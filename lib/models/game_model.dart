import 'package:cloud_firestore/cloud_firestore.dart';

enum GameType {
  surveyCompatibility,      // İlişki uyumluluk anketi
  personalityTest,          // Kişilik testi
  relationshipAssessment,   // İlişki değerlendirmesi
  communicationStyle,       // İletişim stili anketi
  loveLanguage,             // Aşk dili anketi
  emotionalIntelligence,    // Duygusal zeka testi
  attachmentStyle,          // Bağlanma stili anketi
}

enum GameDifficulty {
  easy,
  medium,
  hard,
}

enum GameStatus {
  notStarted,
  inProgress,
  completed,
  paused,
}

class GameModel {
  final String id;
  final String title;
  final String description;
  final GameType type;
  final GameDifficulty difficulty;
  final int estimatedDuration; // dakika cinsinden
  final String? thumbnailUrl;
  final List<SurveyQuestion> questions;
  final bool isPremium;
  final int tokenCost;
  final double rating;
  final int ratingsCount;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int maxScore;
  final Map<String, dynamic> gameRules;

  GameModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.estimatedDuration,
    this.thumbnailUrl,
    required this.questions,
    this.isPremium = false,
    this.tokenCost = 0,
    this.rating = 0.0,
    this.ratingsCount = 0,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
    required this.maxScore,
    required this.gameRules,
  });

  factory GameModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: GameType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => GameType.surveyCompatibility,
      ),
      difficulty: GameDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == data['difficulty'],
        orElse: () => GameDifficulty.easy,
      ),
      estimatedDuration: data['estimatedDuration'] ?? 0,
      thumbnailUrl: data['thumbnailUrl'],
      questions: (data['questions'] as List<dynamic>?)
          ?.map((question) => SurveyQuestion.fromMap(question))
          .toList() ?? [],
      isPremium: data['isPremium'] ?? false,
      tokenCost: data['tokenCost'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      ratingsCount: data['ratingsCount'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      maxScore: data['maxScore'] ?? 100,
      gameRules: Map<String, dynamic>.from(data['gameRules'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'estimatedDuration': estimatedDuration,
      'thumbnailUrl': thumbnailUrl,
      'questions': questions.map((question) => question.toMap()).toList(),
      'isPremium': isPremium,
      'tokenCost': tokenCost,
      'rating': rating,
      'ratingsCount': ratingsCount,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'maxScore': maxScore,
      'gameRules': gameRules,
    };
  }
}

enum QuestionType {
  multipleChoice,    // Çoktan seçmeli
  scale,            // 1-5 skala
  yesNo,            // Evet/Hayır
  openText,         // Serbest metin
}

class SurveyQuestion {
  final String id;
  final String text;
  final QuestionType type;
  final List<String>? options;          // Çoktan seçmeli için seçenekler
  final int? scaleMin;                  // Skala minimum değeri (örn: 1)
  final int? scaleMax;                  // Skala maksimum değeri (örn: 5)
  final List<String>? scaleLabels;      // Skala etiketleri ["Hiç", "Az", "Orta", "Çok", "Aşırı"]
  final String? category;               // Soru kategorisi (iletişim, duygusal vb.)
  final int order;                      // Soru sırası
  final bool isRequired;                // Zorunlu soru mu?
  final String? helpText;               // Yardım metni
  final String? imageUrl;               // Soru görseli

  SurveyQuestion({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.scaleMin,
    this.scaleMax,
    this.scaleLabels,
    this.category,
    this.order = 0,
    this.isRequired = true,
    this.helpText,
    this.imageUrl,
  });

  factory SurveyQuestion.fromMap(Map<String, dynamic> map) {
    return SurveyQuestion(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => QuestionType.multipleChoice,
      ),
      options: map['options'] != null ? List<String>.from(map['options']) : null,
      scaleMin: map['scaleMin'],
      scaleMax: map['scaleMax'],
      scaleLabels: map['scaleLabels'] != null ? List<String>.from(map['scaleLabels']) : null,
      category: map['category'],
      order: map['order'] ?? 0,
      isRequired: map['isRequired'] ?? true,
      helpText: map['helpText'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last,
      'options': options,
      'scaleMin': scaleMin,
      'scaleMax': scaleMax,
      'scaleLabels': scaleLabels,
      'category': category,
      'order': order,
      'isRequired': isRequired,
      'helpText': helpText,
      'imageUrl': imageUrl,
    };
  }
}

class UserGameSession {
  final String id;
  final String userId;
  final String gameId;
  final GameStatus status;
  final int currentScore;
  final int currentQuestionIndex;
  final Map<String, dynamic> answers;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime lastAccessedAt;
  final int timeSpent; // saniye cinsinden
  final String? partnerId; // Çift modu için

  UserGameSession({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.status,
    this.currentScore = 0,
    this.currentQuestionIndex = 0,
    required this.answers,
    required this.startedAt,
    this.completedAt,
    required this.lastAccessedAt,
    this.timeSpent = 0,
    this.partnerId,
  });

  factory UserGameSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserGameSession(
      id: doc.id,
      userId: data['userId'] ?? '',
      gameId: data['gameId'] ?? '',
      status: GameStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => GameStatus.notStarted,
      ),
      currentScore: data['currentScore'] ?? 0,
      currentQuestionIndex: data['currentQuestionIndex'] ?? 0,
      answers: Map<String, dynamic>.from(data['answers'] ?? {}),
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      lastAccessedAt: (data['lastAccessedAt'] as Timestamp).toDate(),
      timeSpent: data['timeSpent'] ?? 0,
      partnerId: data['partnerId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'gameId': gameId,
      'status': status.toString().split('.').last,
      'currentScore': currentScore,
      'currentQuestionIndex': currentQuestionIndex,
      'answers': answers,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'lastAccessedAt': Timestamp.fromDate(lastAccessedAt),
      'timeSpent': timeSpent,
      'partnerId': partnerId,
    };
  }

  UserGameSession copyWith({
    GameStatus? status,
    int? currentScore,
    int? currentQuestionIndex,
    Map<String, dynamic>? answers,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
    int? timeSpent,
  }) {
    return UserGameSession(
      id: id,
      userId: userId,
      gameId: gameId,
      status: status ?? this.status,
      currentScore: currentScore ?? this.currentScore,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      timeSpent: timeSpent ?? this.timeSpent,
      partnerId: partnerId,
    );
  }
}

class GameResult {
  final String id;
  final String userId;
  final String gameId;
  final int finalScore;
  final double percentage;
  final Map<String, dynamic> categoryScores;
  final List<String> achievements;
  final String personalityType;
  final List<String> recommendations;
  final DateTime completedAt;

  GameResult({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.finalScore,
    required this.percentage,
    required this.categoryScores,
    required this.achievements,
    required this.personalityType,
    required this.recommendations,
    required this.completedAt,
  });

  factory GameResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameResult(
      id: doc.id,
      userId: data['userId'] ?? '',
      gameId: data['gameId'] ?? '',
      finalScore: data['finalScore'] ?? 0,
      percentage: (data['percentage'] ?? 0.0).toDouble(),
      categoryScores: Map<String, dynamic>.from(data['categoryScores'] ?? {}),
      achievements: List<String>.from(data['achievements'] ?? []),
      personalityType: data['personalityType'] ?? '',
      recommendations: List<String>.from(data['recommendations'] ?? []),
      completedAt: (data['completedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'gameId': gameId,
      'finalScore': finalScore,
      'percentage': percentage,
      'categoryScores': categoryScores,
      'achievements': achievements,
      'personalityType': personalityType,
      'recommendations': recommendations,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  GameResult copyWith({
    String? id,
    String? userId,
    String? gameId,
    int? finalScore,
    double? percentage,
    Map<String, dynamic>? categoryScores,
    List<String>? achievements,
    String? personalityType,
    List<String>? recommendations,
    DateTime? completedAt,
  }) {
    return GameResult(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameId: gameId ?? this.gameId,
      finalScore: finalScore ?? this.finalScore,
      percentage: percentage ?? this.percentage,
      categoryScores: categoryScores ?? this.categoryScores,
      achievements: achievements ?? this.achievements,
      personalityType: personalityType ?? this.personalityType,
      recommendations: recommendations ?? this.recommendations,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}