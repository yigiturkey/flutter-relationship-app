import 'package:cloud_firestore/cloud_firestore.dart';

enum AnalysisType {
  whatsappConversation,
  socialMediaContent,
  horoscopeCompatibility,
  personalityAnalysis,
  relationshipAssessment,
  futureReport,
}

enum AnalysisStatus {
  pending,
  processing,
  completed,
  failed,
}

class RelationshipAnalysisModel {
  final String id;
  final String userId;
  final AnalysisType type;
  final AnalysisStatus status;
  final String title;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic>? results;
  final List<String> recommendations;
  final double? overallScore;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int tokensCost;
  final bool isPremium;

  RelationshipAnalysisModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.title,
    required this.inputData,
    this.results,
    this.recommendations = const [],
    this.overallScore,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
    this.tokensCost = 0,
    this.isPremium = false,
  });

  factory RelationshipAnalysisModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RelationshipAnalysisModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: AnalysisType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => AnalysisType.relationshipAssessment,
      ),
      status: AnalysisStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => AnalysisStatus.pending,
      ),
      title: data['title'] ?? '',
      inputData: Map<String, dynamic>.from(data['inputData'] ?? {}),
      results: data['results'] != null ? Map<String, dynamic>.from(data['results']) : null,
      recommendations: List<String>.from(data['recommendations'] ?? []),
      overallScore: data['overallScore']?.toDouble(),
      errorMessage: data['errorMessage'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null ? (data['completedAt'] as Timestamp).toDate() : null,
      tokensCost: data['tokensCost'] ?? 0,
      isPremium: data['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'title': title,
      'inputData': inputData,
      'results': results,
      'recommendations': recommendations,
      'overallScore': overallScore,
      'errorMessage': errorMessage,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'tokensCost': tokensCost,
      'isPremium': isPremium,
    };
  }

  RelationshipAnalysisModel copyWith({
    String? id,
    String? userId,
    AnalysisType? type,
    AnalysisStatus? status,
    String? title,
    Map<String, dynamic>? inputData,
    Map<String, dynamic>? results,
    List<String>? recommendations,
    double? overallScore,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
    int? tokensCost,
    bool? isPremium,
  }) {
    return RelationshipAnalysisModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      inputData: inputData ?? this.inputData,
      results: results ?? this.results,
      recommendations: recommendations ?? this.recommendations,
      overallScore: overallScore ?? this.overallScore,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      tokensCost: tokensCost ?? this.tokensCost,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}

class HoroscopeCompatibilityModel {
  final String id;
  final String userId;
  final String sign1;
  final String sign2;
  final DateTime birthDate1;
  final DateTime birthDate2;
  final Map<String, dynamic> compatibilityResults;
  final int overallScore;
  final DateTime createdAt;

  HoroscopeCompatibilityModel({
    required this.id,
    required this.userId,
    required this.sign1,
    required this.sign2,
    required this.birthDate1,
    required this.birthDate2,
    required this.compatibilityResults,
    required this.overallScore,
    required this.createdAt,
  });

  factory HoroscopeCompatibilityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HoroscopeCompatibilityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      sign1: data['sign1'] ?? '',
      sign2: data['sign2'] ?? '',
      birthDate1: (data['birthDate1'] as Timestamp).toDate(),
      birthDate2: (data['birthDate2'] as Timestamp).toDate(),
      compatibilityResults: Map<String, dynamic>.from(data['compatibilityResults'] ?? {}),
      overallScore: data['overallScore'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'sign1': sign1,
      'sign2': sign2,
      'birthDate1': Timestamp.fromDate(birthDate1),
      'birthDate2': Timestamp.fromDate(birthDate2),
      'compatibilityResults': compatibilityResults,
      'overallScore': overallScore,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  HoroscopeCompatibilityModel copyWith({
    String? id,
    String? userId,
    String? sign1,
    String? sign2,
    DateTime? birthDate1,
    DateTime? birthDate2,
    Map<String, dynamic>? compatibilityResults,
    int? overallScore,
    DateTime? createdAt,
  }) {
    return HoroscopeCompatibilityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sign1: sign1 ?? this.sign1,
      sign2: sign2 ?? this.sign2,
      birthDate1: birthDate1 ?? this.birthDate1,
      birthDate2: birthDate2 ?? this.birthDate2,
      compatibilityResults: compatibilityResults ?? this.compatibilityResults,
      overallScore: overallScore ?? this.overallScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class WhatsAppAnalysisModel {
  final String id;
  final String userId;
  final String conversationTitle;
  final String conversationText;
  final List<String> imageUrls;
  final Map<String, dynamic> analysisResults;
  final List<String> insights;
  final DateTime createdAt;

  WhatsAppAnalysisModel({
    required this.id,
    required this.userId,
    required this.conversationTitle,
    required this.conversationText,
    this.imageUrls = const [],
    required this.analysisResults,
    this.insights = const [],
    required this.createdAt,
  });

  factory WhatsAppAnalysisModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WhatsAppAnalysisModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      conversationTitle: data['conversationTitle'] ?? '',
      conversationText: data['conversationText'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      analysisResults: Map<String, dynamic>.from(data['analysisResults'] ?? {}),
      insights: List<String>.from(data['insights'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'conversationTitle': conversationTitle,
      'conversationText': conversationText,
      'imageUrls': imageUrls,
      'analysisResults': analysisResults,
      'insights': insights,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  WhatsAppAnalysisModel copyWith({
    String? id,
    String? userId,
    String? conversationTitle,
    String? conversationText,
    List<String>? imageUrls,
    Map<String, dynamic>? analysisResults,
    List<String>? insights,
    DateTime? createdAt,
  }) {
    return WhatsAppAnalysisModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      conversationTitle: conversationTitle ?? this.conversationTitle,
      conversationText: conversationText ?? this.conversationText,
      imageUrls: imageUrls ?? this.imageUrls,
      analysisResults: analysisResults ?? this.analysisResults,
      insights: insights ?? this.insights,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SocialMediaAnalysisModel {
  final String id;
  final String userId;
  final String platform;
  final String description;
  final List<String> imageUrls;
  final Map<String, dynamic> analysisResults;
  final List<String> relationshipInsights;
  final DateTime createdAt;

  SocialMediaAnalysisModel({
    required this.id,
    required this.userId,
    required this.platform,
    required this.description,
    this.imageUrls = const [],
    required this.analysisResults,
    this.relationshipInsights = const [],
    required this.createdAt,
  });

  factory SocialMediaAnalysisModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialMediaAnalysisModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      platform: data['platform'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      analysisResults: Map<String, dynamic>.from(data['analysisResults'] ?? {}),
      relationshipInsights: List<String>.from(data['relationshipInsights'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'platform': platform,
      'description': description,
      'imageUrls': imageUrls,
      'analysisResults': analysisResults,
      'relationshipInsights': relationshipInsights,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  SocialMediaAnalysisModel copyWith({
    String? id,
    String? userId,
    String? platform,
    String? description,
    List<String>? imageUrls,
    Map<String, dynamic>? analysisResults,
    List<String>? relationshipInsights,
    DateTime? createdAt,
  }) {
    return SocialMediaAnalysisModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      platform: platform ?? this.platform,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      analysisResults: analysisResults ?? this.analysisResults,
      relationshipInsights: relationshipInsights ?? this.relationshipInsights,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PersonalityProfileModel {
  final String id;
  final String userId;
  final String profileName;
  final String description;
  final Map<String, dynamic> personalityTraits;
  final Map<String, dynamic> analysisResults;
  final String personalityType;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> compatibleTypes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PersonalityProfileModel({
    required this.id,
    required this.userId,
    required this.profileName,
    required this.description,
    required this.personalityTraits,
    required this.analysisResults,
    required this.personalityType,
    this.strengths = const [],
    this.weaknesses = const [],
    this.compatibleTypes = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory PersonalityProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PersonalityProfileModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      profileName: data['profileName'] ?? '',
      description: data['description'] ?? '',
      personalityTraits: Map<String, dynamic>.from(data['personalityTraits'] ?? {}),
      analysisResults: Map<String, dynamic>.from(data['analysisResults'] ?? {}),
      personalityType: data['personalityType'] ?? '',
      strengths: List<String>.from(data['strengths'] ?? []),
      weaknesses: List<String>.from(data['weaknesses'] ?? []),
      compatibleTypes: List<String>.from(data['compatibleTypes'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'profileName': profileName,
      'description': description,
      'personalityTraits': personalityTraits,
      'analysisResults': analysisResults,
      'personalityType': personalityType,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'compatibleTypes': compatibleTypes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  PersonalityProfileModel copyWith({
    String? id,
    String? userId,
    String? profileName,
    String? description,
    Map<String, dynamic>? personalityTraits,
    Map<String, dynamic>? analysisResults,
    String? personalityType,
    List<String>? strengths,
    List<String>? weaknesses,
    List<String>? compatibleTypes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonalityProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profileName: profileName ?? this.profileName,
      description: description ?? this.description,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      analysisResults: analysisResults ?? this.analysisResults,
      personalityType: personalityType ?? this.personalityType,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      compatibleTypes: compatibleTypes ?? this.compatibleTypes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Burç listesi
class ZodiacSign {
  static const List<String> signs = [
    'Koç',
    'Boğa', 
    'İkizler',
    'Yengeç',
    'Aslan',
    'Başak',
    'Terazi',
    'Akrep',
    'Yay',
    'Oğlak',
    'Kova',
    'Balık',
  ];

  static const Map<String, String> signDescriptions = {
    'Koç': 'Ateş elementi, lider ruh, cesaretli',
    'Boğa': 'Toprak elementi, kararlı, sebatkar',
    'İkizler': 'Hava elementi, iletişimci, çok yönlü',
    'Yengeç': 'Su elementi, duygusal, koruyucu',
    'Aslan': 'Ateş elementi, yaratıcı, gururlu',
    'Başak': 'Toprak elementi, analitik, mükemmeliyetçi',
    'Terazi': 'Hava elementi, dengeli, adalet seven',
    'Akrep': 'Su elementi, yoğun, tutkulu',
    'Yay': 'Ateş elementi, özgür, felsefi',
    'Oğlak': 'Toprak elementi, disiplinli, hedef odaklı',
    'Kova': 'Hava elementi, özgün, vizyoner',
    'Balık': 'Su elementi, hayal gücü yüksek, sezgisel',
  };

  static String getSignByDate(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Koç';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Boğa';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'İkizler';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Yengeç';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Aslan';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Başak';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Terazi';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Akrep';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Yay';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Oğlak';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Kova';
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return 'Balık';

    return 'Bilinmeyen';
  }
}