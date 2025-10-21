// lib/app/data/services/web_notification_bridge.dart

export 'web_notifications_stub.dart'
  if (dart.library.html) 'web_notifications_browser.dart';