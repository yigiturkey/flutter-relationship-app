import 'package:cloud_firestore/cloud_firestore.dart';

enum PodcastCategory {
  relationship,
  personalGrowth,
  mindfulness,
  communication,
  selfCare,
  spirituality,
  motivation,
}

enum PodcastStatus {
  published,
  draft,
  archived,
}

class PodcastModel {
  final String id;
  final String title;
  final String description;
  final String host;
  final PodcastCategory category;
  final int duration; // saniye cinsinden
  final String audioUrl;
  final String? imageUrl;
  final String? transcript;
  final List<String> tags;
  final PodcastStatus status;
  final bool isPremium;
  final int listenCount;
  final double rating;
  final int ratingsCount;
  final DateTime publishedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PodcastModel({
    required this.id,
    required this.title,
    required this.description,
    required this.host,
    required this.category,
    required this.duration,
    required this.audioUrl,
    this.imageUrl,
    this.transcript,
    this.tags = const [],
    this.status = PodcastStatus.published,
    this.isPremium = false,
    this.listenCount = 0,
    this.rating = 0.0,
    this.ratingsCount = 0,
    required this.publishedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory PodcastModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PodcastModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      host: data['host'] ?? '',
      category: PodcastCategory.values.firstWhere(
        (e) => e.toString().split('.').last == data['category'],
        orElse: () => PodcastCategory.relationship,
      ),
      duration: data['duration'] ?? 0,
      audioUrl: data['audioUrl'] ?? '',
      imageUrl: data['imageUrl'],
      transcript: data['transcript'],
      tags: List<String>.from(data['tags'] ?? []),
      status: PodcastStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => PodcastStatus.published,
      ),
      isPremium: data['isPremium'] ?? false,
      listenCount: data['listenCount'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      ratingsCount: data['ratingsCount'] ?? 0,
      publishedAt: (data['publishedAt'] as Timestamp).toDate(),
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
      'host': host,
      'category': category.toString().split('.').last,
      'duration': duration,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'transcript': transcript,
      'tags': tags,
      'status': status.toString().split('.').last,
      'isPremium': isPremium,
      'listenCount': listenCount,
      'rating': rating,
      'ratingsCount': ratingsCount,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  PodcastModel copyWith({
    String? id,
    String? title,
    String? description,
    String? host,
    PodcastCategory? category,
    int? duration,
    String? audioUrl,
    String? imageUrl,
    String? transcript,
    List<String>? tags,
    PodcastStatus? status,
    bool? isPremium,
    int? listenCount,
    double? rating,
    int? ratingsCount,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PodcastModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      host: host ?? this.host,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      transcript: transcript ?? this.transcript,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      isPremium: isPremium ?? this.isPremium,
      listenCount: listenCount ?? this.listenCount,
      rating: rating ?? this.rating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get categoryDisplayName {
    switch (category) {
      case PodcastCategory.relationship:
        return 'İlişkiler';
      case PodcastCategory.personalGrowth:
        return 'Kişisel Gelişim';
      case PodcastCategory.mindfulness:
        return 'Farkındalık';
      case PodcastCategory.communication:
        return 'İletişim';
      case PodcastCategory.selfCare:
        return 'Öz Bakım';
      case PodcastCategory.spirituality:
        return 'Maneviyat';
      case PodcastCategory.motivation:
        return 'Motivasyon';
    }
  }
}

class PodcastPlayHistory {
  final String id;
  final String userId;
  final String podcastId;
  final int currentPosition; // saniye cinsinden
  final int totalDuration;
  final bool isCompleted;
  final DateTime startedAt;
  final DateTime lastPlayedAt;
  final DateTime? completedAt;

  PodcastPlayHistory({
    required this.id,
    required this.userId,
    required this.podcastId,
    this.currentPosition = 0,
    required this.totalDuration,
    this.isCompleted = false,
    required this.startedAt,
    required this.lastPlayedAt,
    this.completedAt,
  });

  factory PodcastPlayHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PodcastPlayHistory(
      id: doc.id,
      userId: data['userId'] ?? '',
      podcastId: data['podcastId'] ?? '',
      currentPosition: data['currentPosition'] ?? 0,
      totalDuration: data['totalDuration'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      lastPlayedAt: (data['lastPlayedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'podcastId': podcastId,
      'currentPosition': currentPosition,
      'totalDuration': totalDuration,
      'isCompleted': isCompleted,
      'startedAt': Timestamp.fromDate(startedAt),
      'lastPlayedAt': Timestamp.fromDate(lastPlayedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  PodcastPlayHistory copyWith({
    String? id,
    String? userId,
    String? podcastId,
    int? currentPosition,
    int? totalDuration,
    bool? isCompleted,
    DateTime? startedAt,
    DateTime? lastPlayedAt,
    DateTime? completedAt,
  }) {
    return PodcastPlayHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      podcastId: podcastId ?? this.podcastId,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  double get progressPercentage {
    if (totalDuration == 0) return 0.0;
    return (currentPosition / totalDuration).clamp(0.0, 1.0);
  }
}