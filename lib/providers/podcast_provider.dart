import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/podcast_model.dart';
import '../models/firebase_collections.dart';
import 'auth_provider.dart';

class PodcastProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<PodcastModel> _podcasts = [];
  PodcastModel? _currentPodcast;
  Map<String, PodcastPlayHistory> _playHistories = {};
  bool _isLoading = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  DateTime? _lastHistoryUpdate;

  PodcastProvider(this._authProvider) {
    _initializePlayer();
  }

  // Getters
  List<PodcastModel> get podcasts => _podcasts;
  PodcastModel? get currentPodcast => _currentPodcast;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get progress => _duration.inMilliseconds > 0 
      ? _position.inMilliseconds / _duration.inMilliseconds 
      : 0.0;

  void _initializePlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    // Throttle position updates to reduce Firestore writes
    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
      
      // Only update history every 30 seconds or on first play
      final now = DateTime.now();
      if (_lastHistoryUpdate == null || 
          now.difference(_lastHistoryUpdate!).inSeconds >= 30) {
        _updatePlayHistory();
        _lastHistoryUpdate = now;
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });
  }

  Future<void> loadPodcasts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.podcasts)
          .where('status', isEqualTo: 'published')
          .orderBy('publishedAt', descending: true)
          .get();

      _podcasts = snapshot.docs
          .map((doc) => PodcastModel.fromFirestore(doc))
          .toList();

      await _loadPlayHistories();
    } catch (e) {
      print('Podcast yükleme hatası: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPlayHistories() async {
    if (_authProvider.currentUser == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.podcasts)
          .doc('play_histories')
          .collection(_authProvider.currentUser!.uid)
          .get();

      _playHistories = Map.fromEntries(
        snapshot.docs.map((doc) => MapEntry(
          doc.id,
          PodcastPlayHistory.fromFirestore(doc),
        )),
      );
    } catch (e) {
      print('Dinleme geçmişi yükleme hatası: $e');
    }
  }

  Future<void> playPodcast(PodcastModel podcast) async {
    try {
      _currentPodcast = podcast;
      
      // Load audio from Firebase URL
      await _audioPlayer.setUrl(podcast.audioUrl);
      
      // Resume from saved position if exists
      final history = _playHistories[podcast.id];
      if (history != null && !history.isCompleted) {
        await _audioPlayer.seek(Duration(seconds: history.currentPosition));
      }
      
      await _audioPlayer.play();
      
      // Create or update play history
      await _createOrUpdatePlayHistory(podcast);
      
      notifyListeners();
    } catch (e) {
      print('Podcast oynatma hatası: $e');
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    await _updatePlayHistory(); // Always update on pause
    _lastHistoryUpdate = DateTime.now();
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentPodcast = null;
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    await _updatePlayHistory();
  }

  Future<void> _createOrUpdatePlayHistory(PodcastModel podcast) async {
    if (_authProvider.currentUser == null) return;

    final now = DateTime.now();
    final history = PodcastPlayHistory(
      id: podcast.id,
      userId: _authProvider.currentUser!.uid,
      podcastId: podcast.id,
      currentPosition: 0,
      totalDuration: podcast.duration,
      isCompleted: false,
      startedAt: _playHistories[podcast.id]?.startedAt ?? now,
      lastPlayedAt: now,
    );

    _playHistories[podcast.id] = history;

    try {
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.podcasts)
          .doc('play_histories')
          .collection(_authProvider.currentUser!.uid)
          .doc(podcast.id)
          .set(history.toFirestore());
    } catch (e) {
      print('Dinleme geçmişi kaydetme hatası: $e');
    }
  }

  Future<void> _updatePlayHistory() async {
    if (_currentPodcast == null || _authProvider.currentUser == null) return;

    final history = _playHistories[_currentPodcast!.id];
    if (history == null) return;

    final currentSeconds = _position.inSeconds;
    final totalSeconds = _duration.inSeconds;
    final isCompleted = totalSeconds > 0 && currentSeconds >= totalSeconds * 0.9;

    final updatedHistory = history.copyWith(
      currentPosition: currentSeconds,
      lastPlayedAt: DateTime.now(),
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
    );

    _playHistories[_currentPodcast!.id] = updatedHistory;

    try {
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.podcasts)
          .doc('play_histories')
          .collection(_authProvider.currentUser!.uid)
          .doc(_currentPodcast!.id)
          .update(updatedHistory.toFirestore());
    } catch (e) {
      print('Dinleme geçmişi güncelleme hatası: $e');
    }
  }

  double getProgress(String podcastId) {
    final history = _playHistories[podcastId];
    if (history == null) return 0.0;
    return history.progressPercentage;
  }

  int getCurrentPosition(String podcastId) {
    final history = _playHistories[podcastId];
    return history?.currentPosition ?? 0;
  }

  bool isCompleted(String podcastId) {
    final history = _playHistories[podcastId];
    return history?.isCompleted ?? false;
  }

  Future<void> markAsCompleted(String podcastId) async {
    final history = _playHistories[podcastId];
    if (history == null) return;

    final updatedHistory = history.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
      currentPosition: history.totalDuration,
    );

    _playHistories[podcastId] = updatedHistory;

    if (_authProvider.currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection(FirebaseCollections.podcasts)
            .doc('play_histories')
            .collection(_authProvider.currentUser!.uid)
            .doc(podcastId)
            .update(updatedHistory.toFirestore());
      } catch (e) {
        print('Tamamlanma durumu kaydetme hatası: $e');
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}