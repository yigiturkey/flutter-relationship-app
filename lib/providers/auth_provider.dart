import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // Constructor
  AuthProvider() {
    _initializeAuth();
  }

  // Auth durumunu dinle
  void _initializeAuth() {
    AuthService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserProfile(firebaseUser.uid);
      } else {
        _setUnauthenticated();
      }
    });
  }

  // Kullanıcı profilini yükle
  Future<void> _loadUserProfile(String userId) async {
    try {
      _setStatus(AuthStatus.loading);
      
      final userProfile = await AuthService.getCurrentUserProfile();
      if (userProfile != null) {
        _user = userProfile;
        _setStatus(AuthStatus.authenticated);
        await AnalyticsService.trackAppOpen();
      } else {
        _setUnauthenticated();
      }
    } catch (e) {
      _setError('Kullanıcı profili yüklenirken hata: $e');
    }
  }

  // E-posta ile kayıt
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required int age,
    String? phone,
  }) async {
    try {
      _setStatus(AuthStatus.loading);
      
      final user = await AuthService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        age: age,
        phone: phone,
      );

      if (user != null) {
        _user = user;
        _setStatus(AuthStatus.authenticated);
        
        await AnalyticsService.trackUserAction(
          action: 'user_registered',
          parameters: {
            'method': 'email',
            'age': age,
          },
        );
        
        return true;
      } else {
        _setError('Kayıt işlemi başarısız');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // E-posta ile giriş
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setStatus(AuthStatus.loading);
      
      final user = await AuthService.signInWithEmail(
        email: email,
        password: password,
      );

      if (user != null) {
        _user = user;
        _setStatus(AuthStatus.authenticated);
        
        await AnalyticsService.trackUserAction(
          action: 'user_logged_in',
          parameters: {
            'method': 'email',
          },
        );
        
        return true;
      } else {
        _setError('Giriş işlemi başarısız');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Çıkış
  Future<void> signOut() async {
    try {
      _setStatus(AuthStatus.loading);
      
      await AnalyticsService.trackUserAction(action: 'user_logged_out');
      await AnalyticsService.trackAppClose();
      await AuthService.signOut();
      
      _setUnauthenticated();
    } catch (e) {
      _setError('Çıkış işlemi başarısız: $e');
    }
  }

  // Şifre sıfırlama
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setStatus(AuthStatus.loading);
      
      await AuthService.sendPasswordResetEmail(email);
      
      await AnalyticsService.trackUserAction(
        action: 'password_reset_requested',
        parameters: {'email': email},
      );
      
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      // Loading durumunu koru çünkü kullanıcı hala giriş yapmamış
      if (_status == AuthStatus.loading) {
        _setStatus(AuthStatus.unauthenticated);
      }
    }
  }

  // E-posta doğrulama gönder
  Future<bool> sendEmailVerification() async {
    try {
      await AuthService.sendEmailVerification();
      
      await AnalyticsService.trackUserAction(
        action: 'email_verification_sent',
      );
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // E-posta doğrulandı mı kontrol et
  Future<bool> checkEmailVerification() async {
    try {
      final isVerified = await AuthService.isEmailVerified();
      
      if (isVerified && _user != null) {
        // Kullanıcı profilini yeniden yükle
        await _loadUserProfile(_user!.id);
      }
      
      return isVerified;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Profil güncelle
  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      _setStatus(AuthStatus.loading);
      
      final user = await AuthService.updateUserProfile(updatedUser);
      _user = user;
      
      await AnalyticsService.trackUserAction(
        action: 'profile_updated',
        parameters: {
          'fields_updated': _getUpdatedFields(_user!, updatedUser),
        },
      );
      
      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      _setError('Profil güncellenirken hata: $e');
      return false;
    }
  }

  // Şifre güncelle
  Future<bool> updatePassword(String newPassword) async {
    try {
      await AuthService.updatePassword(newPassword);
      
      await AnalyticsService.trackUserAction(
        action: 'password_updated',
      );
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Hesap sil
  Future<bool> deleteAccount() async {
    try {
      _setStatus(AuthStatus.loading);
      
      await AnalyticsService.trackUserAction(
        action: 'account_deleted',
      );
      
      await AuthService.deleteAccount();
      _setUnauthenticated();
      
      return true;
    } catch (e) {
      _setError('Hesap silinirken hata: $e');
      return false;
    }
  }

  // Premium durumunu güncelle
  void updatePremiumStatus(bool isPremium) {
    if (_user != null) {
      _user = _user!.copyWith(isPremium: isPremium);
      notifyListeners();
    }
  }

  // Token bakiyesini güncelle
  void updateTokenBalance(int newBalance) {
    if (_user != null) {
      _user = _user!.copyWith(tokenBalance: newBalance);
      notifyListeners();
    }
  }

  // İstatistikleri güncelle
  void updateStats(UserStats newStats) {
    if (_user != null) {
      _user = _user!.copyWith(stats: newStats);
      notifyListeners();
    }
  }

  // Helper methods
  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
    notifyListeners();
  }

  void _setUnauthenticated() {
    _status = AuthStatus.unauthenticated;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  List<String> _getUpdatedFields(UserModel oldUser, UserModel newUser) {
    final updatedFields = <String>[];
    
    if (oldUser.name != newUser.name) updatedFields.add('name');
    if (oldUser.age != newUser.age) updatedFields.add('age');
    if (oldUser.phone != newUser.phone) updatedFields.add('phone');
    if (oldUser.profileImageUrl != newUser.profileImageUrl) updatedFields.add('profileImage');
    
    return updatedFields;
  }

  @override
  void dispose() {
    super.dispose();
  }
}