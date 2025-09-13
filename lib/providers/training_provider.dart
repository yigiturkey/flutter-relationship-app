import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/training_model.dart';
import '../models/firebase_collections.dart';
import '../providers/auth_provider.dart';

enum TrainingProviderStatus {
  initial,
  loading,
  ready,
  inProgress,
  completed,
  error,
}

class TrainingProvider extends ChangeNotifier {
  final AuthProvider? _authProvider;
  TrainingProviderStatus _status = TrainingProviderStatus.initial;
  List<TrainingModel> _availableTrainings = [];
  List<UserTrainingProgress> _userProgress = [];
  TrainingModel? _currentTraining;
  UserTrainingProgress? _currentProgress;
  String? _errorMessage;
  bool _isLoadingTrainings = false;
  bool _isLoadingProgress = false;

  // Getters
  TrainingProviderStatus get status => _status;
  List<TrainingModel> get availableTrainings => _availableTrainings;
  List<UserTrainingProgress> get userProgress => _userProgress;
  TrainingModel? get currentTraining => _currentTraining;
  UserTrainingProgress? get currentProgress => _currentProgress;
  String? get errorMessage => _errorMessage;
  bool get isLoadingTrainings => _isLoadingTrainings;
  bool get isLoadingProgress => _isLoadingProgress;
  bool get isLoading => _status == TrainingProviderStatus.loading;

  TrainingProvider(this._authProvider);

  // Convenience method for backward compatibility
  Future<void> loadTrainings() async {
    await loadAvailableTrainings();
  }

  // Mevcut eğitimleri yükle
  Future<void> loadAvailableTrainings() async {
    try {
      _isLoadingTrainings = true;
      notifyListeners();

      final query = await FirebaseFirestore.instance
          .collection(FirebaseCollections.trainings)
          .orderBy('createdAt', descending: true)
          .get();

      _availableTrainings = query.docs
          .map((doc) => TrainingModel.fromFirestore(doc))
          .toList();

      _clearError();
    } catch (e) {
      _setError('Eğitimler yüklenemedi: $e');
    } finally {
      _isLoadingTrainings = false;
      notifyListeners();
    }
  }

  // Kullanıcının eğitim ilerlemesini yükle
  Future<void> loadUserProgress(String userId) async {
    try {
      _isLoadingProgress = true;
      notifyListeners();

      final query = await FirebaseService.firestore
          .collection('user_training_progress')
          .where('userId', isEqualTo: userId)
          .get();

      _userProgress = query.docs
          .map((doc) => UserTrainingProgress.fromFirestore(doc))
          .toList();

      _clearError();
    } catch (e) {
      _setError('Eğitim ilerlemesi yüklenemedi: $e');
    } finally {
      _isLoadingProgress = false;
      notifyListeners();
    }
  }

  // Kategoriye göre eğitimleri filtrele
  List<TrainingModel> getTrainingsByCategory(TrainingType category) {
    return _availableTrainings
        .where((training) => training.type == category)
        .toList();
  }

  // Zorluk seviyesine göre eğitimleri filtrele
  List<TrainingModel> getTrainingsByDifficulty(TrainingDifficulty difficulty) {
    return _availableTrainings
        .where((training) => training.difficulty == difficulty)
        .toList();
  }

  // Premium durumuna göre eğitimleri filtrele
  List<TrainingModel> getFreeTrainings() {
    return _availableTrainings
        .where((training) => !training.isPremium)
        .toList();
  }

  List<TrainingModel> getPremiumTrainings() {
    return _availableTrainings.where((training) => training.isPremium).toList();
  }

  // Eğitimi başlat
  Future<bool> startTraining(String userId, String trainingId) async {
    try {
      _setStatus(TrainingProviderStatus.loading);

      // Eğitimi bul
      final training = _availableTrainings.firstWhere(
        (t) => t.id == trainingId,
        orElse: () => throw Exception('Eğitim bulunamadı'),
      );

      // Mevcut ilerleme var mı kontrol et
      UserTrainingProgress? existingProgress;
      try {
        final progressQuery = await FirebaseService.firestore
            .collection('user_training_progress')
            .where('userId', isEqualTo: userId)
            .where('trainingId', isEqualTo: trainingId)
            .get();

        if (progressQuery.docs.isNotEmpty) {
          existingProgress = UserTrainingProgress.fromFirestore(
            progressQuery.docs.first,
          );
        }
      } catch (e) {
        // İlerleme bulunamadı, yeni oluşturulacak
      }

      UserTrainingProgress progress;
      if (existingProgress != null) {
        // Mevcut ilerlemeyi devam ettir
        progress = existingProgress.copyWith(
          status: TrainingStatus.inProgress,
          lastAccessedAt: DateTime.now(),
        );
      } else {
        // Yeni ilerleme oluştur
        progress = UserTrainingProgress(
          id: '', // Firestore otomatik ID verecek
          userId: userId,
          trainingId: trainingId,
          status: TrainingStatus.inProgress,
          completedModules: [],
          exerciseResults: {},
          startedAt: DateTime.now(),
          lastAccessedAt: DateTime.now(),
        );
      }

      // Firestore'a kaydet
      if (existingProgress != null) {
        await FirebaseService.firestore
            .collection('user_training_progress')
            .doc(existingProgress.id)
            .update(progress.toFirestore());
      } else {
        await FirebaseService.firestore
            .collection('user_training_progress')
            .add(progress.toFirestore());
      }

      _currentTraining = training;
      _currentProgress = progress;
      _setStatus(TrainingProviderStatus.inProgress);

      await AnalyticsService.trackUserAction(
        action: 'training_started',
        parameters: {
          'trainingId': trainingId,
          'trainingType': training.type.toString().split('.').last,
          'difficulty': training.difficulty.toString().split('.').last,
          'isPremium': training.isPremium,
        },
      );

      return true;
    } catch (e) {
      _setError('Eğitim başlatılamadı: $e');
      return false;
    }
  }

  // Modülü tamamla
  Future<bool> completeModule(
    String moduleId,
    Map<String, dynamic> exerciseResults,
  ) async {
    if (_currentProgress == null || _currentTraining == null) return false;

    try {
      // Modülü tamamlananlara ekle
      final completedModules = List<String>.from(
        _currentProgress!.completedModules,
      );
      if (!completedModules.contains(moduleId)) {
        completedModules.add(moduleId);
      }

      // Egzersiz sonuçlarını güncelle
      final updatedExerciseResults = Map<String, dynamic>.from(
        _currentProgress!.exerciseResults,
      );
      updatedExerciseResults[moduleId] = exerciseResults;

      // İlerleme yüzdesini hesapla
      final progressPercentage =
          (completedModules.length / _currentTraining!.modules.length) * 100;

      // İlerlemeyi güncelle
      _currentProgress = _currentProgress!.copyWith(
        completedModules: completedModules,
        exerciseResults: updatedExerciseResults,
        progressPercentage: progressPercentage,
        lastAccessedAt: DateTime.now(),
        status: progressPercentage >= 100
            ? TrainingStatus.completed
            : TrainingStatus.inProgress,
        completedAt: progressPercentage >= 100 ? DateTime.now() : null,
      );

      // Firestore'da güncelle
      await FirebaseService.firestore
          .collection('user_training_progress')
          .doc(_currentProgress!.id)
          .update(_currentProgress!.toFirestore());

      if (progressPercentage >= 100) {
        _setStatus(TrainingProviderStatus.completed);

        await AnalyticsService.trackTrainingCompleted(
          trainingId: _currentTraining!.id,
          trainingType: _currentTraining!.type.toString().split('.').last,
          progressPercentage: progressPercentage,
          timeSpent: DateTime.now()
              .difference(_currentProgress!.startedAt)
              .inSeconds,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Modül tamamlanırken hata: $e');
      return false;
    }
  }

  // Eğitimi duraklat
  Future<bool> pauseTraining() async {
    if (_currentProgress == null) return false;

    try {
      _currentProgress = _currentProgress!.copyWith(
        status: TrainingStatus.paused,
        lastAccessedAt: DateTime.now(),
      );

      await FirebaseService.firestore
          .collection('user_training_progress')
          .doc(_currentProgress!.id)
          .update(_currentProgress!.toFirestore());

      await AnalyticsService.trackUserAction(
        action: 'training_paused',
        parameters: {
          'trainingId': _currentTraining?.id,
          'progressPercentage': _currentProgress!.progressPercentage,
        },
      );

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Eğitim duraklatılamadı: $e');
      return false;
    }
  }

  // Eğitimi devam ettir
  Future<bool> resumeTraining() async {
    if (_currentProgress == null) return false;

    try {
      _currentProgress = _currentProgress!.copyWith(
        status: TrainingStatus.inProgress,
        lastAccessedAt: DateTime.now(),
      );

      await FirebaseService.firestore
          .collection('user_training_progress')
          .doc(_currentProgress!.id)
          .update(_currentProgress!.toFirestore());

      _setStatus(TrainingProviderStatus.inProgress);

      await AnalyticsService.trackUserAction(
        action: 'training_resumed',
        parameters: {
          'trainingId': _currentTraining?.id,
          'progressPercentage': _currentProgress!.progressPercentage,
        },
      );

      return true;
    } catch (e) {
      _setError('Eğitim devam ettirilemedi: $e');
      return false;
    }
  }

  // Belirli bir eğitimin ilerlemesini al
  UserTrainingProgress? getTrainingProgress(String trainingId) {
    try {
      return _userProgress.firstWhere(
        (progress) => progress.trainingId == trainingId,
      );
    } catch (e) {
      return null;
    }
  }

  // Tamamlanan eğitimleri al
  List<UserTrainingProgress> getCompletedTrainings() {
    return _userProgress
        .where((progress) => progress.status == TrainingStatus.completed)
        .toList();
  }

  // Devam eden eğitimleri al
  List<UserTrainingProgress> getInProgressTrainings() {
    return _userProgress
        .where((progress) => progress.status == TrainingStatus.inProgress)
        .toList();
  }

  // Eğitim önerilerini al (kullanıcının seviyesine göre)
  List<TrainingModel> getRecommendedTrainings(String userId) {
    final completedCount = getCompletedTrainings().length;

    if (completedCount == 0) {
      // Yeni kullanıcılar için başlangıç eğitimleri
      return _availableTrainings
          .where(
            (training) =>
                training.difficulty == TrainingDifficulty.beginner &&
                !training.isPremium,
          )
          .take(3)
          .toList();
    } else if (completedCount < 3) {
      // Az deneyimli kullanıcılar için orta seviye
      return _availableTrainings
          .where(
            (training) =>
                training.difficulty == TrainingDifficulty.intermediate,
          )
          .take(3)
          .toList();
    } else {
      // Deneyimli kullanıcılar için ileri seviye
      return _availableTrainings
          .where(
            (training) => training.difficulty == TrainingDifficulty.advanced,
          )
          .take(3)
          .toList();
    }
  }

  // Arama yap
  List<TrainingModel> searchTrainings(String query) {
    if (query.isEmpty) return _availableTrainings;

    final lowercaseQuery = query.toLowerCase();
    return _availableTrainings
        .where(
          (training) =>
              training.title.toLowerCase().contains(lowercaseQuery) ||
              training.description.toLowerCase().contains(lowercaseQuery) ||
              training.tags.any(
                (tag) => tag.toLowerCase().contains(lowercaseQuery),
              ),
        )
        .toList();
  }

  // İstatistikleri al
  Map<String, dynamic> getUserTrainingStats() {
    final completed = getCompletedTrainings();
    final inProgress = getInProgressTrainings();

    int totalTimeSpent = 0;
    for (final progress in completed) {
      if (progress.completedAt != null) {
        totalTimeSpent += progress.completedAt!
            .difference(progress.startedAt)
            .inMinutes;
      }
    }

    return {
      'totalTrainings': _userProgress.length,
      'completedTrainings': completed.length,
      'inProgressTrainings': inProgress.length,
      'totalTimeSpent': totalTimeSpent, // dakika
      'averageProgress': _userProgress.isNotEmpty
          ? _userProgress
                    .map((p) => p.progressPercentage)
                    .reduce((a, b) => a + b) /
                _userProgress.length
          : 0.0,
      'streakDays': _calculateStreakDays(),
    };
  }

  // Günlük eğitim streak'i hesapla
  int _calculateStreakDays() {
    if (_userProgress.isEmpty) return 0;

    final sortedProgress =
        _userProgress.where((p) => p.lastAccessedAt != null).toList()
          ..sort((a, b) => b.lastAccessedAt.compareTo(a.lastAccessedAt));

    int streak = 0;
    DateTime? lastDate;

    for (final progress in sortedProgress) {
      final date = DateTime(
        progress.lastAccessedAt.year,
        progress.lastAccessedAt.month,
        progress.lastAccessedAt.day,
      );

      if (lastDate == null) {
        lastDate = date;
        streak = 1;
      } else {
        final difference = lastDate.difference(date).inDays;
        if (difference == 1) {
          streak++;
          lastDate = date;
        } else if (difference > 1) {
          break;
        }
      }
    }

    return streak;
  }

  // Helper methods
  void _setStatus(TrainingProviderStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = TrainingProviderStatus.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sıfırla
  void reset() {
    _status = TrainingProviderStatus.initial;
    _currentTraining = null;
    _currentProgress = null;
    _errorMessage = null;
    notifyListeners();
  }
}
