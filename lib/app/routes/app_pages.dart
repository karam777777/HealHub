import 'package:get/get.dart';

import '../modules/auth/views/splash_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/user_type_selection_view.dart';
import '../modules/auth/views/doctor_profile_setup_view.dart';
import '../modules/auth/views/patient_profile_setup_view.dart';
import '../modules/doctor/views/doctor_home_view.dart';
import '../modules/patient/views/patient_home_view.dart';
import '../modules/doctor/views/doctor_appointments_view.dart';
import '../modules/patient/views/patient_appointments_view.dart';
import '../modules/patient/views/appointment_booking_view.dart';
import '../modules/doctor/views/prescription_write_view.dart';
import '../modules/patient/views/prescription_view.dart';
import '../modules/patient/views/doctor_list_view.dart';
import '../modules/patient/views/doctor_detail_view.dart';
import '../modules/auth/views/firebase_setup_view.dart';
import '../modules/shared/views/community_view.dart';
import '../modules/shared/views/notification_view.dart';
import '../modules/doctor/views/doctor_confirmed_appointments_view.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/doctor/bindings/doctor_binding.dart';
import '../modules/patient/bindings/patient_binding.dart';
import '../modules/auth/bindings/firebase_setup_binding.dart';
import '../modules/shared/controllers/community_controller.dart';
import '../modules/shared/controllers/notification_controller.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.FIREBASE_SETUP,
      page: () => FirebaseSetupView(),
      binding: FirebaseSetupBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.USER_TYPE_SELECTION,
      page: () => UserTypeSelectionView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.DOCTOR_PROFILE_SETUP,
      page: () => DoctorProfileSetupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.PATIENT_PROFILE_SETUP,
      page: () => PatientProfileSetupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.DOCTOR_HOME,
      page: () => DoctorHomeView(),
      binding: DoctorBinding(),
    ),
    GetPage(
      name: AppRoutes.PATIENT_HOME,
      page: () => PatientHomeView(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: AppRoutes.DOCTOR_APPOINTMENTS,
      page: () => DoctorAppointmentsView(),
      binding: DoctorBinding(),
    ),
    GetPage(
      name: AppRoutes.PATIENT_APPOINTMENTS,
      page: () => PatientAppointmentsView(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: AppRoutes.APPOINTMENT_BOOKING,
      page: () => AppointmentBookingView(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: AppRoutes.PRESCRIPTION_WRITE,
      page: () => PrescriptionWriteView(),
      binding: DoctorBinding(),
    ),
    GetPage(
      name: AppRoutes.PRESCRIPTION_VIEW,
      page: () => PrescriptionView(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: AppRoutes.DOCTOR_LIST,
      page: () => DoctorListView(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: AppRoutes.DOCTOR_DETAIL,
      page: () => DoctorDetailView(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: AppRoutes.COMMUNITY,
      page: () => CommunityView(),
      binding: BindingsBuilder(() => Get.put(CommunityController())),
    ),
    GetPage(
      name: AppRoutes.NOTIFICATIONS,
      page: () => NotificationView(),
      binding: BindingsBuilder(() => Get.put(NotificationController())),
    ),
    GetPage(
      name: AppRoutes.DOCTOR_CONFIRMED_APPOINTMENTS,
      page: () => DoctorConfirmedAppointmentsView(),
      binding: DoctorBinding(),
    ),
  ];
}
