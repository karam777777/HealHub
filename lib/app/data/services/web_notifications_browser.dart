// lib/app/data/services/web_notifications_browser.dart

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> showWebNotification({
  required String title,
  required String body,
  Map<String, dynamic>? data,
}) async {
  if (!html.Notification.supported) {
    // المتصفح لا يدعم إشعارات المتصفح
    print('Browser does not support notifications');
    return;
  }

  // طلب الإذن إذا لم يكن ممنوحاً
  if (html.Notification.permission == 'default') {
    final permission = await html.Notification.requestPermission();
    if (permission != 'granted') {
      print('Notification permission denied');
      return;
    }
  } else if (html.Notification.permission == 'denied') {
    print('Notification permission denied');
    return;
  }

  try {
    final notification = html.Notification(
      title,
      body: body,
      icon: '/favicon.ico',
    );

    // إغلاق الإشعار تلقائياً بعد 5 ثوانٍ
    Future.delayed(const Duration(seconds: 5), () {
      notification.close();
    });

    notification.onClick.listen((_) {
      // ركّز النافذة عند الضغط على الإشعار
      html.window.open(html.window.location.href, '_self');
      notification.close();

      // مثال توجيه (اختياري):
      // إذا بعثت URL ضمن data:
      final url = (data ?? const {})['url'];
      if (url is String && url.isNotEmpty) {
        html.window.open(url, '_self');
      }
    });

    print('Web notification shown: $title - $body');
  } catch (e) {
    print('Error showing web notification: $e');
  }
}
