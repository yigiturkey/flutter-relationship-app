import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import '../models/relationship_analysis_model.dart';
import '../services/firebase_service.dart';
import '../services/openai_service.dart';
import '../services/analytics_service.dart';

enum RelationshipProviderStatus {
  initial,
  loading,
  ready,
  processing,
  completed,
  error,
}

class RelationshipProvider extends ChangeNotifier {
  RelationshipProviderStatus _status = RelationshipProviderStatus.initial;
  List<RelationshipAnalysisModel> _userAnalyses = [];
  List<HoroscopeCompatibilityModel> _horoscopeAnalyses = [];
  List<WhatsAppAnalysisModel> _whatsappAnalyses = [];
  List<SocialMediaAnalysisModel> _socialMediaAnalyses = [];
  List<PersonalityProfileModel> _personalityProfiles = [];
  RelationshipAnalysisModel? _currentAnalysis;
  String? _errorMessage;
  bool _isProcessing = false;

  // Getters
  RelationshipProviderStatus get status => _status;
  List<RelationshipAnalysisModel> get userAnalyses => _userAnalyses;
  List<HoroscopeCompatibilityModel> get horoscopeAnalyses => _horoscopeAnalyses;
  List<WhatsAppAnalysisModel> get whatsappAnalyses => _whatsappAnalyses;
  List<SocialMediaAnalysisModel> get socialMediaAnalyses => _socialMediaAnalyses;
  List<PersonalityProfileModel> get personalityProfiles => _personalityProfiles;
  RelationshipAnalysisModel? get currentAnalysis => _currentAnalysis;
  String? get errorMessage => _errorMessage;
  bool get isProcessing => _isProcessing;
  bool get isLoading => _status == RelationshipProviderStatus.loading;

  // Kullanıcının tüm analizlerini yükle
  Future<void> loadUserAnalyses(String userId) async {
    try {
      _setStatus(RelationshipProviderStatus.loading);

      final query = await FirebaseService.firestore
          .collection('relationship_analyses')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _userAnalyses = query.docs
          .map((doc) => RelationshipAnalysisModel.fromFirestore(doc))
          .toList();

      _setStatus(RelationshipProviderStatus.ready);
      _clearError();
    } catch (e) {
      _setError('Analizler yüklenemedi: $e');
    }
  }

  // Burç uyumluluğu analizi yap
  Future<bool> analyzeHoroscopeCompatibility({
    required String userId,
    required String sign1,
    required String sign2,
    required DateTime birthDate1,
    required DateTime birthDate2,
  }) async {
    try {
      _setProcessing(true);

      // OpenAI ile analiz yap
      final results = await OpenAIService.analyzeHoroscopeCompatibility(
        sign1,
        sign2,
        birthDate1,
        birthDate2,
      );

      // Analiz modeli oluştur
      final analysis = RelationshipAnalysisModel(
        id: '',
        userId: userId,
        type: AnalysisType.horoscopeCompatibility,
        status: AnalysisStatus.completed,
        title: '$sign1 & $sign2 Burç Uyumluluğu',
        inputData: {
          'sign1': sign1,
          'sign2': sign2,
          'birthDate1': birthDate1.toIso8601String(),
          'birthDate2': birthDate2.toIso8601String(),
        },
        results: results,
        overallScore: results['compatibility_score']?.toDouble(),
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      // Firebase'e kaydet
      final docRef = await FirebaseService.firestore
          .collection('relationship_analyses')
          .add(analysis.toFirestore());

      _currentAnalysis = analysis.copyWith(id: docRef.id);
      _userAnalyses.insert(0, _currentAnalysis!);

      // Horoscope modeli de oluştur
      final horoscopeModel = HoroscopeCompatibilityModel(
        id: '',
        userId: userId,
        sign1: sign1,
        sign2: sign2,
        birthDate1: birthDate1,
        birthDate2: birthDate2,
        compatibilityResults: results,
        overallScore: (results['compatibility_score'] ?? 0).toInt(),
        createdAt: DateTime.now(),
      );

      final horoscopeDocRef = await FirebaseService.firestore
          .collection('horoscope_compatibility')
          .add(horoscopeModel.toFirestore());

      _horoscopeAnalyses.insert(0, horoscopeModel.copyWith(id: horoscopeDocRef.id));

      await AnalyticsService.trackUserAction(
        action: 'horoscope_analysis_completed',
        parameters: {
          'sign1': sign1,
          'sign2': sign2,
          'compatibility_score': results['compatibility_score'],
        },
      );

      _setProcessing(false);
      return true;
    } catch (e) {
      _setProcessing(false);
      _setError('Burç uyumluluğu analizi yapılamadı: $e');
      return false;
    }
  }

  // WhatsApp konuşma analizi
  Future<bool> analyzeWhatsAppConversation({
    required String userId,
    required String conversationTitle,
    required String conversationText,
    List<Uint8List>? imageFiles,
  }) async {
    try {
      _setProcessing(true);

      List<String> imageDescriptions = [];
      
      // Eğer resim varsa, önce onları açıkla
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (final imageFile in imageFiles) {
          final description = await OpenAIService.describeImage(imageFile);
          imageDescriptions.add(description);
        }
      }

      // WhatsApp analizi yap
      final results = await OpenAIService.analyzeWhatsAppConversation(conversationText);

      // Analiz modeli oluştur
      final analysis = RelationshipAnalysisModel(
        id: '',
        userId: userId,
        type: AnalysisType.whatsappConversation,
        status: AnalysisStatus.completed,
        title: conversationTitle,
        inputData: {
          'conversationText': conversationText,
          'imageDescriptions': imageDescriptions,
        },
        results: results,
        overallScore: results['overall_score']?.toDouble(),
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      final docRef = await FirebaseService.firestore
          .collection('relationship_analyses')
          .add(analysis.toFirestore());

      _currentAnalysis = analysis.copyWith(id: docRef.id);
      _userAnalyses.insert(0, _currentAnalysis!);

      // WhatsApp modeli de oluştur
      final whatsappModel = WhatsAppAnalysisModel(
        id: '',
        userId: userId,
        conversationTitle: conversationTitle,
        conversationText: conversationText,
        analysisResults: results,
        insights: (results['recommendations'] as List?)?.cast<String>() ?? [],
        createdAt: DateTime.now(),
      );

      final whatsappDocRef = await FirebaseService.firestore
          .collection('whatsapp_analyses')
          .add(whatsappModel.toFirestore());

      _whatsappAnalyses.insert(0, whatsappModel.copyWith(id: whatsappDocRef.id));

      await AnalyticsService.trackUserAction(
        action: 'whatsapp_analysis_completed',
        parameters: {
          'text_length': conversationText.length,
          'image_count': imageFiles?.length ?? 0,
          'overall_score': results['overall_score'],
        },
      );

      _setProcessing(false);
      return true;
    } catch (e) {
      _setProcessing(false);
      _setError('WhatsApp analizi yapılamadı: $e');
      return false;
    }
  }

  // Sosyal medya analizi
  Future<bool> analyzeSocialMediaContent({
    required String userId,
    required String platform,
    required String description,
    List<Uint8List>? imageFiles,
  }) async {
    try {
      _setProcessing(true);

      List<String> imageDescriptions = [];
      
      // Resimleri açıkla
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (final imageFile in imageFiles) {
          final imageDescription = await OpenAIService.describeImage(imageFile);
          imageDescriptions.add(imageDescription);
        }
      }

      // Sosyal medya analizi yap
      final results = await OpenAIService.analyzeSocialMediaContent(
        description,
        imageDescriptions,
      );

      // Analiz modeli oluştur
      final analysis = RelationshipAnalysisModel(
        id: '',
        userId: userId,
        type: AnalysisType.socialMediaContent,
        status: AnalysisStatus.completed,
        title: '$platform Sosyal Medya Analizi',
        inputData: {
          'platform': platform,
          'description': description,
          'imageDescriptions': imageDescriptions,
        },
        results: results,
        overallScore: results['overall_score']?.toDouble(),
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      final docRef = await FirebaseService.firestore
          .collection('relationship_analyses')
          .add(analysis.toFirestore());

      _currentAnalysis = analysis.copyWith(id: docRef.id);
      _userAnalyses.insert(0, _currentAnalysis!);

      // Sosyal medya modeli de oluştur
      final socialMediaModel = SocialMediaAnalysisModel(
        id: '',
        userId: userId,
        platform: platform,
        description: description,
        analysisResults: results,
        relationshipInsights: (results['recommendations'] as List?)?.cast<String>() ?? [],
        createdAt: DateTime.now(),
      );

      final socialMediaDocRef = await FirebaseService.firestore
          .collection('social_media_analyses')
          .add(socialMediaModel.toFirestore());

      _socialMediaAnalyses.insert(0, socialMediaModel.copyWith(id: socialMediaDocRef.id));

      await AnalyticsService.trackUserAction(
        action: 'social_media_analysis_completed',
        parameters: {
          'platform': platform,
          'image_count': imageFiles?.length ?? 0,
          'overall_score': results['overall_score'],
        },
      );

      _setProcessing(false);
      return true;
    } catch (e) {
      _setProcessing(false);
      _setError('Sosyal medya analizi yapılamadı: $e');
      return false;
    }
  }

  // Kişilik analizi
  Future<bool> analyzePersonality({
    required String userId,
    required String profileName,
    required String description,
    required Map<String, dynamic> personalityTraits,
  }) async {
    try {
      _setProcessing(true);

      // Kişilik analizi yap
      final results = await OpenAIService.analyzePersonDescription(
        description,
        personalityTraits,
      );

      // Analiz modeli oluştur
      final analysis = RelationshipAnalysisModel(
        id: '',
        userId: userId,
        type: AnalysisType.personalityAnalysis,
        status: AnalysisStatus.completed,
        title: '$profileName Kişilik Analizi',
        inputData: {
          'profileName': profileName,
          'description': description,
          'personalityTraits': personalityTraits,
        },
        results: results,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      final docRef = await FirebaseService.firestore
          .collection('relationship_analyses')
          .add(analysis.toFirestore());

      _currentAnalysis = analysis.copyWith(id: docRef.id);
      _userAnalyses.insert(0, _currentAnalysis!);

      // Kişilik profili modeli oluştur
      final personalityProfile = PersonalityProfileModel(
        id: '',
        userId: userId,
        profileName: profileName,
        description: description,
        personalityTraits: personalityTraits,
        analysisResults: results,
        personalityType: results['personality_type'] ?? '',
        strengths: (results['strengths'] as List?)?.cast<String>() ?? [],
        weaknesses: (results['weaknesses'] as List?)?.cast<String>() ?? [],
        compatibleTypes: (results['compatibility_with'] as List?)?.cast<String>() ?? [],
        createdAt: DateTime.now(),
      );

      final personalityDocRef = await FirebaseService.firestore
          .collection('personality_profiles')
          .add(personalityProfile.toFirestore());

      _personalityProfiles.insert(0, personalityProfile.copyWith(id: personalityDocRef.id));

      await AnalyticsService.trackUserAction(
        action: 'personality_analysis_completed',
        parameters: {
          'personality_type': results['personality_type'],
          'profile_name': profileName,
        },
      );

      _setProcessing(false);
      return true;
    } catch (e) {
      _setProcessing(false);
      _setError('Kişilik analizi yapılamadı: $e');
      return false;
    }
  }

  // Anlık soru-cevap analizi
  Future<bool> createInstantAnalysis({
    required String userId,
    required String question,
    String? context,
  }) async {
    try {
      _setProcessing(true);

      // OpenAI ile soru yanıtla
      final answer = await OpenAIService.askRelationshipQuestion(
        question,
        context != null ? {'context': context} : null,
      );

      // Analiz modeli oluştur
      final analysis = RelationshipAnalysisModel(
        id: '',
        userId: userId,
        type: AnalysisType.relationshipAssessment,
        status: AnalysisStatus.completed,
        title: 'Anlık İlişki Analizi',
        inputData: {
          'question': question,
          'context': context ?? '',
        },
        results: {
          'answer': answer,
          'question': question,
          'context': context,
        },
        recommendations: [answer],
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      final docRef = await FirebaseService.firestore
          .collection('relationship_analyses')
          .add(analysis.toFirestore());

      _currentAnalysis = analysis.copyWith(id: docRef.id);
      _userAnalyses.insert(0, _currentAnalysis!);

      await AnalyticsService.trackUserAction(
        action: 'instant_analysis_completed',
        parameters: {
          'question_length': question.length,
          'has_context': context != null && context.isNotEmpty,
        },
      );

      _setProcessing(false);
      return true;
    } catch (e) {
      _setProcessing(false);
      _setError('Anlık analiz yapılamadı: $e');
      return false;
    }
  }

  // Gelecek raporu oluştur
  Future<bool> generateFutureReport({
    required String userId,
    required Map<String, dynamic> currentAnalysis,
    List<Map<String, dynamic>>? historicalData,
  }) async {
    try {
      _setProcessing(true);

      final futureReport = await OpenAIService.predictRelationshipFuture(
        currentAnalysis,
        historicalData ?? [],
      );

      // Gelecek raporu analizi oluştur
      final analysis = RelationshipAnalysisModel(
        id: '',
        userId: userId,
        type: AnalysisType.futureReport,
        status: AnalysisStatus.completed,
        title: 'İlişki Gelecek Raporu',
        inputData: {
          'currentAnalysis': currentAnalysis,
          'historicalData': historicalData ?? [],
        },
        results: {
          'future_prediction': futureReport,
          'confidence_level': 'high',
        },
        recommendations: [futureReport],
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      final docRef = await FirebaseService.firestore
          .collection('relationship_analyses')
          .add(analysis.toFirestore());

      _currentAnalysis = analysis.copyWith(id: docRef.id);
      _userAnalyses.insert(0, _currentAnalysis!);

      await AnalyticsService.trackUserAction(
        action: 'future_report_generated',
        parameters: {
          'historical_data_count': historicalData?.length ?? 0,
        },
      );

      _setProcessing(false);
      return true;
    } catch (e) {
      _setProcessing(false);
      _setError('Gelecek raporu oluşturulamadı: $e');
      return false;
    }
  }

  // Analiz sil
  Future<bool> deleteAnalysis(String analysisId) async {
    try {
      await FirebaseService.firestore
          .collection('relationship_analyses')
          .doc(analysisId)
          .delete();

      _userAnalyses.removeWhere((analysis) => analysis.id == analysisId);
      
      if (_currentAnalysis?.id == analysisId) {
        _currentAnalysis = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Analiz silinemedi: $e');
      return false;
    }
  }

  // Burç uyumluluğu geçmişini yükle
  Future<void> loadHoroscopeAnalyses(String userId) async {
    try {
      final query = await FirebaseService.firestore
          .collection('horoscope_compatibility')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _horoscopeAnalyses = query.docs
          .map((doc) => HoroscopeCompatibilityModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Burç analizleri yüklenemedi: $e');
    }
  }

  // İstatistikleri al
  Map<String, dynamic> getAnalysisStats() {
    final totalAnalyses = _userAnalyses.length;
    final completedAnalyses = _userAnalyses
        .where((analysis) => analysis.status == AnalysisStatus.completed)
        .length;
    
    final averageScore = _userAnalyses
        .where((analysis) => analysis.overallScore != null)
        .map((analysis) => analysis.overallScore!)
        .fold(0.0, (sum, score) => sum + score) / 
        (_userAnalyses.where((analysis) => analysis.overallScore != null).length.clamp(1, double.infinity));

    final analysisTypes = <String, int>{};
    for (final analysis in _userAnalyses) {
      final type = analysis.type.toString().split('.').last;
      analysisTypes[type] = (analysisTypes[type] ?? 0) + 1;
    }

    return {
      'totalAnalyses': totalAnalyses,
      'completedAnalyses': completedAnalyses,
      'averageScore': averageScore.isNaN ? 0.0 : averageScore,
      'analysisTypes': analysisTypes,
      'horoscopeAnalyses': _horoscopeAnalyses.length,
      'whatsappAnalyses': _whatsappAnalyses.length,
      'socialMediaAnalyses': _socialMediaAnalyses.length,
      'personalityProfiles': _personalityProfiles.length,
    };
  }

  // Helper methods
  void _setStatus(RelationshipProviderStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = RelationshipProviderStatus.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sıfırla
  void reset() {
    _status = RelationshipProviderStatus.initial;
    _userAnalyses.clear();
    _horoscopeAnalyses.clear();
    _whatsappAnalyses.clear();
    _socialMediaAnalyses.clear();
    _personalityProfiles.clear();
    _currentAnalysis = null;
    _errorMessage = null;
    _isProcessing = false;
    notifyListeners();
  }
}