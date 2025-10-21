import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FirebaseSetupController extends GetxController {
  final isLoading = false.obs;
  final setupStatus = 'Ready to start Firebase setup.'.obs;

  Future<void> performSetup() async {
    isLoading.value = true;
    setupStatus.value = 'Starting Firebase setup...';

    try {
      // 1. Create a dummy doctor user
      setupStatus.value = 'Creating dummy doctor user...';
      UserCredential doctorCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'doctor@example.com',
        password: 'password123',
      );
      String doctorUid = doctorCredential.user!.uid;

      // 2. Add doctor data to Firestore
      setupStatus.value = 'Adding doctor data to Firestore...';
      String doctorId = Uuid().v4();
      await FirebaseFirestore.instance.collection('doctors').doc(doctorId).set({
        'uid': doctorUid,
        'id': doctorId,
        'name': 'Dr. Ahmed',
        'specialty': 'General Medicine',
        'email': 'doctor@example.com',
        'phone': '+966501234567',
        'address': 'Riyadh, Saudi Arabia',
        'bio': 'Experienced general practitioner.',
        'imageUrl': 'https://via.placeholder.com/150',
        'isApproved': true,
      });

      // 3. Create a dummy patient user
      setupStatus.value = 'Creating dummy patient user...';
      UserCredential patientCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'patient@example.com',
        password: 'password123',
      );
      String patientUid = patientCredential.user!.uid;

      // 4. Add patient data to Firestore
      setupStatus.value = 'Adding patient data to Firestore...';
      String patientId = Uuid().v4();
      await FirebaseFirestore.instance.collection('patients').doc(patientId).set({
        'uid': patientUid,
        'id': patientId,
        'name': 'Fatimah Ali',
        'email': 'patient@example.com',
        'phone': '+966557654321',
        'address': 'Jeddah, Saudi Arabia',
        'dateOfBirth': '1990-01-01',
        'gender': 'Female',
        'imageUrl': 'https://via.placeholder.com/150',
      });

      setupStatus.value = 'Firebase setup complete! Redirecting...';
      // Redirect to the main application after setup
      Get.offAllNamed('/splash'); // Assuming splash handles initial routing

    } catch (e) {
      setupStatus.value = 'Error during Firebase setup: ${e.toString()}';
      print('Firebase Setup Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}


