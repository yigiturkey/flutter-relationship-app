import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  pulseCheck,
  analysisReady,
  trainingReminder,
  gameInvitation,
  achievementUnlocked,
  dailyReward,
  partnerActivity,
  systemUpdate,
  premium,
}

enum NotificationPriority {
  low,
  medium,
  high,
  urgent,
}

enum NotificationStatus {
  pending,
  sent,
  delivered,
  read,
  failed,
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final NotificationPriority priority;
  final NotificationStatus status;
  final String title;
  final String message;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final String? actionUrl;
  final String? actionText;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime? readAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.priority,
    required this.status,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.data,
    this.actionUrl,
    this.actionText,
    required this.createdAt,
    this.scheduledAt,
    this.sentAt,
    this.readAt,
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => NotificationType.systemUpdate,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString().split('.').last == data['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      status: NotificationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => NotificationStatus.pending,
      ),
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      imageUrl: data['imageUrl'],
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      actionUrl: data['actionUrl'],
      actionText: data['actionText'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      scheduledAt: data['scheduledAt'] != null 
          ? (data['scheduledAt'] as Timestamp).toDate() 
          : null,
      sentAt: data['sentAt'] != null 
          ? (data['sentAt'] as Timestamp).toDate() 
          : null,
      readAt: data['readAt'] != null 
          ? (data['readAt'] as Timestamp).toDate() 
          : null,
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'data': data,
      'actionUrl': actionUrl,
      'actionText': actionText,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'isRead': isRead,
    };
  }

  NotificationModel copyWith({
    NotificationStatus? status,
    DateTime? sentAt,
    DateTime? readAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      priority: priority,
      status: status ?? this.status,
      title: title,
      message: message,
      imageUrl: imageUrl,
      data: data,
      actionUrl: actionUrl,
      actionText: actionText,
      createdAt: createdAt,
      scheduledAt: scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationSettings {
  final String userId;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final Map<NotificationType, bool> typeSettings;
  final NotificationQuietHours? quietHours;
  final int maxDailyNotifications;
  final DateTime updatedAt;

  NotificationSettings({
    required this.userId,
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = false,
    required this.typeSettings,
    this.quietHours,
    this.maxDailyNotifications = 5,
    required this.updatedAt,
  });

  factory NotificationSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    Map<NotificationType, bool> typeSettings = {};
    final typeSettingsData = data['typeSettings'] as Map<String, dynamic>? ?? {};
    
    for (final type in NotificationType.values) {
      final key = type.toString().split('.').last;
      typeSettings[type] = typeSettingsData[key] ?? true;
    }

    return NotificationSettings(
      userId: data['userId'] ?? '',
      pushNotificationsEnabled: data['pushNotificationsEnabled'] ?? true,
      emailNotificationsEnabled: data['emailNotificationsEnabled'] ?? false,
      typeSettings: typeSettings,
      quietHours: data['quietHours'] != null 
          ? NotificationQuietHours.fromMap(data['quietHours']) 
          : null,
      maxDailyNotifications: data['maxDailyNotifications'] ?? 5,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    Map<String, bool> typeSettingsData = {};
    typeSettings.forEach((type, enabled) {
      typeSettingsData[type.toString().split('.').last] = enabled;
    });

    return {
      'userId': userId,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'typeSettings': typeSettingsData,
      'quietHours': quietHours?.toMap(),
      'maxDailyNotifications': maxDailyNotifications,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class NotificationQuietHours {
  final int startHour; // 0-23
  final int startMinute; // 0-59
  final int endHour; // 0-23
  final int endMinute; // 0-59
  final List<int> activeDays; // 1-7 (Pazartesi=1, Pazar=7)

  NotificationQuietHours({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.activeDays,
  });

  factory NotificationQuietHours.fromMap(Map<String, dynamic> map) {
    return NotificationQuietHours(
      startHour: map['startHour'] ?? 22,
      startMinute: map['startMinute'] ?? 0,
      endHour: map['endHour'] ?? 8,
      endMinute: map['endMinute'] ?? 0,
      activeDays: List<int>.from(map['activeDays'] ?? [1, 2, 3, 4, 5, 6, 7]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'activeDays': activeDays,
    };
  }

  bool isInQuietHours(DateTime time) {
    if (!activeDays.contains(time.weekday)) {
      return false;
    }

    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    if (startMinutes <= endMinutes) {
      // Aynı gün içinde (örn: 22:00 - 08:00 değil, 08:00 - 22:00)
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } else {
      // Gece yarısını geçen sessiz saatler (örn: 22:00 - 08:00)
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }
}

class NotificationTemplate {
  final String id;
  final NotificationType type;
  final String titleTemplate;
  final String messageTemplate;
  final String? imageUrl;
  final String? actionText;
  final Map<String, dynamic> defaultData;
  final bool isActive;

  NotificationTemplate({
    required this.id,
    required this.type,
    required this.titleTemplate,
    required this.messageTemplate,
    this.imageUrl,
    this.actionText,
    required this.defaultData,
    this.isActive = true,
  });

  factory NotificationTemplate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationTemplate(
      id: doc.id,
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => NotificationType.systemUpdate,
      ),
      titleTemplate: data['titleTemplate'] ?? '',
      messageTemplate: data['messageTemplate'] ?? '',
      imageUrl: data['imageUrl'],
      actionText: data['actionText'],
      defaultData: Map<String, dynamic>.from(data['defaultData'] ?? {}),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.toString().split('.').last,
      'titleTemplate': titleTemplate,
      'messageTemplate': messageTemplate,
      'imageUrl': imageUrl,
      'actionText': actionText,
      'defaultData': defaultData,
      'isActive': isActive,
    };
  }

  String generateTitle(Map<String, dynamic> variables) {
    String result = titleTemplate;
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value.toString());
    });
    return result;
  }

  String generateMessage(Map<String, dynamic> variables) {
    String result = messageTemplate;
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value.toString());
    });
    return result;
  }
}