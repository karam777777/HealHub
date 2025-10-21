import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/firebase_setup_controller.dart';

class FirebaseSetupView extends GetView<FirebaseSetupController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Setup'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Text(
                controller.setupStatus.value,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              )),
              SizedBox(height: 20),
              Obx(() => controller.isLoading.value
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => controller.performSetup(),
                      child: Text('Start Firebase Setup'),
                    )),
              SizedBox(height: 20),
              Text(
                'This process will initialize Firebase and create initial data (one doctor and one patient). Please ensure you have configured your Firebase project correctly.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


