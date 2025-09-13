import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../core/utils/constants.dart';
import 'firebase_service.dart';
import 'auth_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Bildirimleri başlat
  static Future<void> initialize() async {
    try {
      // Bildirim izni iste
      await requestPermission();
      
      // FCM token al ve kaydet
      await updateFCMToken();
      
      // Token yenileme dinleyicisi
      _messaging.onTokenRefresh.listen((token) {
        updateFCMToken();
      });
      
      // Foreground bildirimleri dinle
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Background'dan bildirim açıldığında
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      
      // App kapalıyken bildirim açıldığında
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
      
    } catch (e) {
      print('Notification service başlatılamadı: $e');
    }
  }

  // Bildirim izni iste
  static Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      print('Bildirim izni alınamadı: $e');
      return false;
    }
  }

  // FCM token'ı al ve kullanıcı profiline kaydet
  static Future<void> updateFCMToken() async {
    try {
      final token = await _messaging.getToken();
      final userId = AuthService.currentUserId;
      
      if (token != null && userId != null) {
        // Firestore'da kullanıcının FCM token'ını güncelle
        await FirebaseService.users.doc(userId).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        
        // SharedPreferences'a da kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
      }
    } catch (e) {
      print('FCM token güncellenemedi: $e');
    }
  }

  // Bildirim gönder (admin/sistem tarafından)
  static Future<void> sendNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    String? imageUrl,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? actionText,
    DateTime? scheduledAt,
  }) async {
    try {
      // Kullanıcının bildirim ayarlarını kontrol et
      final settings = await getUserNotificationSettings(userId);
      if (settings != null && !settings.pushNotificationsEnabled) {
        return; // Bildirimler kapalı
      }

      // Tip bazlı kontrol
      if (settings != null && !(settings.typeSettings[type] ?? true)) {
        return; // Bu tip bildirimler kapalı
      }

      // Günlük bildirim limitini kontrol et
      if (settings != null) {
        final todayCount = await getTodayNotificationCount(userId);
        if (todayCount >= settings.maxDailyNotifications) {
          return; // Günlük limit aşıldı
        }
      }

      // Sessiz saatleri kontrol et
      if (settings?.quietHours != null) {
        final now = DateTime.now();
        if (settings!.quietHours!.isInQuietHours(now)) {
          return; // Sessiz saatlerde
        }
      }

      // Bildirim modeli oluştur
      final notification = NotificationModel(
        id: '', // Firestore otomatik ID verecek
        userId: userId,
        type: type,
        priority: _getNotificationPriority(type),
        status: NotificationStatus.pending,
        title: title,
        message: message,
        imageUrl: imageUrl,
        data: data ?? {},
        actionUrl: actionUrl,
        actionText: actionText,
        createdAt: DateTime.now(),
        scheduledAt: scheduledAt,
      );

      // Firestore'a kaydet
      final docRef = await FirebaseService.notifications.add(notification.toFirestore());

      // Hemen gönder (zamanlanmadıysa)
      if (scheduledAt == null || scheduledAt.isBefore(DateTime.now())) {
        await _sendPushNotification(userId, title, message, imageUrl, data);
        
        // NOT: _sendPushNotification sadece payload oluşturur, gerçek gönderim için backend servisi gerekli
        // Bu nedenle status'u 'queued' olarak işaretliyoruz, backend başarıyla gönderdiğinde 'sent' olacak
        await docRef.update({
          'status': NotificationStatus.pending.toString().split('.').last,
          'queuedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Bildirim gönderilirken hata: $e');
    }
  }

  // Push bildirim gönder
  static Future<void> _sendPushNotification(
    String userId,
    String title,
    String message,
    String? imageUrl,
    Map<String, dynamic>? data,
  ) async {
    try {
      // Kullanıcının FCM token'ını al
      final userDoc = await FirebaseService.users.doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final fcmToken = userData['fcmToken'] as String?;
      
      if (fcmToken == null) return;

      // FCM mesaj payload'ı
      final messagePayload = {
        'to': fcmToken,
        'notification': {
          'title': title,
          'body': message,
          if (imageUrl != null) 'image': imageUrl,
        },
        'data': data ?? {},
        'android': {
          'notification': {
            'icon': 'ic_notification',
            'color': '#6366F1',
            'channel_id': 'default',
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'badge': 1,
              'sound': 'default',
            },
          },
        },
      };

      // DİKKAT: Bu method sadece FCM payload'ı hazırlar, gerçek gönderim yapmaz!
      // Gerçek gönderim için Cloud Functions veya backend servisiniz gerekli
      // FCM Admin SDK kullanarak bu payload'ı backend'den göndermeniz gerekir
      print('FCM message payload prepared (not sent): $messagePayload');
      
    } catch (e) {
      print('Push bildirim gönderilirken hata: $e');
    }
  }

  // Foreground bildirim işleyici
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground bildirim alındı: ${message.notification?.title}');
    
    // Bildirim durumunu güncelle
    _updateNotificationStatus(message, NotificationStatus.delivered);
    
    // Local notification göster (isteğe bağlı)
    // Bu örnekte sadece log yazıyoruz
  }

  // Bildirim açıldığında işleyici
  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('Bildirim açıldı: ${message.notification?.title}');
    
    // Bildirim durumunu güncelle
    _updateNotificationStatus(message, NotificationStatus.read);
    
    // Action URL varsa navigate et
    final actionUrl = message.data['actionUrl'] as String?;
    if (actionUrl != null) {
      // Burada navigation logic'i ekleyebilirsiniz
      print('Navigating to: $actionUrl');
    }
  }

  // Bildirim durumunu güncelle
  static Future<void> _updateNotificationStatus(
    RemoteMessage message,
    NotificationStatus status,
  ) async {
    try {
      final notificationId = message.data['notificationId'] as String?;
      if (notificationId == null) return;

      await FirebaseService.notifications.doc(notificationId).update({
        'status': status.toString().split('.').last,
        if (status == NotificationStatus.delivered) 'deliveredAt': FieldValue.serverTimestamp(),
        if (status == NotificationStatus.read) 'readAt': FieldValue.serverTimestamp(),
        'isRead': status == NotificationStatus.read,
      });
    } catch (e) {
      print('Bildirim durumu güncellenirken hata: $e');
    }
  }

  // Kullanıcının bildirim ayarlarını al
  static Future<NotificationSettings?> getUserNotificationSettings(String userId) async {
    try {
      final doc = await FirebaseService.firestore
          .collection('notification_settings')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return NotificationSettings.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Bildirim ayarları alınamadı: $e');
      return null;
    }
  }

  // Bugünkü bildirim sayısını al
  static Future<int> getTodayNotificationCount(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final query = await FirebaseService.notifications
          .where('userId', isEqualTo: userId)
          .where('sentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('sentAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return query.docs.length;
    } catch (e) {
      print('Günlük bildirim sayısı alınamadı: $e');
      return 0;
    }
  }

  // Bildirim önceliğini belirle
  static NotificationPriority _getNotificationPriority(NotificationType type) {
    switch (type) {
      case NotificationType.pulseCheck:
        return NotificationPriority.high;
      case NotificationType.analysisReady:
        return NotificationPriority.medium;
      case NotificationType.trainingReminder:
        return NotificationPriority.low;
      case NotificationType.gameInvitation:
        return NotificationPriority.low;
      case NotificationType.achievementUnlocked:
        return NotificationPriority.medium;
      case NotificationType.dailyReward:
        return NotificationPriority.low;
      case NotificationType.partnerActivity:
        return NotificationPriority.medium;
      case NotificationType.systemUpdate:
        return NotificationPriority.high;
      case NotificationType.premium:
        return NotificationPriority.medium;
    }
  }

  // Kullanıcının okunmamış bildirimlerini al
  static Future<List<NotificationModel>> getUnreadNotifications(String userId) async {
    try {
      final query = await FirebaseService.notifications
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return query.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Okunmamış bildirimler alınamadı: $e');
      return [];
    }
  }

  // Bildirimi okundu olarak işaretle
  static Future<void> markAsRead(String notificationId) async {
    try {
      await FirebaseService.notifications.doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
        'status': NotificationStatus.read.toString().split('.').last,
      });
    } catch (e) {
      print('Bildirim okundu işaretlenirken hata: $e');
    }
  }

  // Tüm bildirimleri okundu olarak işaretle
  static Future<void> markAllAsRead(String userId) async {
    try {
      final query = await FirebaseService.notifications
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = FirebaseService.batch();
      for (final doc in query.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
          'status': NotificationStatus.read.toString().split('.').last,
        });
      }

      await batch.commit();
    } catch (e) {
      print('Tüm bildirimler okundu işaretlenirken hata: $e');
    }
  }
}