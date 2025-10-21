import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Obx(() => controller.notifications.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.mark_email_read_outlined),
                  onPressed: controller.notifications.isNotEmpty ? () => controller.markAllAsRead() : null,
                  tooltip: 'تحديد الكل كمقروء',
                )
              : const SizedBox.shrink()),
          Obx(() => controller.notifications.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: controller.notifications.isNotEmpty ? () => controller.clearAllNotifications() : null,
                  tooltip: 'مسح الكل',
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 20),
                Text(
                  'لا توجد إشعارات حالياً',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'عندما يكون لديك إشعارات، ستظهر هنا.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
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
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: notification.isRead ? 0.5 : 2,
              color: notification.isRead ? Colors.grey[100] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: notification.isRead ? Colors.grey[200]! : Theme.of(context).primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.isRead ? Colors.grey[300] : Theme.of(context).primaryColor.withOpacity(0.8),
                  child: Icon(
                    controller.getNotificationIcon(notification.type),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  notification.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                trailing: notification.isRead
                    ? null
                    : Icon(Icons.circle, color: Theme.of(context).primaryColor, size: 10),
                onTap: () {
                  controller.markAsRead(notification);
                  // Optionally navigate to a specific screen based on notification.data or type
                  // Example: if (notification.type == NotificationType.appointmentReminder) { Get.toNamed(AppRoutes.PATIENT_APPOINTMENTS); }
                },
              ),
            );
          },
        );
      }),
    );
  }
}


