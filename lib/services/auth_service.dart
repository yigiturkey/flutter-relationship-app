import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/utils/constants.dart';
import 'firebase_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mevcut kullanıcı
  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;
  static bool get isSignedIn => _auth.currentUser != null;

  // Auth state dinleyici
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // E-posta ile kayıt
  static Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required int age,
    String? phone,
  }) async {
    try {
      // Yaş kontrolü (18+)
      if (age < 18) {
        throw Exception('Bu uygulama 18 yaş ve üzeri kullanıcılar içindir');
      }

      // Firebase Auth ile kayıt
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Kullanıcı oluşturulamadı');

      // Display name güncelle
      await user.updateDisplayName(name);

      // Firestore'da kullanıcı profili oluştur
      // DateTime.now() yerine server timestamp kullanmak için placeholder tarih kullanıyoruz
      final now = DateTime.now(); // Placeholder
      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        age: age,
        phone: phone,
        createdAt: now, // Placeholder
        lastLoginAt: now, // Placeholder
        preferences: UserPreferences(),
        stats: UserStats(),
      );

      // Kullanıcı profilini kaydet ve server timestamp ile güncelle
      await FirebaseService.users.doc(user.uid).set(userModel.toFirestore());
      
      // Server timestamp ile güncelle (consistency için)
      await FirebaseService.users.doc(user.uid).update({
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      // SharedPreferences'a kaydet
      await _saveUserToPrefs(userModel);

      // E-posta doğrulama gönder
      await sendEmailVerification();

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Kayıt işlemi başarısız: $e');
    }
  }

  // E-posta ile giriş
  static Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Giriş başarısız');

      // Kullanıcı profilini getir
      final userDoc = await FirebaseService.users.doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('Kullanıcı profili bulunamadı');
      }

      final userModel = UserModel.fromFirestore(userDoc);

      // Son giriş tarihini güncelle
      await FirebaseService.users.doc(user.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      // SharedPreferences'a kaydet
      await _saveUserToPrefs(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Giriş işlemi başarısız: $e');
    }
  }

  // Çıkış
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _clearUserPrefs();
    } catch (e) {
      throw Exception('Çıkış işlemi başarısız: $e');
    }
  }

  // Şifre sıfırlama
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Şifre sıfırlama e-postası gönderilemedi: $e');
    }
  }

  // E-posta doğrulama gönder
  static Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('E-posta doğrulama gönderilemedi: $e');
    }
  }

  // E-posta doğrulandı mı kontrol et
  static Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    await user.reload();
    return user.emailVerified;
  }

  // Şifre güncelle
  static Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı girişi gerekli');
      
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Şifre güncellenemeidi: $e');
    }
  }

  // E-posta güncelle
  static Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı girişi gerekli');
      
      await user.updateEmail(newEmail);
      
      // Firestore'da da güncelle
      await FirebaseService.users.doc(user.uid).update({
        'email': newEmail,
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('E-posta güncellenemedi: $e');
    }
  }

  // Hesap silme
  static Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı girişi gerekli');

      // Firestore'dan kullanıcı verilerini sil
      await FirebaseService.users.doc(user.uid).delete();
      
      // Firebase Auth'dan hesabı sil
      await user.delete();
      
      // SharedPreferences'ı temizle
      await _clearUserPrefs();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Hesap silinemedi: $e');
    }
  }

  // Kullanıcı profilini güncelle
  static Future<UserModel> updateUserProfile(UserModel updatedUser) async {
    try {
      await FirebaseService.users.doc(updatedUser.id).update(updatedUser.toFirestore());
      await _saveUserToPrefs(updatedUser);
      return updatedUser;
    } catch (e) {
      throw Exception('Profil güncellenemedi: $e');
    }
  }

  // Mevcut kullanıcı profilini getir
  static Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await FirebaseService.users.doc(user.uid).get();
      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      print('Kullanıcı profili alınamadı: $e');
      return null;
    }
  }

  // SharedPreferences'dan kullanıcı bilgisi al
  static Future<UserModel?> getUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConstants.userIdKey);
      if (userJson == null) return null;

      // Bu örnekte sadece ID'yi saklıyoruz, tam profili Firebase'den alıyoruz
      return await getCurrentUserProfile();
    } catch (e) {
      return null;
    }
  }

  // Kullanıcıyı SharedPreferences'a kaydet
  static Future<void> _saveUserToPrefs(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userIdKey, user.id);
    } catch (e) {
      print('Kullanıcı bilgisi kaydedilemedi: $e');
    }
  }

  // SharedPreferences'ı temizle
  static Future<void> _clearUserPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userIdKey);
      await prefs.remove(AppConstants.userTokenKey);
    } catch (e) {
      print('Kullanıcı bilgisi temizlenemedi: $e');
    }
  }

  // Firebase Auth hatalarını işle
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Şifre çok zayıf';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Hatalı şifre';
      case 'user-disabled':
        return 'Kullanıcı hesabı devre dışı bırakılmış';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda izin verilmiyor';
      case 'requires-recent-login':
        return 'Bu işlem için yeniden giriş yapmanız gerekiyor';
      default:
        return 'Kimlik doğrulama hatası: ${e.message}';
    }
  }
}