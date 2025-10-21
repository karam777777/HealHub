import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/patient_model.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

  // Doctor profile controllers
  final specialtyController = TextEditingController();
  final clinicNameController = TextEditingController();
  final clinicAddressController = TextEditingController();
  final bioController = TextEditingController();

  // Patient profile controllers
  final addressController = TextEditingController();

  // Observable
  var isLoading = false.obs;
  var selectedUserType = ''.obs;
  var selectedGender = ''.obs;
  var selectedDob = Rx<DateTime?>(null);
  var workingHours = <String, List<WorkingHourRange>>{}.obs;

  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final doctorProfileFormKey = GlobalKey<FormState>();
  final patientProfileFormKey = GlobalKey<FormState>();

  @override
  void onClose() {
    if (!Get.isRegistered<AuthController>()) {
      emailController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
      fullNameController.dispose();
      phoneController.dispose();
      specialtyController.dispose();
      clinicNameController.dispose();
      clinicAddressController.dispose();
      bioController.dispose();
      addressController.dispose();
      super.onClose();
    }
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    isLoading.value = true;
    final success = await _authService.signInWithEmailAndPassword(
      emailController.text.trim(),
      passwordController.text,
    );
    if (success) {
      clearLoginForm();
    }
    isLoading.value = false;
  }

  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('خطأ', 'كلمات المرور غير متطابقة');
      return;
    }

    isLoading.value = true;
    final success = await _authService.createUserWithEmailAndPassword(
      emailController.text.trim(),
      passwordController.text,
    );

    if (success) {
      clearRegisterForm();
      Get.toNamed(AppRoutes.USER_TYPE_SELECTION);
    }
    isLoading.value = false;
  }

  Future<void> selectUserType(String userType) async {
    selectedUserType.value = userType;

    final success = await _authService.createUserProfile(
      fullName: fullNameController.text.trim(),
      userType: userType,
      phoneNumber: phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
    );

    if (success) {
      if (userType == 'doctor') {
        Get.toNamed(AppRoutes.DOCTOR_PROFILE_SETUP);
      } else {
        Get.toNamed(AppRoutes.PATIENT_PROFILE_SETUP);
      }
    }
  }

  Future<void> setupDoctorProfile() async {
    if (!doctorProfileFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final doctor = DoctorModel(
        uid: _authService.currentUserId!,
        fullName: fullNameController.text.trim(),
        specialty: specialtyController.text.trim(),
        clinicName: clinicNameController.text.trim(),
        clinicAddress: clinicAddressController.text.trim(),
        workingHours: workingHours, // Map<String, List<WorkingHourRange>>
        bio: bioController.text.trim().isEmpty
            ? null
            : bioController.text.trim(),
      );

      print('Doctor Model to be created: ${doctor.toMap()}');

      await _firestoreService.createDoctor(doctor);
      print('Doctor profile created successfully in Firestore.');
      clearDoctorProfileForm();
      Get.offAndToNamed(AppRoutes.DOCTOR_HOME);
    } catch (e) {
      print('Error in setupDoctorProfile: $e');
      Get.snackbar('خطأ', 'فشل في إنشاء ملف الطبيب: ${e.toString()}');
    }
    isLoading.value = false;
  }

  Future<void> setupPatientProfile() async {
    if (!patientProfileFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final patient = PatientModel(
        uid: _authService.currentUserId!,
        fullName: fullNameController.text.trim(),
        dob: selectedDob.value,
        gender: selectedGender.value.isEmpty ? null : selectedGender.value,
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
      );

      await _firestoreService.createPatient(patient);
      clearPatientProfileForm();
      Get.offAndToNamed(AppRoutes.PATIENT_HOME);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إنشاء ملف المريض: ${e.toString()}');
    }
    isLoading.value = false;
  }

  void addWorkingHours(String day, WorkingHourRange timeRange) {
    workingHours[day] ??= [];
    workingHours[day]!.add(timeRange);
    workingHours.refresh();
  }

  void removeWorkingHours(String day, WorkingHourRange timeRange) {
    workingHours[day]?.removeWhere(
      (element) =>
          element.startTime == timeRange.startTime &&
          element.endTime == timeRange.endTime,
    );
    if (workingHours[day]?.isEmpty == true) {
      workingHours.remove(day);
    }
    workingHours.refresh();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void clearLoginForm() {
    emailController.clear();
    passwordController.clear();
  }

  void clearRegisterForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    //  fullNameController.clear();
    phoneController.clear();
  }

  void clearDoctorProfileForm() {
    specialtyController.clear();
    clinicNameController.clear();
    clinicAddressController.clear();
    bioController.clear();
    workingHours.clear();
  }

  void clearPatientProfileForm() {
    addressController.clear();
    selectedGender.value = '';
    selectedDob.value = null;
  }

  // Validators
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!GetUtils.isEmail(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }
}
