import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class WebNotificationService {
  static bool _permissionRequested = false;
  static String _permission = 'default';

  // Request notification permission for web
  static Future<bool> requestPermission() async {
    if (!kIsWeb) return false;

    if (_permissionRequested && _permission == 'granted') {
      return true;
    }

    try {
      // Check if notifications are supported
      if (!html.Notification.supported) {
        print('Web notifications are not supported in this browser');
        return false;
      }

      // Request permission
      final permission = await html.Notification.requestPermission();
      _permission = permission;
      _permissionRequested = true;

      print('Web notification permission: $permission');
      return permission == 'granted';
    } catch (e) {
      print('Error requesting web notification permission: $e');
      return false;
    }
  }

  // Show web notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String? icon,
    String? badge,
    Map<String, dynamic>? data,
  }) async {
    if (!kIsWeb) return;

    try {
      // Check permission first
      if (_permission != 'granted') {
        final hasPermission = await requestPermission();
        if (!hasPermission) {
          print('Web notification permission denied');
          return;
        }
      }

      // Create notification
      final notification = html.Notification(
        title,
        body: body,
        icon: icon ?? '/icons/Icon-192.png',
        tag: 'healhub-notification',
      );

      // Handle notification click
      notification.onClick.listen((event) {
        print('Web notification clicked');
        notification.close();
        // Focus the window
        html.window.open(html.window.location.href, html.window.name!);
      });

      // Auto close after 5 seconds if not interacted with
      Future.delayed(const Duration(seconds: 5), () {
        try {
          notification.close();
        } catch (e) {
          // Notification might already be closed
        }
      });
    } catch (e) {
      print('Error showing web notification: $e');
    }
  }

  // Check if notifications are supported and permitted
  static bool get isSupported {
    if (!kIsWeb) return false;
    return html.Notification.supported;
  }

  static String get permission {
    if (!kIsWeb) return 'denied';
    return html.Notification.permission ?? 'default';
  }

  static bool get hasPermission {
    return permission == 'granted';
  }
}
