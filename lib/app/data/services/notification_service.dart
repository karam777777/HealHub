// lib/app/data/services/notification_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../models/appointment_model.dart';
import '../models/notification_model.dart';
import '../models/community_post_model.dart';
import '../models/comment_model.dart';
import '../models/rating_model.dart';

import 'firestore_service.dart';
import 'auth_service.dart';

// استبدلنا web_notification_service.dart بجسر آمن لا يجرّ dart:html على Android
import 'web_notification_bridge.dart' as web_bridge;

class NotificationService extends GetxService {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  var notifications = <NotificationModel>[].obs;
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeLocalNotifications();
    _requestPermissions();
    _configureFirebaseMessaging();

    // Load notifications for the current user if logged in
    ever(_authService.firebaseUser, (user) {
      if (user != null) {
        loadNotifications(user.uid);
      } else {
        notifications.clear();
        unreadCount.value = 0;
      }
    });
  }

  void _initializeLocalNotifications() {
    if (kIsWeb) {
      // على الويب نستخدم Notification API الخاصة بالمتصفح
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          // يمكنك التنقّل حسب payload
          debugPrint('Notification payload: ${details.payload}');
        }
      },
    );
  }

  Future<void> _requestPermissions() async {
    // إذن الإشعارات عبر FCM (يناسب الموبايل والويب)
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  void _configureFirebaseMessaging() {
    // احصل على التوكن وخزّنه في Firestore
    _firebaseMessaging.getToken().then((token) {
      if (token != null && _authService.currentUserId != null) {
        debugPrint('FCM Token: $token');
        _firestoreService.updateUserToken(_authService.currentUserId!, token);
      }
    });

    // عند تحديث التوكن
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      if (_authService.currentUserId != null) {
        _firestoreService.updateUserToken(
          _authService.currentUserId!,
          newToken,
        );
      }
    });

    // رسائل المقدّمة (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Got a foreground message: ${message.messageId}');
      debugPrint('Message data: ${message.data}');
      
      // إنشاء مستند إشعار في Firestore أولاً
      if (_authService.currentUserId != null) {
        await _firestoreService.createNotification(
          NotificationModel(
            notificationId: '',
            userId: _authService.currentUserId!,
            title: message.notification?.title ?? 'HealHub',
            message: message.notification?.body ?? 'لديك إشعار جديد',
            type: NotificationType.other,
            isRead: false,
            createdAt: DateTime.now(),
            data: message.data,
          ),
        );
      }
      
      // عرض الإشعار المحلي
      if (message.notification != null) {
        await showNotification(
          title: message.notification?.title ?? 'HealHub',
          body: message.notification?.body ?? 'لديك إشعار جديد',
          payload: message.data['payload'],
          data: message.data,
        );
      }
    });
  
    // الرسالة التي فتحت التطبيق من حالة terminated
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('Opened from terminated: ${message.messageId}');
        // TODO: تنقّل أو تعامل خاص إن لزم
      }
    });

    // فتح التطبيق من الخلفية
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Opened from background: ${message.messageId}');
      // TODO: تنقّل أو تعامل خاص إن لزم
    });
  }

  // ✅ دالة واحدة لكل المنصات:
  // على الويب → تستخدم bridge (Notification API)
  // على الموبايل → FlutterLocalNotificationsPlugin
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    Map<String, dynamic>? data,
  }) async {
    if (kIsWeb) {
      await web_bridge.showWebNotification(
        title: title,
        body: body,
        data: data ?? (payload != null ? {'payload': payload} : null),
      );
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'medical_app_channel',
      'Medical App Notifications',
      channelDescription: 'Notifications for HealHub app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  // ———————————————— إشعارات أعمالك الحالية ————————————————

  Future<void> notifyPatientNextInQueue(AppointmentModel appointment) async {
    try {
      final notification = NotificationModel(
        notificationId: '',
        userId: appointment.patientUid,
        title: 'موعدك القادم',
        message: 'أنت التالي في الطابور. يرجى الاستعداد للدخول.',
        type: NotificationType.appointmentReminder,
        isRead: false,
        createdAt: DateTime.now(),
        data: {
          'appointmentId': appointment.appointmentId,
          'doctorUid': appointment.doctorUid,
        },
      );
      await _firestoreService.createNotification(notification);
      final recipientToken = await _firestoreService.getUserToken(
        notification.userId,
      );
      if (recipientToken != null) {
        await _sendTargetedNotification(
          recipientToken,
          notification.title,
          notification.message,
          notification.data,
        );
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }
  

  Future<void> notifyDoctorNewAppointment(AppointmentModel appointment) async {
    try {
      final notification = NotificationModel(
        notificationId: '',
        userId: appointment.doctorUid,
        title: 'حجز جديد',
        message:
            'لديك حجز جديد من ${appointment.patientName} في ${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute}.',
        type: NotificationType.newAppointment,
        isRead: false,
        createdAt: DateTime.now(),
        data: {
          'appointmentId': appointment.appointmentId,
          'patientUid': appointment.patientUid,
        },
      );
      await _firestoreService.createNotification(notification);
      final recipientToken = await _firestoreService.getUserToken(
        notification.userId,
      );
      if (recipientToken != null) {
        await _sendTargetedNotification(
          recipientToken,
          notification.title,
          notification.message,
          notification.data,
        );
      }
    } catch (e) {
      debugPrint('Error sending new appointment notification to doctor: $e');
    }
  }

  Future<void> notifyPatientAppointmentConfirmed(
    AppointmentModel appointment,
  ) async {
    try {
      final notification = NotificationModel(
        notificationId: '',
        userId: appointment.patientUid,
        title: 'تم تأكيد موعدك',
        message: 'تم تأكيد موعدك بنجاح. سيتم إشعارك عند اقتراب موعدك.',
        type: NotificationType.newAppointment,
        isRead: false,
        createdAt: DateTime.now(),
        data: {
          'appointmentId': appointment.appointmentId,
          'doctorUid': appointment.doctorUid,
        },
      );
      await _firestoreService.createNotification(notification);
      final recipientToken = await _firestoreService.getUserToken(
        notification.userId,
      );
      if (recipientToken != null) {
        await _sendTargetedNotification(
          recipientToken,
          notification.title,
          notification.message,
          notification.data,
        );
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  Future<void> notifyDoctorAppointmentCancelled(
    AppointmentModel appointment,
  ) async {
    try {
      final notification = NotificationModel(
        notificationId: '',
        userId: appointment.doctorUid,
        title: 'تم إلغاء حجز',
        message:
            'تم إلغاء حجز من ${appointment.patientName} لموعد في ${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute}.',
        type: NotificationType.appointmentReminder,
        isRead: false,
        createdAt: DateTime.now(),
        data: {
          'appointmentId': appointment.appointmentId,
          'patientUid': appointment.patientUid,
        },
      );
      await _firestoreService.createNotification(notification);
      final recipientToken = await _firestoreService.getUserToken(
        notification.userId,
      );
      if (recipientToken != null) {
        await _sendTargetedNotification(
          recipientToken,
          notification.title,
          notification.message,
          notification.data,
        );
      }
    } catch (e) {
      debugPrint(
        'Error sending appointment cancellation notification to doctor: $e',
      );
    }
  }

  Future<void> notifyPatientAppointmentCancelled(
    AppointmentModel appointment,
  ) async {
    try {
      final notification = NotificationModel(
        notificationId: '',
        userId: appointment.patientUid,
        title: 'تم إلغاء موعدك',
        message: 'تم إلغاء موعدك. يمكنك حجز موعد جديد في أي وقت.',
        type: NotificationType.appointmentReminder,
        isRead: false,
        createdAt: DateTime.now(),
        data: {
          'appointmentId': appointment.appointmentId,
          'doctorUid': appointment.doctorUid,
        },
      );
      await _firestoreService.createNotification(notification);
      final recipientToken = await _firestoreService.getUserToken(
        notification.userId,
      );
      if (recipientToken != null) {
        await _sendTargetedNotification(
          recipientToken,
          notification.title,
          notification.message,
          notification.data,
        );
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  Future<void> notifyPatientAppointmentCompleted(
    AppointmentModel appointment,
  ) async {
    try {
      final notification = NotificationModel(
        notificationId: '',
        userId: appointment.patientUid,
        title: 'تم إتمام موعدك',
        message: 'تم إتمام موعدك بنجاح. يمكنك الآن تقييم الطبيب.',
        type: NotificationType.appointmentReminder,
        isRead: false,
        createdAt: DateTime.now(),
        data: {
          'appointmentId': appointment.appointmentId,
          'doctorUid': appointment.doctorUid,
        },
      );
      await _firestoreService.createNotification(notification);
      final recipientToken = await _firestoreService.getUserToken(
        notification.userId,
      );
      if (recipientToken != null) {
        await _sendTargetedNotification(
          recipientToken,
          notification.title,
          notification.message,
          notification.data,
        );
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  Future<void> notifyNewPrescription(
    String patientUid,
    String doctorUid,
  ) async {
    try {
      final notification = NotificationModel(
        notificationId: '',
        userId: patientUid,
        title: 'وصفة طبية جديدة',
        message: 'تم إرسال وصفة طبية جديدة لك من الطبيب.',
        type: NotificationType.prescriptionIssued,
        isRead: false,
        createdAt: DateTime.now(),
        data: {'doctorUid': doctorUid},
      );
      await _firestoreService.createNotification(notification);
      final recipientToken = await _firestoreService.getUserToken(
        notification.userId,
      );
      if (recipientToken != null) {
        await _sendTargetedNotification(
          recipientToken,
          notification.title,
          notification.message,
          notification.data,
        );
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  Future<void> notifyDoctorNewRating(RatingModel rating) async {
    try {
      final notification = NotificationModel(
        notificationId: '',
        userId: rating.doctorId,
        title: 'تقييم جديد',
        message:
            'لقد تلقيت تقييمًا جديدًا بـ ${rating.rating} نجوم من ${rating.patientName}.',
        type: NotificationType.system, // أو نوع مخصص newRating
        isRead: false,
        createdAt: DateTime.now(),
        data: {'ratingId': rating.id, 'patientUid': rating.patientId},
      );
      await _firestoreService.createNotification(notification);
      final recipientToken = await _firestoreService.getUserToken(
        notification.userId,
      );
      if (recipientToken != null) {
        await _sendTargetedNotification(
          recipientToken,
          notification.title,
          notification.message,
          notification.data,
        );
      }
    } catch (e) {
      debugPrint('Error sending new rating notification to doctor: $e');
    }
  }

  Future<void> notifyNewCommunityPost(CommunityPostModel post) async {
    try {
      final patientUids = await _firestoreService.getAllPatientUids();
      for (final patientUid in patientUids) {
        if (patientUid == post.doctorUid) continue;

        final notification = NotificationModel(
          notificationId: '',
          userId: patientUid,
          title: 'منشور جديد من ${post.doctorName}',
          message:
              'تم نشر منشور جديد في المجتمع الطبي: ${post.content.length > 50 ? post.content.substring(0, 50) + '...' : post.content}',
          type: NotificationType.communityPost,
          isRead: false,
          createdAt: DateTime.now(),
          data: {'postId': post.postId, 'doctorUid': post.doctorUid},
        );
        await _firestoreService.createNotification(notification);
        final recipientToken = await _firestoreService.getUserToken(
          notification.userId,
        );
        if (recipientToken != null) {
          await _sendTargetedNotification(
            recipientToken,
            notification.title,
            notification.message,
            notification.data,
          );
        }
      }
    } catch (e) {
      debugPrint('Error sending new community post notification: $e');
    }
  }

  Future<void> notifyNewComment(
    CommunityPostModel post,
    CommentModel comment,
  ) async {
    try {
      final notification = NotificationModel(
        notificationId: '',
        userId: post.doctorUid,
        title: 'تعليق جديد على منشورك',
        message:
            '${comment.userName} علّق على منشورك: ${comment.commentText.length > 50 ? comment.commentText.substring(0, 50) + '...' : comment.commentText}',
        type: NotificationType.newComment,
        isRead: false,
        createdAt: DateTime.now(),
        data: {
          'postId': post.postId,
          'commentId': comment.commentId,
          'commenterUid': comment.userId,
        },
      );
      await _firestoreService.createNotification(notification);
      final recipientToken = await _firestoreService.getUserToken(
        notification.userId,
      );
      if (recipientToken != null) {
        await _sendTargetedNotification(
          recipientToken,
          notification.title,
          notification.message,
          notification.data,
        );
      }
    } catch (e) {
      debugPrint('Error sending new comment notification: $e');
    }
  }

  Future<void> clearAllNotifications(String userId) async {
    try {
      await _firestoreService.clearUserNotifications(userId);
      notifications.clear();
      unreadCount.value = 0;
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
    }
  }

  Future<void> loadNotifications(String userId) async {
    try {
      _firestoreService.getUserNotificationsStream(userId).listen((
        userNotifications,
      ) {
        notifications.value = userNotifications;
        unreadCount.value = userNotifications.where((n) => !n.isRead).length;
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> markAsRead(NotificationModel notification) async {
    try {
      final updated = notification.copyWith(isRead: true);
      await _firestoreService.updateNotification(updated);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _firestoreService.markAllNotificationsAsRead(userId);
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.appointmentReminder:
      case NotificationType.newAppointment:
        return Icons.schedule;
      case NotificationType.prescriptionIssued:
        return Icons.receipt_long;
      case NotificationType.chatMessage:
        return Icons.chat;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.communityPost:
        return Icons.campaign;
      case NotificationType.newComment:
        return Icons.comment;
      case NotificationType.patientEntryConfirmed:
        return Icons.meeting_room;
      case NotificationType.other:
      default:
        return Icons.notifications;
    }
  }
}

// Helper function to send a notification to a specific device token
Future<void> _sendTargetedNotification(
  String token,
  String title,
  String body,
  Map<String, dynamic>? data,
) async {
  // This is a conceptual implementation. In a real app, you would use a backend service (like Firebase Cloud Functions)
  // to send messages using the FCM admin SDK to avoid exposing server keys on the client.
  // For this project, we'll simulate the behavior by logging it and showing a local notification.
  debugPrint('--- Sending Targeted Notification ---');
  debugPrint('Token: $token');
  debugPrint('Title: $title');
  debugPrint('Body: $body');
  debugPrint('Data: $data');
  debugPrint('------------------------------------');

  // Show local notification as fallback
  await NotificationService.showNotification(
    title: title,
    body: body,
    data: data,
  );

  // The logic to send a push notification via a server would go here.
  // For example, using an HTTP POST request to the FCM API.
}

// Helper function to send a notification to all users
Future<void> _sendNotificationToAllUsers(
  String title,
  String body,
  Map<String, dynamic>? data,
) async {
  // The logic to send a push notification to all users via a server would go here.
  // For example, using an HTTP POST request to the FCM API.
  debugPrint('--- Sending Notification to All Users ---');
  debugPrint('Title: $title');
  debugPrint('Body: $body');
  debugPrint('Data: $data');
  debugPrint('------------------------------------');
}