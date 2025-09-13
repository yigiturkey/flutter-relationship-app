import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_model.dart';
import '../models/firebase_collections.dart';
import '../services/openai_service.dart';
import 'auth_provider.dart';

class GameProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  final OpenAIService _openAIService;

  List<GameModel> _games = [];
  List<GameResult> _userResults = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  GameProvider(this._authProvider, this._openAIService);

  // Getters
  List<GameModel> get games => _games;
  List<GameResult> get userResults => _userResults;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;

  Future<void> loadGames() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.games)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      _games = snapshot.docs
          .map((doc) => GameModel.fromFirestore(doc))
          .toList();

      if (_authProvider.currentUser != null) {
        await _loadUserResults();
      }
    } catch (e) {
      print('Oyun yükleme hatası: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserResults() async {
    if (_authProvider.currentUser == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.gameResults)
          .where('userId', isEqualTo: _authProvider.currentUser!.uid)
          .orderBy('completedAt', descending: true)
          .get();

      _userResults = snapshot.docs
          .map((doc) => GameResult.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Oyun sonuçları yükleme hatası: $e');
    }
  }

  Future<void> submitSurveyAnswers(String gameId, Map<String, dynamic> answers) async {
    if (_authProvider.currentUser == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final game = _games.firstWhere((g) => g.id == gameId);
      
      // AI analizi için prompt oluştur
      final analysisPrompt = _buildAnalysisPrompt(game, answers);
      
      // OpenAI ile analiz yap
      final aiAnalysis = await _openAIService.analyzePersonality(analysisPrompt);
      
      // Skor hesapla
      final scores = _calculateScores(game, answers);
      final finalScore = scores.isNotEmpty 
          ? scores.values.fold(0.0, (sum, score) => sum + score) / scores.length
          : 0.0;
      
      // Kişilik tipi belirle
      final personalityType = _determinePersonalityType(game, answers, scores);
      
      // Öneriler oluştur
      final recommendations = _generateRecommendations(game, answers, scores);
      
      // Sonucu kaydet
      final result = GameResult(
        id: '',
        userId: _authProvider.currentUser!.uid,
        gameId: gameId,
        finalScore: finalScore.round(),
        percentage: finalScore / 100, // finalScore is already a percentage (0-100)
        categoryScores: scores,
        achievements: _calculateAchievements(game, scores),
        personalityType: personalityType,
        recommendations: recommendations,
        completedAt: DateTime.now(),
      );

      final docRef = await FirebaseFirestore.instance
          .collection(FirebaseCollections.gameResults)
          .add(result.toFirestore());

      // ID'yi güncelle ve listeye ekle
      final savedResult = result.copyWith(id: docRef.id);
      _userResults.insert(0, savedResult);

      // Kullanıcı istatistiklerini güncelle
      await _updateUserStats(gameId);

    } catch (e) {
      print('Anket gönderme hatası: $e');
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  String _buildAnalysisPrompt(GameModel game, Map<String, dynamic> answers) {
    final prompt = StringBuffer();
    prompt.writeln('${game.title} anketi analizi:');
    prompt.writeln('Anket türü: ${game.type.toString().split('.').last}');
    prompt.writeln('');
    prompt.writeln('Verilen cevaplar:');
    
    for (int i = 0; i < game.questions.length; i++) {
      final question = game.questions[i];
      final answer = answers[question.id];
      
      prompt.writeln('Soru ${i + 1}: ${question.text}');
      
      switch (question.type) {
        case QuestionType.multipleChoice:
          if (answer != null && question.options != null && answer < question.options!.length) {
            prompt.writeln('Cevap: ${question.options![answer]}');
          }
          break;
        case QuestionType.scale:
          prompt.writeln('Cevap: $answer/${question.scaleMax ?? 5}');
          break;
        case QuestionType.yesNo:
          prompt.writeln('Cevap: ${answer == true ? "Evet" : "Hayır"}');
          break;
        case QuestionType.openText:
          prompt.writeln('Cevap: $answer');
          break;
      }
      prompt.writeln('');
    }
    
    prompt.writeln('Lütfen bu cevaplara dayalı olarak:');
    prompt.writeln('1. Kişilik özelliklerini analiz et');
    prompt.writeln('2. Güçlü ve geliştirilmesi gereken yanları belirle');
    prompt.writeln('3. İlişkiler açısından uyumluluğu değerlendir');
    prompt.writeln('4. Pratik öneriler sun');
    prompt.writeln('5. Türkçe, empatik ve yapıcı bir dilde yaz');
    
    return prompt.toString();
  }

  Map<String, double> _calculateScores(GameModel game, Map<String, dynamic> answers) {
    final scores = <String, double>{};
    final categoryTotals = <String, double>{};
    final categoryCounts = <String, int>{};

    for (final question in game.questions) {
      final category = question.category ?? 'genel';
      final answer = answers[question.id];
      
      double questionScore = 0.0;
      
      switch (question.type) {
        case QuestionType.scale:
          final max = question.scaleMax ?? 5;
          questionScore = (answer ?? 1) / max * 100;
          break;
        case QuestionType.yesNo:
          questionScore = answer == true ? 100.0 : 0.0;
          break;
        case QuestionType.multipleChoice:
          // Basit puanlama: seçenek sırasına göre
          final optionCount = question.options?.length ?? 1;
          questionScore = (answer ?? 0) / (optionCount - 1) * 100;
          break;
        case QuestionType.openText:
          // Metin uzunluğuna göre basit puanlama
          final textLength = answer?.toString().length ?? 0;
          questionScore = (textLength > 10) ? 80.0 : 40.0;
          break;
      }
      
      categoryTotals[category] = (categoryTotals[category] ?? 0) + questionScore;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    for (final category in categoryTotals.keys) {
      final total = categoryTotals[category]!;
      final count = categoryCounts[category]!;
      scores[category] = total / count;
    }

    return scores;
  }

  String _determinePersonalityType(
    GameModel game,
    Map<String, dynamic> answers,
    Map<String, double> scores,
  ) {
    switch (game.type) {
      case GameType.personalityTest:
        return _determinePersonalityTestType(scores);
      case GameType.communicationStyle:
        return _determineCommunicationStyle(scores);
      case GameType.loveLanguage:
        return _determineLoveLanguage(scores);
      case GameType.attachmentStyle:
        return _determineAttachmentStyle(scores);
      case GameType.emotionalIntelligence:
        return _determineEILevel(scores);
      default:
        return _determineGeneralType(scores);
    }
  }

  String _determinePersonalityTestType(Map<String, double> scores) {
    final maxCategory = scores.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    ).key;
    
    final maxScore = scores[maxCategory]!;
    
    if (maxScore >= 80) return 'Güçlü $maxCategory';
    if (maxScore >= 60) return 'Orta $maxCategory';
    return 'Gelişen $maxCategory';
  }

  String _determineCommunicationStyle(Map<String, double> scores) {
    if (scores['assertive'] != null && scores['assertive']! > 70) {
      return 'Kendinden Emin İletişimci';
    } else if (scores['empathetic'] != null && scores['empathetic']! > 70) {
      return 'Empatik İletişimci';
    } else if (scores['analytical'] != null && scores['analytical']! > 70) {
      return 'Analitik İletişimci';
    }
    return 'Dengeli İletişimci';
  }

  String _determineLoveLanguage(Map<String, double> scores) {
    final maxCategory = scores.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    ).key;
    
    switch (maxCategory) {
      case 'words':
        return 'Olumlu Sözler';
      case 'touch':
        return 'Fiziksel Temas';
      case 'time':
        return 'Kaliteli Zaman';
      case 'gifts':
        return 'Hediyeler';
      case 'service':
        return 'Hizmet Etme';
      default:
        return 'Karma Stil';
    }
  }

  String _determineAttachmentStyle(Map<String, double> scores) {
    if (scores['secure'] != null && scores['secure']! > 70) {
      return 'Güvenli Bağlanma';
    } else if (scores['anxious'] != null && scores['anxious']! > 60) {
      return 'Kaygılı Bağlanma';
    } else if (scores['avoidant'] != null && scores['avoidant']! > 60) {
      return 'Kaçınan Bağlanma';
    }
    return 'Karma Bağlanma';
  }

  String _determineEILevel(Map<String, double> scores) {
    final averageScore = scores.values.fold(0.0, (sum, score) => sum + score) / scores.length;
    
    if (averageScore >= 85) return 'Yüksek Duygusal Zeka';
    if (averageScore >= 70) return 'İyi Duygusal Zeka';
    if (averageScore >= 55) return 'Orta Duygusal Zeka';
    return 'Gelişen Duygusal Zeka';
  }

  String _determineGeneralType(Map<String, double> scores) {
    final averageScore = scores.values.fold(0.0, (sum, score) => sum + score) / scores.length;
    
    if (averageScore >= 80) return 'Güçlü Profil';
    if (averageScore >= 60) return 'Dengeli Profil';
    return 'Gelişen Profil';
  }

  List<String> _generateRecommendations(
    GameModel game,
    Map<String, dynamic> answers,
    Map<String, double> scores,
  ) {
    final recommendations = <String>[];
    
    // Düşük skorlu kategoriler için öneriler
    final weakCategories = scores.entries
        .where((entry) => entry.value < 60)
        .map((entry) => entry.key)
        .toList();
    
    for (final category in weakCategories) {
      recommendations.addAll(_getCategoryRecommendations(category));
    }
    
    // Genel öneriler
    recommendations.addAll(_getGeneralRecommendations(game.type));
    
    return recommendations.take(5).toList();
  }

  List<String> _getCategoryRecommendations(String category) {
    switch (category) {
      case 'communication':
        return [
          'Aktif dinleme becerilerinizi geliştirin',
          'Empati kurma alıştırmaları yapın',
          'Açık ve net iletişim kurmaya odaklanın',
        ];
      case 'emotional':
        return [
          'Duygusal farkındalık meditasyonu yapın',
          'Duygu günlüğü tutun',
          'Stres yönetimi tekniklerini öğrenin',
        ];
      case 'social':
        return [
          'Sosyal aktivitelere katılın',
          'Yeni insanlarla tanışmaya açık olun',
          'Takım çalışması becerilerinizi geliştirin',
        ];
      default:
        return [
          'Bu alanda daha fazla pratik yapın',
          'Uzman desteği almayı düşünün',
          'Kendinize sabırlı olun ve gelişime odaklanın',
        ];
    }
  }

  List<String> _getGeneralRecommendations(GameType gameType) {
    switch (gameType) {
      case GameType.personalityTest:
        return [
          'Güçlü yanlarınızı hayatınızda daha aktif kullanın',
          'Gelişim alanlarınız için hedefler belirleyin',
        ];
      case GameType.relationshipAssessment:
        return [
          'Partnerinizle açık iletişim kurma zamanları oluşturun',
          'Birlikte kaliteli zaman geçirmeyi ihmal etmeyin',
        ];
      case GameType.communicationStyle:
        return [
          'Farklı iletişim stillerini tanımaya çalışın',
          'Karşınızdakine uygun iletişim yolları geliştirin',
        ];
      default:
        return [
          'Düzenli olarak kendinizi değerlendirin',
          'Sürekli öğrenmeye ve gelişmeye açık olun',
        ];
    }
  }

  List<String> _calculateAchievements(GameModel game, Map<String, double> scores) {
    final achievements = <String>[];
    
    final averageScore = scores.values.fold(0.0, (sum, score) => sum + score) / scores.length;
    
    if (averageScore >= 90) {
      achievements.add('Mükemmel Performans');
    } else if (averageScore >= 80) {
      achievements.add('Harika Sonuç');
    } else if (averageScore >= 70) {
      achievements.add('İyi Performans');
    }
    
    // Kategori bazlı başarılar
    for (final entry in scores.entries) {
      if (entry.value >= 85) {
        achievements.add('${entry.key} Uzmanı');
      }
    }
    
    // Oyun tipine özel başarılar
    switch (game.type) {
      case GameType.personalityTest:
        achievements.add('Kendini Tanıyan');
        break;
      case GameType.relationshipAssessment:
        achievements.add('İlişki Analisti');
        break;
      case GameType.communicationStyle:
        achievements.add('İletişim Uzmanı');
        break;
      default:
        achievements.add('Anket Tamamlayıcı');
    }
    
    return achievements;
  }

  Future<void> _updateUserStats(String gameId) async {
    if (_authProvider.currentUser == null) return;

    try {
      final userDoc = FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(_authProvider.currentUser!.uid);

      await userDoc.update({
        'stats.totalGamesPlayed': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Kullanıcı istatistikleri güncelleme hatası: $e');
    }
  }

  GameResult? getResultForGame(String gameId) {
    try {
      return _userResults.firstWhere((result) => result.gameId == gameId);
    } catch (e) {
      return null;
    }
  }

  List<GameModel> getGamesByType(GameType type) {
    return _games.where((game) => game.type == type).toList();
  }

  List<GameModel> getGamesByDifficulty(GameDifficulty difficulty) {
    return _games.where((game) => game.difficulty == difficulty).toList();
  }
}