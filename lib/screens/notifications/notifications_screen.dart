import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/custom_button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Analiz Tamamlandı',
      message: 'Burç uyumluluğu analiziniz hazır! Sonuçları görüntülemek için tıklayın.',
      type: NotificationType.analysisComplete,
      isRead: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    NotificationItem(
      id: '2',
      title: 'Yeni Eğitim Eklendi',
      message: 'İletişim Becerileri eğitimimiz yayınlandı. Hemen başlayın!',
      type: NotificationType.newContent,
      isRead: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationItem(
      id: '3',
      title: 'Günlük Hatırlatma',
      message: 'Bugünün ilişki tavsiyesini okumayı unutmayın.',
      type: NotificationType.reminder,
      isRead: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    NotificationItem(
      id: '4',
      title: 'Premium Avantajları',
      message: 'Premium üyelikle sınırsız analiz yapın. %30 indirim fırsatı!',
      type: NotificationType.promotion,
      isRead: true,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationItem(
      id: '5',
      title: 'Haftalık Rapor Hazır',
      message: 'Bu haftaki ilişki gelişiminizi gösteren raporunuz hazır.',
      type: NotificationType.report,
      isRead: true,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadNotifications = _notifications.where((n) => !n.isRead).toList();
    final readNotifications = _notifications.where((n) => n.isRead).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          if (unreadNotifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Tümünü Okundu İşaretle',
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_read',
                child: const Text('Okunanları Temizle'),
              ),
              PopupMenuItem(
                value: 'settings',
                child: const Text('Bildirim Ayarları'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'clear_read':
                  _clearReadNotifications();
                  break;
                case 'settings':
                  Navigator.pushNamed(context, '/notification-settings');
                  break;
              }
            },
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unread notifications
                  if (unreadNotifications.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Yeni (${unreadNotifications.length})',
                        style: AppFonts.headingSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    ...unreadNotifications.map((notification) => 
                      _buildNotificationCard(notification)),
                    
                    const SizedBox(height: 16),
                  ],
                  
                  // Read notifications
                  if (readNotifications.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Önceki Bildirimler',
                        style: AppFonts.headingSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ...readNotifications.map((notification) => 
                      _buildNotificationCard(notification)),
                  ],
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? Colors.white 
                : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead 
                  ? AppColors.lightGray 
                  : AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationTypeColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationTypeIcon(notification.type),
                  color: _getNotificationTypeColor(notification.type),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppFonts.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: notification.isRead 
                                  ? FontWeight.normal 
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        // Unread indicator
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      notification.message,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: AppFonts.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Options
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    PopupMenuItem(
                      value: 'mark_read',
                      child: const Text('Okundu İşaretle'),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Sil',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'mark_read':
                      _markAsRead(notification.id);
                      break;
                    case 'delete':
                      _deleteNotification(notification.id);
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Henüz Bildirim Yok',
              style: AppFonts.headingMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Yeni analizler, eğitimler ve güncel bilgiler için bildirimleri açın.',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            CustomButton(
              text: 'Bildirim Ayarları',
              onPressed: () {
                Navigator.pushNamed(context, '/notification-settings');
              },
              variant: CustomButtonVariant.outlined,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.analysisComplete:
        return Icons.analytics;
      case NotificationType.newContent:
        return Icons.fiber_new;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.report:
        return Icons.assessment;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  Color _getNotificationTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.analysisComplete:
        return AppColors.success;
      case NotificationType.newContent:
        return AppColors.primary;
      case NotificationType.reminder:
        return AppColors.warning;
      case NotificationType.promotion:
        return AppColors.secondary;
      case NotificationType.report:
        return AppColors.info;
      case NotificationType.system:
        return AppColors.textSecondary;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.analysisComplete:
        Navigator.pushNamed(context, '/analysis-result');
        break;
      case NotificationType.newContent:
        Navigator.pushNamed(context, '/training');
        break;
      case NotificationType.reminder:
        Navigator.pushNamed(context, '/daily-tip');
        break;
      case NotificationType.promotion:
        Navigator.pushNamed(context, '/store');
        break;
      case NotificationType.report:
        Navigator.pushNamed(context, '/reports');
        break;
      case NotificationType.system:
        // Show details or navigate to settings
        break;
    }
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n.id == notificationId);
    });
  }

  void _clearReadNotifications() {
    setState(() {
      _notifications.removeWhere((n) => n.isRead);
    });
  }
}

enum NotificationType {
  analysisComplete,
  newContent,
  reminder,
  promotion,
  report,
  system,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime timestamp;
  final String? actionUrl;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.timestamp,
    this.actionUrl,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    DateTime? timestamp,
    String? actionUrl,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}