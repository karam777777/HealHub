import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/services/notification_service.dart'; // Import the new NotificationService
import '../../../data/models/notification_model.dart';
import '../../../data/models/user_model.dart';

class NotificationController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final NotificationService _notificationService = Get.find<NotificationService>();

  // Observable variables
  var notifications = <NotificationModel>[].obs;
  var unreadCount = 0.obs;
  var isLoading = false.obs;

  // Current user
  UserModel? get currentUser => _authService.currentUser.value;
  String? get currentUserId => _authService.currentUserId;

  @override
  void onInit() {
    super.onInit();
    // Listen to notifications from NotificationService
    ever(_notificationService.notifications, (List<NotificationModel> newNotifications) {
      notifications.value = newNotifications;
      _updateUnreadCount();
    });
    ever(_notificationService.unreadCount, (int newUnreadCount) {
      unreadCount.value = newUnreadCount;
    });

    // Initial load if user is already logged in
    if (currentUserId != null) {
      _notificationService.loadNotifications(currentUserId!); // Use NotificationService to load
    }
  }

  // Load notifications (now handled by NotificationService)
  Future<void> loadNotifications() async {
    if (currentUserId == null) return;
    isLoading.value = true;
    await _notificationService.loadNotifications(currentUserId!); // Delegate to NotificationService
    isLoading.value = false;
  }

  // Mark notification as read (now handled by NotificationService)
  Future<void> markAsRead(NotificationModel notification) async {
    await _notificationService.markAsRead(notification);
  }

  // Mark all notifications as read (now handled by NotificationService)
  Future<void> markAllAsRead() async {
    if (currentUserId == null) return;
    await _notificationService.markAllAsRead(currentUserId!); // Delegate to NotificationService
    Get.snackbar('تم', 'تم تحديد جميع الإشعارات كمقروءة');
  }

  // Clear all notifications (now handled by NotificationService)
  Future<void> clearAllNotifications() async {
    if (currentUserId == null) return;
   await _notificationService.clearAllNotifications(currentUserId!); // Delegate to NotificationService
    Get.snackbar('تم', 'تم حذف جميع الإشعارات');
  }

  // Update unread count (now handled by NotificationService and reflected here)
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  // Handle notification tap
  void handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      markAsRead(notification);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.appointmentReminder:
      case NotificationType.newAppointment:
        _handleAppointmentNotification(notification);
        break;
      case NotificationType.prescriptionIssued:
        _handlePrescriptionNotification(notification);
        break;
      case NotificationType.chatMessage:
        // Handle chat message navigation
        break;
      case NotificationType.system:
        // Handle system notification
        break;
      case NotificationType.other:
        // Handle other notification types
        break;
      case NotificationType.appointment:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.communityPost:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.newComment:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.patientEntryConfirmed:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  void _handleAppointmentNotification(NotificationModel notification) {
    final appointmentId = notification.data?['appointmentId'];
    if (appointmentId != null) {
      // Navigate to appointment details or appointments list
      if (currentUser?.userType == 'doctor') {
        Get.toNamed('/doctor-home'); // Navigate to doctor home with appointments
      } else {
        Get.toNamed('/patient-appointments'); // Navigate to patient appointments
      }
    }
  }

  void _handlePrescriptionNotification(NotificationModel notification) {
    final prescriptionId = notification.data?['prescriptionId'];
    if (prescriptionId != null) {
      // Navigate to prescription details
      Get.toNamed('/prescriptions', arguments: prescriptionId);
    }
  }

  // Show notifications bottom sheet
  void showNotificationsBottomSheet() {
    Get.bottomSheet(
      _NotificationsBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Get notification icon
  IconData getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
      case NotificationType.appointmentReminder:
      case NotificationType.newAppointment:
        return Icons.calendar_today;
      case NotificationType.prescriptionIssued:
        return Icons.receipt_long;
      case NotificationType.chatMessage:
        return Icons.chat;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.communityPost:
        return Icons.article;
      case NotificationType.newComment:
        return Icons.comment;
      case NotificationType.other:
      default:
        return Icons.notifications;
    }
  }

  // Get notification color
  Color getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
      case NotificationType.newAppointment:
        return Colors.blue.shade700; // تأكيد = أزرق
      case NotificationType.appointmentReminder:
        return Colors.orange.shade700; // تذكير = برتقالي
      case NotificationType.prescriptionIssued:
        return Colors.green.shade700; // وصفة = أخضر
      case NotificationType.chatMessage:
        return Colors.purple.shade700; // رسالة = بنفسجي
      case NotificationType.system:
        return Colors.teal.shade700; // نظام = تركواز
      case NotificationType.communityPost:
        return Colors.indigo.shade700; // منشور مجتمع = نيلي
      case NotificationType.newComment:
        return Colors.deepOrange.shade700; // تعليق جديد = برتقالي غامق
      case NotificationType.other:
      default:
        return Colors.grey.shade700;
    }
  }
}

// Notifications Bottom Sheet Widget
class _NotificationsBottomSheet extends GetView<NotificationController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications,
                  color: Color(0xFF667eea),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'الإشعارات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                Obx(() => controller.unreadCount.value > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${controller.unreadCount.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'mark_all_read':
                        controller.markAllAsRead();
                        break;
                      case 'clear_all':
                        controller.clearAllNotifications();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'mark_all_read',
                      child: Text('تحديد الكل كمقروء'),
                    ),
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Text('حذف جميع الإشعارات'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Notifications list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                  ),
                );
              }

              if (controller.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد إشعارات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ستظهر الإشعارات هنا عند وصولها',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  final notification = controller.notifications[index];
                  return _buildNotificationItem(notification);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xFF667eea).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey[200]! : const Color(0xFF667eea).withOpacity(0.2),
        ),
      ),
      child: ListTile(
        onTap: () => controller.handleNotificationTap(notification),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: controller.getNotificationColor(notification.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            controller.getNotificationIcon(notification.type),
            color: controller.getNotificationColor(notification.type),
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatNotificationTime(notification.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF667eea),
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}


