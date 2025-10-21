import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/prescription_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/notification_model.dart'; // Import NotificationModel for NotificationType enum
import '../../../routes/app_pages.dart';
import '../../../data/services/notification_service.dart'; // Import NotificationService
import 'package:uuid/uuid.dart';
class DoctorController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final NotificationService notificationService = Get.find<NotificationService>(); // Use NotificationService

  // Observable variables
  var isLoading = false.obs;
  var todayAppointments = <AppointmentModel>[].obs;
  var selectedDate = DateTime.now().obs;
  var doctorProfile = Rx<DoctorModel?>(null);
  var selectedAppointment = Rx<AppointmentModel?>(null);

  // Prescription form
  final prescriptionController = TextEditingController();
  final prescriptionFormKey = GlobalKey<FormState>();

  // Current user
  UserModel? get currentUser => _authService.currentUser.value;
  String? get currentUserId => _authService.currentUserId;

  @override
  void onInit() {
    super.onInit();
    loadDoctorProfile();
    loadTodayAppointments();

    // Listen to date changes
    ever(selectedDate, (_) => loadAppointmentsForDate());
  }

  @override
  void onClose() {
    prescriptionController.dispose();
    super.onClose();
  }

  // Confirm appointment
  Future<void> confirmAppointment(AppointmentModel appointment) async {
    try {
      isLoading.value = true;

      AppointmentModel updatedAppointment = appointment.copyWith(
        status: 'confirmed',
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateAppointment(updatedAppointment);

      // Send notification to patient
      await notificationService.notifyPatientAppointmentConfirmed(updatedAppointment);

      // Send notification to doctor (if this was a new appointment)
      if (appointment.status == 'pending') {
        await notificationService.notifyDoctorNewAppointment(updatedAppointment);
      }
      loadAppointmentsForDate();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تأكيد الموعد: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Reject appointment
  Future<void> rejectAppointment(AppointmentModel appointment) async {
    try {
      isLoading.value = true;

      AppointmentModel updatedAppointment = appointment.copyWith(
        status: 'cancelled',
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateAppointment(updatedAppointment);

      // Send notification to patient
      await notificationService.notifyPatientAppointmentCancelled(updatedAppointment);
      // Send notification to doctor
      await notificationService.notifyDoctorAppointmentCancelled(updatedAppointment);

      Get.snackbar('نجح', 'تم رفض الموعد بنجاح');
      loadAppointmentsForDate();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في رفض الموعد: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load doctor profile
  Future<void> loadDoctorProfile() async {
    if (currentUserId == null) return;

    try {
      DoctorModel? doctor = await _firestoreService.getDoctor(currentUserId!);
      doctorProfile.value = doctor;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل ملف الطبيب: ${e.toString()}');
    }
  }

  // Load today's appointments
  Future<void> loadTodayAppointments() async {
    if (currentUserId == null) return;

    try {
      isLoading.value = true;
      List<AppointmentModel> appointments = await _firestoreService
          .getDoctorAppointments(currentUserId!, DateTime.now());
      todayAppointments.value = appointments;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل المواعيد: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load appointments for specific date
  Future<void> loadAppointmentsForDate() async {
    if (currentUserId == null) {
      print("Doctor: currentUserId is null, cannot load appointments");
      return;
    }

try {
      isLoading.value = true;
      print(
        "Doctor: Loading appointments for doctor $currentUserId on date ${selectedDate.value}",
      );
      List<AppointmentModel> appointments = await _firestoreService
          .getDoctorAppointments(currentUserId!, selectedDate.value);
      print("Doctor: Loaded ${appointments.length} appointments");
      todayAppointments.value = appointments;
    } catch (e) {
      print("Doctor: Error loading appointments: $e");
      Get.snackbar('خطأ', 'فشل في تحميل المواعيد: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Get appointment status color
  Color getAppointmentStatusColor(AppointmentModel appointment) {
    DateTime now = DateTime.now();
    DateTime appointmentTime = appointment.appointmentTime;

    // Check if appointment is current (within 30 minutes)
    Duration difference = appointmentTime.difference(now);

    if (difference.inMinutes <= 30 && difference.inMinutes >= -30) {
      return Colors.green; // Current appointment
    }

    // Check if appointment is next (within next hour)
    if (difference.inMinutes > 30 && difference.inMinutes <= 90) {
      return Colors.blue; // Next appointment
      // TODO: Trigger notification for patient
    }

    return Colors.grey; // Other appointments
  }

  // Get appointment status text
  String getAppointmentStatusText(AppointmentModel appointment) {
    DateTime now = DateTime.now();
    DateTime appointmentTime = appointment.appointmentTime;

    Duration difference = appointmentTime.difference(now);

    if (difference.inMinutes <= 30 && difference.inMinutes >= -30) {
      return 'الموعد الحالي';
    }

    if (difference.inMinutes > 30 && difference.inMinutes <= 90) {
      return 'الموعد التالي';
    }

    if (difference.inMinutes < -30) {
      return 'منتهي';
    }

    return 'قادم';
  }

  // Complete appointment
  Future<void> completeAppointment(AppointmentModel appointment) async {
    try {
      isLoading.value = true;

      AppointmentModel updatedAppointment = appointment.copyWith(
        status: 'completed',
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateAppointment(updatedAppointment);

      // Send notification to patient
      await notificationService.notifyPatientAppointmentCompleted(updatedAppointment);

      Get.snackbar('نجح', 'تم إتمام الموعد بنجاح');
      loadAppointmentsForDate();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إتمام الموعد: ${e.toString()}');
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(AppointmentModel appointment) async {
    try {
      isLoading.value = true;

      AppointmentModel updatedAppointment = appointment.copyWith(
        status: 'cancelled',
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateAppointment(updatedAppointment);

      // Send notification to patient
      await notificationService.notifyPatientAppointmentCancelled(updatedAppointment);
      await notificationService.notifyDoctorAppointmentCancelled(updatedAppointment);

      Get.snackbar('نجح', 'تم إلغاء الموعد بنجاح');
      loadAppointmentsForDate();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إلغاء الموعد: ${e.toString()}');
    }
  }

// Navigate to prescription writing
  void navigateToPrescriptionWrite(AppointmentModel appointment) {
    selectedAppointment.value = appointment;
    Get.toNamed(AppRoutes.PRESCRIPTION_WRITE, arguments: appointment);
  }

  // Write prescription
  Future<void> writePrescription() async {
    if (!prescriptionFormKey.currentState!.validate() ||
        selectedAppointment.value == null ||
        currentUserId == null) {
      return;
    }

    try {
      isLoading.value = true;

      PrescriptionModel prescription = PrescriptionModel(
        prescriptionId:'',
        appointmentId: selectedAppointment.value!.appointmentId,
        doctorUid: currentUserId!,
        patientUid: selectedAppointment.value!.patientUid,
        prescriptionText: prescriptionController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Update the appointment status to reflect that a prescription has been added
      await _firestoreService.updateAppointment(
        selectedAppointment.value!.copyWith(hasPrescription: true),
      );

      String prescriptionId = await _firestoreService.createPrescription(
        prescription,
      );

      // Send notification to patient
      await notificationService.notifyNewPrescription(
        selectedAppointment.value!.patientUid,
        currentUserId!, // Pass doctorUid
      ); // Use the correct notification type and service

      Get.snackbar('نجح', 'تم إرسال الوصفة الطبية بنجاح');
      prescriptionController.clear();
      Get.back();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إرسال الوصفة الطبية: ${e.toString()}');
    }
  }

  // Get patient name by uid
  Future<String> getPatientName(String patientUid) async {
    try {
      var user = await _firestoreService.getUser(patientUid);
      return user?.fullName ?? 'مريض';
    } catch (e) {
      return 'مريض';
    }
  }

  // Change selected date
  void changeDate(DateTime date) {
    selectedDate.value = date;
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Refresh data
  Future<void> refreshData() async {
    await Future.wait([loadDoctorProfile(), loadAppointmentsForDate()]);
  }

  // Validators
  String? validatePrescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى كتابة الوصفة الطبية';
    }
    if (value.trim().length < 10) {
      return 'يجب أن تكون الوصفة الطبية أكثر تفصيلاً';
    }
    return null;
  }

  // Format date helper
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }
}


