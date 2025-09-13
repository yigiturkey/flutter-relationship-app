import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  // Firestore koleksiyonları
  static CollectionReference get users => firestore.collection('users');
  static CollectionReference get analyses => firestore.collection('analyses');
  static CollectionReference get trainings => firestore.collection('trainings');
  static CollectionReference get games => firestore.collection('games');
  static CollectionReference get achievements => firestore.collection('achievements');
  static CollectionReference get notifications => firestore.collection('notifications');
  static CollectionReference get transactions => firestore.collection('transactions');
  static CollectionReference get memories => firestore.collection('memories');
  static CollectionReference get relationships => firestore.collection('relationships');

  // Firebase başlatma
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      await _configureFirestore();
      await _configureMessaging();
    } catch (e) {
      throw Exception('Firebase başlatma hatası: $e');
    }
  }

  // Firestore ayarları
  static Future<void> _configureFirestore() async {
    try {
      // Offline persistance etkinleştir
      await firestore.enablePersistence();
      
      // Cache boyutu ayarla (100MB)
      FirebaseFirestore.instance.settings = const Settings(
        cacheSizeBytes: 104857600, // 100MB
        persistenceEnabled: true,
      );
    } catch (e) {
      // Persistance zaten etkinse hata almayacak
      print('Firestore persistance ayarı: $e');
    }
  }

  // Messaging ayarları
  static Future<void> _configureMessaging() async {
    try {
      // Bildirim izni iste
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Kullanıcı bildirimlere izin verdi');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('Kullanıcı geçici bildirimlere izin verdi');
      } else {
        print('Kullanıcı bildirimlere izin vermedi');
      }

      // Foreground bildirimleri için ayar
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      print('Messaging yapılandırma hatası: $e');
    }
  }

  // FCM token al
  static Future<String?> getFCMToken() async {
    try {
      return await messaging.getToken();
    } catch (e) {
      print('FCM token alma hatası: $e');
      return null;
    }
  }

  // Token yenileme dinleyici
  static void listenToTokenRefresh(Function(String) onTokenRefresh) {
    messaging.onTokenRefresh.listen(onTokenRefresh);
  }

  // Foreground bildirimler
  static void listenToForegroundMessages(Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  // Background bildirimler için NOT:
  // FirebaseMessaging.onBackgroundMessage() sadece top-level function kabul eder!
  // Bu method'u doğrudan main.dart'ta şu şekilde kullanın:
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // 
  // Örnek top-level function:
  // @pragma('vm:entry-point')
  // Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   await Firebase.initializeApp();
  //   print("Background message alındı: ${message.messageId}");
  // }

  // Notification açıldığında
  static void listenToMessageOpenedApp(Function(RemoteMessage) onMessageOpenedApp) {
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
  }

  // Batch operations
  static WriteBatch batch() => firestore.batch();

  // Transaction operations
  static Future<T> runTransaction<T>(
    TransactionHandler<T> updateFunction, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    return await firestore.runTransaction(updateFunction, timeout: timeout);
  }

  // Server timestamp
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  // Array operations
  static FieldValue arrayUnion(List<Object?> elements) => FieldValue.arrayUnion(elements);
  static FieldValue arrayRemove(List<Object?> elements) => FieldValue.arrayRemove(elements);

  // Increment
  static FieldValue increment(num value) => FieldValue.increment(value);

  // Delete field
  static FieldValue get delete => FieldValue.delete();

}