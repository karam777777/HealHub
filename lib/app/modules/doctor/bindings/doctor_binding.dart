import 'package:get/get.dart';
import '../controllers/doctor_controller.dart';
import '../controllers/doctor_confirmed_appointments_controller.dart'; // تأكد من استيراد هذا الملف

class DoctorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorController>(
      () => DoctorController(),
    );
    Get.lazyPut<DoctorConfirmedAppointmentsController>(
      () => DoctorConfirmedAppointmentsController(),
    );
  }
}