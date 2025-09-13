import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import '../core/utils/constants.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Profil resmi yükle
  static Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      
      // Metadata ekle
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putFile(imageFile, metadata);
      
      // Upload progress dinle
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Profil resmi yüklenirken hata: $e');
    }
  }

  // Eğitim içeriği resmi yükle
  static Future<String> uploadTrainingImage(File imageFile, String trainingId, String imageName) async {
    try {
      final ref = _storage.ref()
          .child('training_images')
          .child(trainingId)
          .child('$imageName.jpg');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Eğitim resmi yüklenirken hata: $e');
    }
  }

  // Oyun içeriği resmi yükle
  static Future<String> uploadGameImage(File imageFile, String gameId, String imageName) async {
    try {
      final ref = _storage.ref()
          .child('game_images')
          .child(gameId)
          .child('$imageName.jpg');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Oyun resmi yüklenirken hata: $e');
    }
  }

  // Anı/albüm resmi yükle
  static Future<String> uploadMemoryImage(File imageFile, String userId, String memoryId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref()
          .child('memories')
          .child(userId)
          .child(memoryId)
          .child('$timestamp.jpg');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Anı resmi yüklenirken hata: $e');
    }
  }

  // Audio dosya yükle (eğitim için)
  static Future<String> uploadAudioFile(File audioFile, String trainingId, String fileName) async {
    try {
      final ref = _storage.ref()
          .child('training_audio')
          .child(trainingId)
          .child('$fileName.mp3');

      final metadata = SettableMetadata(
        contentType: 'audio/mpeg',
      );

      final uploadTask = ref.putFile(audioFile, metadata);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Ses dosyası yüklenirken hata: $e');
    }
  }

  // Video dosya yükle (eğitim için)
  static Future<String> uploadVideoFile(File videoFile, String trainingId, String fileName) async {
    try {
      final ref = _storage.ref()
          .child('training_videos')
          .child(trainingId)
          .child('$fileName.mp4');

      final metadata = SettableMetadata(
        contentType: 'video/mp4',
      );

      final uploadTask = ref.putFile(videoFile, metadata);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Video dosyası yüklenirken hata: $e');
    }
  }

  // Dosya sil
  static Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Dosya silinirken hata: $e');
    }
  }

  // URL'den dosya indir
  static Future<File> downloadFile(String url, String localPath) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Dosya indirilemedi: $e');
    }
  }

  // Kullanıcı verilerini yedekle (JSON export için)
  static Future<String> uploadUserDataBackup(String userId, Map<String, dynamic> userData) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final ref = _storage.ref()
          .child('user_backups')
          .child(userId)
          .child('backup_$timestamp.json');

      // JSON string'e çevir
      final jsonData = jsonEncode(userData);
      final bytes = utf8.encode(jsonData);

      final metadata = SettableMetadata(
        contentType: 'application/json',
        customMetadata: {
          'userId': userId,
          'backupDate': timestamp,
        },
      );

      final uploadTask = ref.putData(bytes, metadata);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Veri yedeği oluşturulamadı: $e');
    }
  }

  // Dosya metadata'sını al
  static Future<FullMetadata> getFileMetadata(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Dosya bilgisi alınamadı: $e');
    }
  }

  // Dosya boyutunu al
  static Future<int> getFileSize(String fileUrl) async {
    try {
      final metadata = await getFileMetadata(fileUrl);
      return metadata.size ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Upload progress dinleyici
  static Stream<double> uploadProgress(UploadTask uploadTask) {
    return uploadTask.snapshotEvents.map((snapshot) {
      return (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
    });
  }

  // Cache temizle
  static Future<void> clearCache() async {
    try {
      // Firebase Storage cache temizle
      await _storage.ref().listAll().then((result) async {
        // Bu sadece liste alır, cache temizleme için platform-specific kod gerekir
        print('Cache temizleme işlemi başlatıldı');
      });
    } catch (e) {
      print('Cache temizlenirken hata: $e');
    }
  }

  // Kullanıcının toplam storage kullanımını hesapla
  static Future<int> getUserStorageUsage(String userId) async {
    try {
      int totalSize = 0;
      
      // Profil resimleri
      try {
        final profileRef = _storage.ref().child('profile_images').child('$userId.jpg');
        final metadata = await profileRef.getMetadata();
        totalSize += metadata.size ?? 0;
      } catch (e) {
        // Dosya yoksa hata almayacak
      }

      // Anı resimleri
      try {
        final memoriesRef = _storage.ref().child('memories').child(userId);
        final result = await memoriesRef.listAll();
        
        for (final item in result.items) {
          final metadata = await item.getMetadata();
          totalSize += metadata.size ?? 0;
        }
      } catch (e) {
        // Klasör yoksa hata almayacak
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  // Boyut formatla (bytes -> human readable)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}