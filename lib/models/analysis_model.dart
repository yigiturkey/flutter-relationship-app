import 'package:cloud_firestore/cloud_firestore.dart';

enum AnalysisType {
  instant,
  general,
  couple,
  future,
}

enum AnalysisStatus {
  pending,
  processing,
  completed,
  failed,
}

class AnalysisModel {
  final String id;
  final String userId;
  final AnalysisType type;
  final AnalysisStatus status;
  final Map<String, dynamic> questions;
  final Map<String, dynamic> answers;
  final AnalysisResult? result;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? partnerId; // Çift modu için
  final int tokenCost;

  AnalysisModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.questions,
    required this.answers,
    this.result,
    required this.createdAt,
    this.completedAt,
    this.partnerId,
    this.tokenCost = 0,
  });

  factory AnalysisModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnalysisModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: AnalysisType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => AnalysisType.instant,
      ),
      status: AnalysisStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => AnalysisStatus.pending,
      ),
      questions: Map<String, dynamic>.from(data['questions'] ?? {}),
      answers: Map<String, dynamic>.from(data['answers'] ?? {}),
      result: data['result'] != null 
          ? AnalysisResult.fromMap(data['result']) 
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      partnerId: data['partnerId'],
      tokenCost: data['tokenCost'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'questions': questions,
      'answers': answers,
      'result': result?.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null 
          ? Timestamp.fromDate(completedAt!) 
          : null,
      'partnerId': partnerId,
      'tokenCost': tokenCost,
    };
  }

  AnalysisModel copyWith({
    AnalysisStatus? status,
    Map<String, dynamic>? answers,
    AnalysisResult? result,
    DateTime? completedAt,
  }) {
    return AnalysisModel(
      id: id,
      userId: userId,
      type: type,
      status: status ?? this.status,
      questions: questions,
      answers: answers ?? this.answers,
      result: result ?? this.result,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      partnerId: partnerId,
      tokenCost: tokenCost,
    );
  }
}

class AnalysisResult {
  final double compatibilityScore;
  final Map<String, double> categoryScores;
  final List<String> strengths;
  final List<String> improvementAreas;
  final List<String> recommendations;
  final String summary;
  final Map<String, dynamic> detailedInsights;

  AnalysisResult({
    required this.compatibilityScore,
    required this.categoryScores,
    required this.strengths,
    required this.improvementAreas,
    required this.recommendations,
    required this.summary,
    required this.detailedInsights,
  });

  factory AnalysisResult.fromMap(Map<String, dynamic> map) {
    return AnalysisResult(
      compatibilityScore: (map['compatibilityScore'] ?? 0.0).toDouble(),
      categoryScores: Map<String, double>.from(
        map['categoryScores']?.map((k, v) => MapEntry(k, v.toDouble())) ?? {},
      ),
      strengths: List<String>.from(map['strengths'] ?? []),
      improvementAreas: List<String>.from(map['improvementAreas'] ?? []),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      summary: map['summary'] ?? '',
      detailedInsights: Map<String, dynamic>.from(map['detailedInsights'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'compatibilityScore': compatibilityScore,
      'categoryScores': categoryScores,
      'strengths': strengths,
      'improvementAreas': improvementAreas,
      'recommendations': recommendations,
      'summary': summary,
      'detailedInsights': detailedInsights,
    };
  }
}

class AnalysisQuestion {
  final String id;
  final String text;
  final AnalysisQuestionType type;
  final List<String>? options; // Çoktan seçmeli için
  final int? minValue; // Slider için
  final int? maxValue; // Slider için
  final bool isRequired;
  final String category;

  AnalysisQuestion({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.minValue,
    this.maxValue,
    this.isRequired = true,
    required this.category,
  });

  factory AnalysisQuestion.fromMap(Map<String, dynamic> map) {
    return AnalysisQuestion(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      type: AnalysisQuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => AnalysisQuestionType.multipleChoice,
      ),
      options: map['options'] != null ? List<String>.from(map['options']) : null,
      minValue: map['minValue'],
      maxValue: map['maxValue'],
      isRequired: map['isRequired'] ?? true,
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last,
      'options': options,
      'minValue': minValue,
      'maxValue': maxValue,
      'isRequired': isRequired,
      'category': category,
    };
  }
}

enum AnalysisQuestionType {
  multipleChoice,
  scale,
  text,
  boolean,
}