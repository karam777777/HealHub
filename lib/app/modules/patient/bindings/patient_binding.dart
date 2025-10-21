import 'package:get/get.dart';
import 'package:untitled/app/data/services/doctor_follow_service.dart';
import 'package:untitled/app/modules/patient/controllers/doctor_follow_controller.dart';
import '../controllers/patient_controller.dart';

class PatientBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PatientController>(PatientController(), permanent: true);
    Get.lazyPut<DoctorFollowService>(() => DoctorFollowService());
    Get.lazyPut<DoctorFollowController>(() => DoctorFollowController());
  }
}