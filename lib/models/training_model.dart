import 'package:cloud_firestore/cloud_firestore.dart';

enum TrainingType {
  communication,
  empathy,
  conflictResolution,
  emotionalIntelligence,
  personalDevelopment,
  relationshipSkills,
}

enum TrainingDifficulty {
  beginner,
  intermediate,
  advanced,
}

enum TrainingStatus {
  notStarted,
  inProgress,
  completed,
  paused,
}

class TrainingModel {
  final String id;
  final String title;
  final String description;
  final String longDescription;
  final TrainingType type;
  final TrainingDifficulty difficulty;
  final int estimatedDuration; // dakika cinsinden
  final String? thumbnailUrl;
  final List<TrainingModule> modules;
  final bool isPremium;
  final int tokenCost;
  final double rating;
  final int ratingsCount;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TrainingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.longDescription,
    required this.type,
    required this.difficulty,
    required this.estimatedDuration,
    this.thumbnailUrl,
    required this.modules,
    this.isPremium = false,
    this.tokenCost = 0,
    this.rating = 0.0,
    this.ratingsCount = 0,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
  });

  factory TrainingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrainingModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      longDescription: data['longDescription'] ?? '',
      type: TrainingType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => TrainingType.personalDevelopment,
      ),
      difficulty: TrainingDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == data['difficulty'],
        orElse: () => TrainingDifficulty.beginner,
      ),
      estimatedDuration: data['estimatedDuration'] ?? 0,
      thumbnailUrl: data['thumbnailUrl'],
      modules: (data['modules'] as List<dynamic>?)
          ?.map((module) => TrainingModule.fromMap(module))
          .toList() ?? [],
      isPremium: data['isPremium'] ?? false,
      tokenCost: data['tokenCost'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      ratingsCount: data['ratingsCount'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'longDescription': longDescription,
      'type': type.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'estimatedDuration': estimatedDuration,
      'thumbnailUrl': thumbnailUrl,
      'modules': modules.map((module) => module.toMap()).toList(),
      'isPremium': isPremium,
      'tokenCost': tokenCost,
      'rating': rating,
      'ratingsCount': ratingsCount,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  TrainingModel copyWith({
    String? id,
    String? title,
    String? description,
    String? longDescription,
    TrainingType? type,
    TrainingDifficulty? difficulty,
    int? estimatedDuration,
    String? thumbnailUrl,
    List<TrainingModule>? modules,
    bool? isPremium,
    int? tokenCost,
    double? rating,
    int? ratingsCount,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      longDescription: longDescription ?? this.longDescription,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      modules: modules ?? this.modules,
      isPremium: isPremium ?? this.isPremium,
      tokenCost: tokenCost ?? this.tokenCost,
      rating: rating ?? this.rating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TrainingModule {
  final String id;
  final String title;
  final String content;
  final int order;
  final int estimatedDuration; // dakika
  final String? videoUrl;
  final String? audioUrl;
  final List<TrainingExercise> exercises;
  final bool isRequired;

  TrainingModule({
    required this.id,
    required this.title,
    required this.content,
    required this.order,
    required this.estimatedDuration,
    this.videoUrl,
    this.audioUrl,
    required this.exercises,
    this.isRequired = true,
  });

  factory TrainingModule.fromMap(Map<String, dynamic> map) {
    return TrainingModule(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      order: map['order'] ?? 0,
      estimatedDuration: map['estimatedDuration'] ?? 0,
      videoUrl: map['videoUrl'],
      audioUrl: map['audioUrl'],
      exercises: (map['exercises'] as List<dynamic>?)
          ?.map((exercise) => TrainingExercise.fromMap(exercise))
          .toList() ?? [],
      isRequired: map['isRequired'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'order': order,
      'estimatedDuration': estimatedDuration,
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      'isRequired': isRequired,
    };
  }
}

class TrainingExercise {
  final String id;
  final String title;
  final String description;
  final String type; // 'reflection', 'practice', 'quiz'
  final Map<String, dynamic> content;
  final bool isRequired;

  TrainingExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.content,
    this.isRequired = true,
  });

  factory TrainingExercise.fromMap(Map<String, dynamic> map) {
    return TrainingExercise(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      content: Map<String, dynamic>.from(map['content'] ?? {}),
      isRequired: map['isRequired'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'content': content,
      'isRequired': isRequired,
    };
  }
}

class UserTrainingProgress {
  final String id;
  final String userId;
  final String trainingId;
  final TrainingStatus status;
  final List<String> completedModules;
  final Map<String, dynamic> exerciseResults;
  final double progressPercentage;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime lastAccessedAt;

  UserTrainingProgress({
    required this.id,
    required this.userId,
    required this.trainingId,
    required this.status,
    required this.completedModules,
    required this.exerciseResults,
    this.progressPercentage = 0.0,
    required this.startedAt,
    this.completedAt,
    required this.lastAccessedAt,
  });

  factory UserTrainingProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserTrainingProgress(
      id: doc.id,
      userId: data['userId'] ?? '',
      trainingId: data['trainingId'] ?? '',
      status: TrainingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => TrainingStatus.notStarted,
      ),
      completedModules: List<String>.from(data['completedModules'] ?? []),
      exerciseResults: Map<String, dynamic>.from(data['exerciseResults'] ?? {}),
      progressPercentage: (data['progressPercentage'] ?? 0.0).toDouble(),
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      lastAccessedAt: (data['lastAccessedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'trainingId': trainingId,
      'status': status.toString().split('.').last,
      'completedModules': completedModules,
      'exerciseResults': exerciseResults,
      'progressPercentage': progressPercentage,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'lastAccessedAt': Timestamp.fromDate(lastAccessedAt),
    };
  }

  UserTrainingProgress copyWith({
    String? id,
    String? userId,
    String? trainingId,
    TrainingStatus? status,
    List<String>? completedModules,
    Map<String, dynamic>? exerciseResults,
    double? progressPercentage,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
  }) {
    return UserTrainingProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trainingId: trainingId ?? this.trainingId,
      status: status ?? this.status,
      completedModules: completedModules ?? this.completedModules,
      exerciseResults: exerciseResults ?? this.exerciseResults,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }
}