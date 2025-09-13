import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analysis_model.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/analytics_service.dart';

enum AnalysisProviderStatus {
  initial,
  loading,
  questionsReady,
  analyzing,
  completed,
  error,
}

class AnalysisProvider extends ChangeNotifier {
  AnalysisProviderStatus _status = AnalysisProviderStatus.initial;
  AnalysisModel? _currentAnalysis;
  List<AnalysisQuestion> _questions = [];
  Map<String, dynamic> _answers = {};
  String? _errorMessage;
  List<AnalysisModel> _userAnalyses = [];
  bool _isLoadingHistory = false;

  // Getters
  AnalysisProviderStatus get status => _status;
  AnalysisModel? get currentAnalysis => _currentAnalysis;
  List<AnalysisQuestion> get questions => _questions;
  Map<String, dynamic> get answers => _answers;
  String? get errorMessage => _errorMessage;
  List<AnalysisModel> get userAnalyses => _userAnalyses;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isLoading => _status == AnalysisProviderStatus.loading || _status == AnalysisProviderStatus.analyzing;
  double get progressPercentage => _questions.isEmpty ? 0 : (_answers.length / _questions.length) * 100;

  // Analiz başlat
  Future<bool> startAnalysis({
    required String userId,
    required AnalysisType type,
    String? partnerId,
  }) async {
    try {
      _setStatus(AnalysisProviderStatus.loading);
      
      // Soruları yükle
      await _loadQuestions(type);
      
      if (_questions.isEmpty) {
        _setError('Analiz soruları yüklenemedi');
        return false;
      }

      // Yeni analiz oluştur
      _currentAnalysis = AnalysisModel(
        id: '', // Firestore otomatik ID verecek
        userId: userId,
        type: type,
        status: AnalysisStatus.pending,
        questions: _questionsToMap(),
        answers: {},
        createdAt: DateTime.now(),
        partnerId: partnerId,
        tokenCost: _calculateTokenCost(type),
      );

      _answers.clear();
      _setStatus(AnalysisProviderStatus.questionsReady);
      
      await AnalyticsService.trackUserAction(
        action: 'analysis_started',
        parameters: {
          'type': type.toString().split('.').last,
          'hasPartner': partnerId != null,
        },
      );
      
      return true;
    } catch (e) {
      _setError('Analiz başlatılamadı: $e');
      return false;
    }
  }

  // Soru cevapla
  void answerQuestion(String questionId, dynamic answer) {
    _answers[questionId] = answer;
    notifyListeners();
  }

  // Analize gönder
  Future<bool> submitAnalysis() async {
    if (_currentAnalysis == null) return false;
    
    try {
      _setStatus(AnalysisProviderStatus.analyzing);
      
      // Cevapları güncelle
      final updatedAnalysis = _currentAnalysis!.copyWith(
        answers: _answers,
        status: AnalysisStatus.processing,
      );
      
      // Firestore'a kaydet
      final docRef = await FirebaseService.analyses.add(updatedAnalysis.toFirestore());
      
      // ID'yi güncelle
      _currentAnalysis = updatedAnalysis.copyWith();
      
      // Analiz sonucunu hesapla (simülasyon)
      await _processAnalysis(docRef.id);
      
      await AnalyticsService.trackAnalysisCompleted(
        analysisId: docRef.id,
        analysisType: _currentAnalysis!.type.toString().split('.').last,
        score: _currentAnalysis!.result?.compatibilityScore ?? 0,
        timeSpent: DateTime.now().difference(_currentAnalysis!.createdAt).inSeconds,
      );
      
      return true;
    } catch (e) {
      _setError('Analiz gönderilirken hata: $e');
      return false;
    }
  }

  // Kullanıcının analiz geçmişini yükle
  Future<void> loadUserAnalyses(String userId) async {
    try {
      _isLoadingHistory = true;
      notifyListeners();
      
      final query = await FirebaseService.analyses
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      
      _userAnalyses = query.docs
          .map((doc) => AnalysisModel.fromFirestore(doc))
          .toList();
      
    } catch (e) {
      _setError('Analiz geçmişi yüklenemedi: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // Belirli bir analizi getir
  Future<AnalysisModel?> getAnalysis(String analysisId) async {
    try {
      final doc = await FirebaseService.analyses.doc(analysisId).get();
      if (doc.exists) {
        return AnalysisModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _setError('Analiz getirilemedi: $e');
      return null;
    }
  }

  // Çift modu için partner analizi ile karşılaştır
  Future<AnalysisResult?> compareWithPartner(String analysisId, String partnerAnalysisId) async {
    try {
      _setStatus(AnalysisProviderStatus.analyzing);
      
      // Her iki analizi de getir
      final analysis1 = await getAnalysis(analysisId);
      final analysis2 = await getAnalysis(partnerAnalysisId);
      
      if (analysis1 == null || analysis2 == null) {
        _setError('Analiz verisi bulunamadı');
        return null;
      }
      
      // Karşılaştırma analizi yap (simülasyon)
      final comparisonResult = _generateComparisonResult(analysis1, analysis2);
      
      _setStatus(AnalysisProviderStatus.completed);
      return comparisonResult;
    } catch (e) {
      _setError('Karşılaştırma analizi hatası: $e');
      return null;
    }
  }

  // Soruları yükle
  Future<void> _loadQuestions(AnalysisType type) async {
    try {
      // Gerçek uygulamada Firestore'dan yüklenecek
      // Bu örnekte sabit sorular kullanıyoruz
      _questions = _getQuestionsForType(type);
    } catch (e) {
      throw Exception('Sorular yüklenemedi: $e');
    }
  }

  // Analizi işle (simülasyon)
  Future<void> _processAnalysis(String analysisId) async {
    try {
      // Simülasyon: 2 saniye bekle
      await Future.delayed(const Duration(seconds: 2));
      
      // Sonuç oluştur
      final result = _generateAnalysisResult();
      
      // Analizi güncelle
      _currentAnalysis = _currentAnalysis!.copyWith(
        status: AnalysisStatus.completed,
        result: result,
        completedAt: DateTime.now(),
      );
      
      // Firestore'da güncelle
      await FirebaseService.analyses.doc(analysisId).update({
        'status': AnalysisStatus.completed.toString().split('.').last,
        'result': result.toMap(),
        'completedAt': FieldValue.serverTimestamp(),
      });
      
      _setStatus(AnalysisProviderStatus.completed);
    } catch (e) {
      _setError('Analiz işlenirken hata: $e');
    }
  }

  // Analiz sonucu oluştur (simülasyon)
  AnalysisResult _generateAnalysisResult() {
    // Cevaplara göre basit bir skor hesaplama
    double totalScore = 0;
    final categoryScores = <String, double>{};
    
    // Her kategori için skor hesapla
    final categories = ['iletişim', 'empati', 'uyumluluk', 'güven', 'bağlılık'];
    for (final category in categories) {
      final score = 60 + (DateTime.now().millisecond % 40); // 60-100 arası rastgele
      categoryScores[category] = score.toDouble();
      totalScore += score;
    }
    
    final averageScore = totalScore / categories.length;
    
    return AnalysisResult(
      compatibilityScore: averageScore,
      categoryScores: categoryScores,
      strengths: _generateStrengths(categoryScores),
      improvementAreas: _generateImprovementAreas(categoryScores),
      recommendations: _generateRecommendations(categoryScores),
      summary: _generateSummary(averageScore),
      detailedInsights: {
        'totalQuestions': _questions.length,
        'answeredQuestions': _answers.length,
        'analysisDate': DateTime.now().toIso8601String(),
      },
    );
  }

  // Karşılaştırma sonucu oluştur
  AnalysisResult _generateComparisonResult(AnalysisModel analysis1, AnalysisModel analysis2) {
    // Basit karşılaştırma algoritması
    final result1 = analysis1.result!;
    final result2 = analysis2.result!;
    
    final combinedScore = (result1.compatibilityScore + result2.compatibilityScore) / 2;
    final combinedCategories = <String, double>{};
    
    for (final category in result1.categoryScores.keys) {
      combinedCategories[category] = 
          (result1.categoryScores[category]! + (result2.categoryScores[category] ?? 0)) / 2;
    }
    
    return AnalysisResult(
      compatibilityScore: combinedScore,
      categoryScores: combinedCategories,
      strengths: [...result1.strengths, ...result2.strengths],
      improvementAreas: _generateCoupleImprovementAreas(combinedCategories),
      recommendations: _generateCoupleRecommendations(combinedScore),
      summary: 'Çift olarak uyumluluk skorunuz: ${combinedScore.toStringAsFixed(1)}',
      detailedInsights: {
        'analysisType': 'couple_comparison',
        'partner1Score': result1.compatibilityScore,
        'partner2Score': result2.compatibilityScore,
        'combinedScore': combinedScore,
      },
    );
  }

  // Tip için sorular (simülasyon)
  List<AnalysisQuestion> _getQuestionsForType(AnalysisType type) {
    switch (type) {
      case AnalysisType.instant:
        return [
          AnalysisQuestion(
            id: 'q1',
            text: 'İlişkinizde iletişimi nasıl değerlendiriyorsunuz?',
            type: AnalysisQuestionType.scale,
            minValue: 1,
            maxValue: 10,
            category: 'iletişim',
          ),
          AnalysisQuestion(
            id: 'q2',
            text: 'Partnerinizin duygularını ne kadar iyi anlayabiliyorsunuz?',
            type: AnalysisQuestionType.scale,
            minValue: 1,
            maxValue: 10,
            category: 'empati',
          ),
        ];
      case AnalysisType.general:
        return [
          AnalysisQuestion(
            id: 'g1',
            text: 'İlişkinizde en önemli değer hangisidir?',
            type: AnalysisQuestionType.multipleChoice,
            options: ['Güven', 'Saygı', 'Sevgi', 'Sadakat', 'Anlayış'],
            category: 'değerler',
          ),
          AnalysisQuestion(
            id: 'g2',
            text: 'Çatışma durumlarında nasıl davranırsınız?',
            type: AnalysisQuestionType.multipleChoice,
            options: ['Sakin kalırım', 'Tartışırım', 'Çekilirim', 'Uzlaşma ararım'],
            category: 'çatışma',
          ),
        ];
      default:
        return [];
    }
  }

  // Helper methods
  Map<String, dynamic> _questionsToMap() {
    final map = <String, dynamic>{};
    for (final question in _questions) {
      map[question.id] = question.toMap();
    }
    return map;
  }

  int _calculateTokenCost(AnalysisType type) {
    switch (type) {
      case AnalysisType.instant:
        return 0; // Ücretsiz
      case AnalysisType.general:
        return 10;
      case AnalysisType.couple:
        return 20;
      case AnalysisType.future:
        return 30;
    }
  }

  List<String> _generateStrengths(Map<String, double> scores) {
    final strengths = <String>[];
    scores.forEach((category, score) {
      if (score >= 80) {
        strengths.add('${category.toUpperCase()} alanında çok başarılısınız');
      }
    });
    return strengths;
  }

  List<String> _generateImprovementAreas(Map<String, double> scores) {
    final improvements = <String>[];
    scores.forEach((category, score) {
      if (score < 70) {
        improvements.add('${category.toUpperCase()} alanında gelişim fırsatı var');
      }
    });
    return improvements;
  }

  List<String> _generateRecommendations(Map<String, double> scores) {
    return [
      'Günlük 15 dakika kaliteli sohbet zamanı ayırın',
      'Duygusal zeka egzersizleri yapın',
      'Birlikte ortak hobiler keşfedin',
    ];
  }

  List<String> _generateCoupleImprovementAreas(Map<String, double> scores) {
    return [
      'Birlikte iletişim teknikleri öğrenin',
      'Çift terapisi düşünebilirsiniz',
      'Ortak hedefler belirleyin',
    ];
  }

  List<String> _generateCoupleRecommendations(double score) {
    if (score >= 80) {
      return ['İlişkiniz çok güçlü! Bu başarıyı sürdürün.'];
    } else if (score >= 60) {
      return ['İlişkinizde gelişim potansiyeli var.'];
    } else {
      return ['İlişkiniz dikkat gerektiriyor. Profesyonel destek alabilirsiniz.'];
    }
  }

  String _generateSummary(double score) {
    if (score >= 80) {
      return 'Tebrikler! İlişkiniz çok sağlıklı ve güçlü.';
    } else if (score >= 60) {
      return 'İlişkiniz genel olarak iyi durumda, bazı alanlarda gelişim fırsatı var.';
    } else {
      return 'İlişkinizde dikkat edilmesi gereken alanlar bulunuyor.';
    }
  }

  void _setStatus(AnalysisProviderStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = AnalysisProviderStatus.error;
    notifyListeners();
  }

  void reset() {
    _status = AnalysisProviderStatus.initial;
    _currentAnalysis = null;
    _questions.clear();
    _answers.clear();
    _errorMessage = null;
    notifyListeners();
  }
}