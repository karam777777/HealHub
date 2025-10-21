import 'package:get/get.dart';
import 'package:untitled/app/modules/auth/controllers/auth_controller.dart';
import 'package:untitled/app/modules/shared/controllers/community_controller.dart';
import 'package:untitled/app/modules/shared/controllers/notification_controller.dart';
import '../data/services/auth_service.dart';
import '../data/services/firestore_service.dart';
import '../data/services/notification_service.dart';
import '../data/services/community_service.dart';
import 'package:untitled/app/data/services/doctor_follow_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<FirestoreService>(FirestoreService(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<CommunityService>(CommunityService(), permanent: true);
    Get.put<DoctorFollowService>(DoctorFollowService(), permanent: true);

    // إضافة الكنترولرز الناقصة
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
    Get.lazyPut<CommunityController>(() => CommunityController(), fenix: true);
  }
}


