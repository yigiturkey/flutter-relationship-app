import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/utils/constants.dart';
import 'firebase_service.dart';
import 'auth_service.dart';

class AnalyticsService {
  // Kullanıcı davranışlarını takip et
  static Future<void> trackUserAction({
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return;

      final eventData = {
        'userId': userId,
        'action': action,
        'parameters': parameters ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'mobile',
        'appVersion': AppConstants.appVersion,
      };

      await FirebaseService.firestore
          .collection('user_events')
          .add(eventData);
    } catch (e) {
      print('Analytics event kaydedilirken hata: $e');
    }
  }

  // Analiz tamamlama olayı
  static Future<void> trackAnalysisCompleted({
    required String analysisId,
    required String analysisType,
    required double score,
    required int timeSpent, // saniye
  }) async {
    await trackUserAction(
      action: 'analysis_completed',
      parameters: {
        'analysisId': analysisId,
        'analysisType': analysisType,
        'score': score,
        'timeSpent': timeSpent,
      },
    );
  }

  // Eğitim tamamlama olayı
  static Future<void> trackTrainingCompleted({
    required String trainingId,
    required String trainingType,
    required double progressPercentage,
    required int timeSpent,
  }) async {
    await trackUserAction(
      action: 'training_completed',
      parameters: {
        'trainingId': trainingId,
        'trainingType': trainingType,
        'progressPercentage': progressPercentage,
        'timeSpent': timeSpent,
      },
    );
  }

  // Oyun tamamlama olayı
  static Future<void> trackGameCompleted({
    required String gameId,
    required String gameType,
    required int score,
    required int timeSpent,
  }) async {
    await trackUserAction(
      action: 'game_completed',
      parameters: {
        'gameId': gameId,
        'gameType': gameType,
        'score': score,
        'timeSpent': timeSpent,
      },
    );
  }

  // Premium satın alma olayı
  static Future<void> trackPremiumPurchase({
    required String planType,
    required double price,
    required String currency,
  }) async {
    await trackUserAction(
      action: 'premium_purchased',
      parameters: {
        'planType': planType,
        'price': price,
        'currency': currency,
      },
    );
  }

  // Token satın alma olayı
  static Future<void> trackTokenPurchase({
    required int tokenAmount,
    required double price,
    required String currency,
  }) async {
    await trackUserAction(
      action: 'tokens_purchased',
      parameters: {
        'tokenAmount': tokenAmount,
        'price': price,
        'currency': currency,
      },
    );
  }

  // Uygulama açılışı
  static Future<void> trackAppOpen() async {
    await trackUserAction(action: 'app_opened');
    await _updateSessionInfo();
  }

  // Uygulama kapanışı
  static Future<void> trackAppClose() async {
    await trackUserAction(action: 'app_closed');
    await _updateSessionEnd();
  }

  // Ekran görüntüleme
  static Future<void> trackScreenView(String screenName) async {
    await trackUserAction(
      action: 'screen_view',
      parameters: {'screenName': screenName},
    );
  }

  // Hata takibi
  static Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    await trackUserAction(
      action: 'error_occurred',
      parameters: {
        'errorType': errorType,
        'errorMessage': errorMessage,
        'stackTrace': stackTrace,
        'context': context ?? {},
      },
    );
  }

  // Kullanıcı oturum bilgilerini güncelle
  static Future<void> _updateSessionInfo() async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return;

      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      
      // Session başlangıcını kaydet
      await prefs.setString('session_start', now.toIso8601String());
      
      // Kullanıcı istatistiklerini güncelle
      await FirebaseService.users.doc(userId).update({
        'lastActiveDate': FieldValue.serverTimestamp(),
        'stats.lastActiveDate': FieldValue.serverTimestamp(),
      });

      // Daily streak hesapla
      await _updateDailyStreak(userId);
    } catch (e) {
      print('Session info güncellenirken hata: $e');
    }
  }

  // Oturum sonunu kaydet
  static Future<void> _updateSessionEnd() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionStartStr = prefs.getString('session_start');
      
      if (sessionStartStr != null) {
        final sessionStart = DateTime.parse(sessionStartStr);
        final sessionDuration = DateTime.now().difference(sessionStart).inSeconds;
        
        await trackUserAction(
          action: 'session_ended',
          parameters: {
            'sessionDuration': sessionDuration,
          },
        );
        
        await prefs.remove('session_start');
      }
    } catch (e) {
      print('Session end kaydedilirken hata: $e');
    }
  }

  // Günlük streak hesapla
  static Future<void> _updateDailyStreak(String userId) async {
    try {
      final userDoc = await FirebaseService.users.doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final stats = userData['stats'] as Map<String, dynamic>? ?? {};
      
      final lastActiveDate = stats['lastActiveDate'] as Timestamp?;
      final currentStreak = stats['streakDays'] as int? ?? 0;
      
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      
      int newStreak = 1;
      
      if (lastActiveDate != null) {
        final lastActive = lastActiveDate.toDate();
        final lastActiveDay = DateTime(lastActive.year, lastActive.month, lastActive.day);
        final todayDay = DateTime(today.year, today.month, today.day);
        final yesterdayDay = DateTime(yesterday.year, yesterday.month, yesterday.day);
        
        if (lastActiveDay == yesterdayDay) {
          // Dün aktifti, streak devam ediyor
          newStreak = currentStreak + 1;
        } else if (lastActiveDay == todayDay) {
          // Bugün zaten giriş yapmış
          newStreak = currentStreak;
        } else {
          // Streak bozuldu
          newStreak = 1;
        }
      }
      
      await FirebaseService.users.doc(userId).update({
        'stats.streakDays': newStreak,
      });

      // Streak milestone'ları için achievement kontrol et
      await _checkStreakAchievements(userId, newStreak);
    } catch (e) {
      print('Daily streak güncellenirken hata: $e');
    }
  }

  // Streak achievement kontrolleri
  static Future<void> _checkStreakAchievements(String userId, int streakDays) async {
    try {
      final milestones = [7, 30, 100, 365]; // 1 hafta, 1 ay, 100 gün, 1 yıl
      
      for (final milestone in milestones) {
        if (streakDays == milestone) {
          await _grantAchievement(userId, 'streak_$milestone', {
            'streakDays': streakDays,
            'achievementType': 'daily_streak',
          });
        }
      }
    } catch (e) {
      print('Streak achievement kontrol edilirken hata: $e');
    }
  }

  // Achievement ver
  static Future<void> _grantAchievement(
    String userId,
    String achievementId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Achievement zaten verilmiş mi kontrol et
      final existingAchievement = await FirebaseService.achievements
          .where('userId', isEqualTo: userId)
          .where('achievementId', isEqualTo: achievementId)
          .get();

      if (existingAchievement.docs.isNotEmpty) return;

      // Yeni achievement ekle
      await FirebaseService.achievements.add({
        'userId': userId,
        'achievementId': achievementId,
        'data': data,
        'earnedAt': FieldValue.serverTimestamp(),
      });

      // Kullanıcı istatistiklerini güncelle
      await FirebaseService.users.doc(userId).update({
        'stats.achievementsUnlocked': FieldValue.increment(1),
      });

      // Achievement bildirimi gönder
      // NotificationService.sendNotification çağrılabilir
      await trackUserAction(
        action: 'achievement_unlocked',
        parameters: {
          'achievementId': achievementId,
          'data': data,
        },
      );
    } catch (e) {
      print('Achievement verilirken hata: $e');
    }
  }

  // Kullanıcı davranış raporu al
  static Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    try {
      // Son 30 günün aktivitelerini al
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final events = await FirebaseService.firestore
          .collection('user_events')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
          .orderBy('timestamp', descending: true)
          .get();

      // İstatistikleri hesapla
      final analytics = <String, dynamic>{};
      final actionCounts = <String, int>{};
      
      for (final doc in events.docs) {
        final data = doc.data();
        final action = data['action'] as String;
        actionCounts[action] = (actionCounts[action] ?? 0) + 1;
      }

      analytics['totalEvents'] = events.docs.length;
      analytics['actionCounts'] = actionCounts;
      analytics['period'] = '30_days';
      analytics['generatedAt'] = DateTime.now().toIso8601String();

      return analytics;
    } catch (e) {
      print('Kullanıcı analitiği alınırken hata: $e');
      return {};
    }
  }

  // Uygulama performans metrikleri
  static Future<void> trackPerformanceMetric({
    required String metricName,
    required double value,
    String? unit,
    Map<String, dynamic>? context,
  }) async {
    await trackUserAction(
      action: 'performance_metric',
      parameters: {
        'metricName': metricName,
        'value': value,
        'unit': unit,
        'context': context ?? {},
      },
    );
  }

  // API çağrı sürelerini takip et
  static Future<void> trackAPICall({
    required String endpoint,
    required int durationMs,
    required int statusCode,
    bool success = true,
  }) async {
    await trackUserAction(
      action: 'api_call',
      parameters: {
        'endpoint': endpoint,
        'durationMs': durationMs,
        'statusCode': statusCode,
        'success': success,
      },
    );
  }
}