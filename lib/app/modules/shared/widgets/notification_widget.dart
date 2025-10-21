import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/models/notification_model.dart';

class NotificationWidget extends StatelessWidget {
  final String userId;

  const NotificationWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NotificationService notificationService = Get.find<NotificationService>();
    
    return Obx(() => Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined),
          onPressed: () => _showNotificationsBottomSheet(context, notificationService),
        ),
        if (notificationService.unreadCount.value > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${notificationService.unreadCount.value}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    ));
  }

  void _showNotificationsBottomSheet(BuildContext context, NotificationService notificationService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'الإشعارات',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (notificationService.unreadCount.value > 0)
                    TextButton(
                      onPressed: () => notificationService.markAllAsRead(userId),
                      child: Text(
                        'قراءة الكل',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Notifications list
            Expanded(
              child: Obx(() {
                if (notificationService.notifications.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: notificationService.notifications.length,
                  itemBuilder: (context, index) {
                    NotificationModel notification = notificationService.notifications[index];
                    return _buildNotificationCard(notification, notificationService);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationService notificationService) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead ? Colors.grey[300]! : Theme.of(Get.context!).primaryColor,
          width: notification.isRead ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            notificationService.markAsRead(notification);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type as String).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type as String),
                  color: _getNotificationColor(notification.type as String),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Unread indicator
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(Get.context!).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ستظهر الإشعارات هنا عند وصولها',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'appointment_next':
        return Icons.schedule;
      case 'appointment_confirmed':
        return Icons.check_circle;
      case 'appointment_cancelled':
        return Icons.cancel;
      case 'new_prescription':
        return Icons.receipt_long;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'appointment_next':
        return Colors.orange;
      case 'appointment_confirmed':
        return Colors.green;
      case 'appointment_cancelled':
        return Colors.red;
      case 'new_prescription':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

