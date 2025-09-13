import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final int age;
  final String? phone;
  final String? profileImageUrl;
  final bool isPremium;
  final int tokenBalance;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final UserPreferences preferences;
  final UserStats stats;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    this.phone,
    this.profileImageUrl,
    this.isPremium = false,
    this.tokenBalance = 0,
    required this.createdAt,
    required this.lastLoginAt,
    required this.preferences,
    required this.stats,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      age: data['age'] ?? 18,
      phone: data['phone'],
      profileImageUrl: data['profileImageUrl'],
      isPremium: data['isPremium'] ?? false,
      tokenBalance: data['tokenBalance'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
      stats: UserStats.fromMap(data['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'isPremium': isPremium,
      'tokenBalance': tokenBalance,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'preferences': preferences.toMap(),
      'stats': stats.toMap(),
    };
  }

  UserModel copyWith({
    String? email,
    String? name,
    int? age,
    String? phone,
    String? profileImageUrl,
    bool? isPremium,
    int? tokenBalance,
    DateTime? lastLoginAt,
    UserPreferences? preferences,
    UserStats? stats,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isPremium: isPremium ?? this.isPremium,
      tokenBalance: tokenBalance ?? this.tokenBalance,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
    );
  }
}

class UserPreferences {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String language;
  final List<String> interestedCategories;
  final int dailyNotificationLimit;

  UserPreferences({
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.language = 'tr',
    this.interestedCategories = const [],
    this.dailyNotificationLimit = 3,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      darkModeEnabled: map['darkModeEnabled'] ?? false,
      language: map['language'] ?? 'tr',
      interestedCategories: List<String>.from(map['interestedCategories'] ?? []),
      dailyNotificationLimit: map['dailyNotificationLimit'] ?? 3,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'language': language,
      'interestedCategories': interestedCategories,
      'dailyNotificationLimit': dailyNotificationLimit,
    };
  }
}

class UserStats {
  final int totalAnalyses;
  final int completedTrainings;
  final int gamesPlayed;
  final int achievementsUnlocked;
  final int streakDays;
  final DateTime? lastActiveDate;

  UserStats({
    this.totalAnalyses = 0,
    this.completedTrainings = 0,
    this.gamesPlayed = 0,
    this.achievementsUnlocked = 0,
    this.streakDays = 0,
    this.lastActiveDate,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalAnalyses: map['totalAnalyses'] ?? 0,
      completedTrainings: map['completedTrainings'] ?? 0,
      gamesPlayed: map['gamesPlayed'] ?? 0,
      achievementsUnlocked: map['achievementsUnlocked'] ?? 0,
      streakDays: map['streakDays'] ?? 0,
      lastActiveDate: map['lastActiveDate'] != null 
          ? (map['lastActiveDate'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalAnalyses': totalAnalyses,
      'completedTrainings': completedTrainings,
      'gamesPlayed': gamesPlayed,
      'achievementsUnlocked': achievementsUnlocked,
      'streakDays': streakDays,
      'lastActiveDate': lastActiveDate != null 
          ? Timestamp.fromDate(lastActiveDate!) 
          : null,
    };
  }
}