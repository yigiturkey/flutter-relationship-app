import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _user?.isPremium ?? false;
  int get tokenBalance => _user?.tokenBalance ?? 0;
  UserStats get stats => _user?.stats ?? UserStats();

  // Kullanıcıyı yükle
  Future<void> loadUser() async {
    if (_isLoading) return;
    
    try {
      _setLoading(true);
      
      final user = await AuthService.getCurrentUserProfile();
      if (user != null) {
        _user = user;
        _clearError();
      } else {
        _setError('Kullanıcı profili bulunamadı');
      }
    } catch (e) {
      _setError('Kullanıcı yüklenirken hata: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı bilgilerini güncelle
  Future<bool> updateUserInfo({
    String? name,
    int? age,
    String? phone,
  }) async {
    if (_user == null) return false;
    
    try {
      _setLoading(true);
      
      final updatedUser = _user!.copyWith(
        name: name ?? _user!.name,
        age: age ?? _user!.age,
        phone: phone ?? _user!.phone,
      );
      
      final result = await AuthService.updateUserProfile(updatedUser);
      _user = result;
      
      await AnalyticsService.trackUserAction(
        action: 'profile_info_updated',
        parameters: {
          'fields': [
            if (name != null && name != _user!.name) 'name',
            if (age != null && age != _user!.age) 'age',
            if (phone != null && phone != _user!.phone) 'phone',
          ],
        },
      );
      
      _clearError();
      return true;
    } catch (e) {
      _setError('Profil güncellenirken hata: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Profil resmi güncelle
  Future<bool> updateProfileImage(String imageUrl) async {
    if (_user == null) return false;
    
    try {
      _setLoading(true);
      
      final updatedUser = _user!.copyWith(profileImageUrl: imageUrl);
      final result = await AuthService.updateUserProfile(updatedUser);
      _user = result;
      
      await AnalyticsService.trackUserAction(
        action: 'profile_image_updated',
      );
      
      _clearError();
      return true;
    } catch (e) {
      _setError('Profil resmi güncellenirken hata: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı tercihlerini güncelle
  Future<bool> updatePreferences(UserPreferences preferences) async {
    if (_user == null) return false;
    
    try {
      _setLoading(true);
      
      final updatedUser = _user!.copyWith(preferences: preferences);
      final result = await AuthService.updateUserProfile(updatedUser);
      _user = result;
      
      await AnalyticsService.trackUserAction(
        action: 'user_preferences_updated',
        parameters: {
          'notifications_enabled': preferences.notificationsEnabled,
          'dark_mode': preferences.darkModeEnabled,
          'language': preferences.language,
          'categories': preferences.interestedCategories,
        },
      );
      
      _clearError();
      return true;
    } catch (e) {
      _setError('Tercihler güncellenirken hata: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Premium'a yükselt
  Future<bool> upgradeToPremium() async {
    if (_user == null) return false;
    
    try {
      _setLoading(true);
      
      final updatedUser = _user!.copyWith(isPremium: true);
      final result = await AuthService.updateUserProfile(updatedUser);
      _user = result;
      
      await AnalyticsService.trackPremiumPurchase(
        planType: 'monthly',
        price: 29.99,
        currency: 'TRY',
      );
      
      _clearError();
      return true;
    } catch (e) {
      _setError('Premium yükseltme hatası: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Token satın al
  Future<bool> purchaseTokens(int amount, double price) async {
    if (_user == null) return false;
    
    try {
      _setLoading(true);
      
      final newBalance = _user!.tokenBalance + amount;
      final updatedUser = _user!.copyWith(tokenBalance: newBalance);
      final result = await AuthService.updateUserProfile(updatedUser);
      _user = result;
      
      await AnalyticsService.trackTokenPurchase(
        tokenAmount: amount,
        price: price,
        currency: 'TRY',
      );
      
      _clearError();
      return true;
    } catch (e) {
      _setError('Token satın alma hatası: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Token harca
  Future<bool> spendTokens(int amount, String reason) async {
    if (_user == null) return false;
    
    if (_user!.tokenBalance < amount) {
      _setError('Yetersiz token bakiyesi');
      return false;
    }
    
    try {
      _setLoading(true);
      
      final newBalance = _user!.tokenBalance - amount;
      final updatedUser = _user!.copyWith(tokenBalance: newBalance);
      final result = await AuthService.updateUserProfile(updatedUser);
      _user = result;
      
      await AnalyticsService.trackUserAction(
        action: 'tokens_spent',
        parameters: {
          'amount': amount,
          'reason': reason,
          'remaining_balance': newBalance,
        },
      );
      
      _clearError();
      return true;
    } catch (e) {
      _setError('Token harcama hatası: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // İstatistikleri güncelle
  Future<void> updateStats({
    int? totalAnalyses,
    int? completedTrainings,
    int? gamesPlayed,
    int? achievementsUnlocked,
  }) async {
    if (_user == null) return;
    
    try {
      final currentStats = _user!.stats;
      final newStats = UserStats(
        totalAnalyses: totalAnalyses ?? currentStats.totalAnalyses,
        completedTrainings: completedTrainings ?? currentStats.completedTrainings,
        gamesPlayed: gamesPlayed ?? currentStats.gamesPlayed,
        achievementsUnlocked: achievementsUnlocked ?? currentStats.achievementsUnlocked,
        streakDays: currentStats.streakDays,
        lastActiveDate: DateTime.now(),
      );
      
      final updatedUser = _user!.copyWith(stats: newStats);
      final result = await AuthService.updateUserProfile(updatedUser);
      _user = result;
      
      notifyListeners();
    } catch (e) {
      _setError('İstatistikler güncellenirken hata: $e');
    }
  }

  // Analiz tamamlandı
  void onAnalysisCompleted() {
    if (_user != null) {
      updateStats(totalAnalyses: _user!.stats.totalAnalyses + 1);
    }
  }

  // Eğitim tamamlandı
  void onTrainingCompleted() {
    if (_user != null) {
      updateStats(completedTrainings: _user!.stats.completedTrainings + 1);
    }
  }

  // Oyun tamamlandı
  void onGameCompleted() {
    if (_user != null) {
      updateStats(gamesPlayed: _user!.stats.gamesPlayed + 1);
    }
  }

  // Achievement unlocked
  void onAchievementUnlocked() {
    if (_user != null) {
      updateStats(achievementsUnlocked: _user!.stats.achievementsUnlocked + 1);
    }
  }

  // Verileri dışa aktar (GDPR)
  Future<Map<String, dynamic>?> exportUserData() async {
    if (_user == null) return null;
    
    try {
      _setLoading(true);
      
      // Kullanıcı verilerini topla
      final userData = {
        'profile': _user!.toFirestore(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
      
      await AnalyticsService.trackUserAction(
        action: 'data_export_requested',
      );
      
      return userData;
    } catch (e) {
      _setError('Veri dışa aktarma hatası: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı storage kullanımını hesapla
  Future<String> getStorageUsage() async {
    if (_user == null) return '0 B';
    
    try {
      final usage = await StorageService.getUserStorageUsage(_user!.id);
      return StorageService.formatFileSize(usage);
    } catch (e) {
      return 'Hesaplanamadı';
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Kullanıcıyı sıfırla (logout için)
  void reset() {
    _user = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}