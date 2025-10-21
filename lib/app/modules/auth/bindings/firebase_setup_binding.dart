import 'package:get/get.dart';
import '../controllers/firebase_setup_controller.dart';

class FirebaseSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FirebaseSetupController>(
      () => FirebaseSetupController(),
    );
  }
}


