import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/prescription_model.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/notification_service.dart'; // Import NotificationService

// تمثيل فترة زمنية مع حالتها
class TimeSlotStatus {
  final String time;
  final bool isBooked;

  TimeSlotStatus({required this.time, this.isBooked = false});
}

class PatientController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final NotificationService notificationService =
      Get.find<NotificationService>(); // Inject NotificationService

  // حالات تفاعلية
  var isLoading = false.obs;
  var doctors = <DoctorModel>[].obs;
  var appointments = <AppointmentModel>[].obs;
  var prescriptions = <PrescriptionModel>[].obs;
  var selectedDoctor = Rx<DoctorModel?>(null);
  var selectedDate = Rx<DateTime?>(null);
  var selectedTime = Rx<TimeOfDay?>(null);
  var availableTimeSlots = <TimeSlotStatus>[].obs;

  // المستخدم الحالي
  UserModel? get currentUser => _authService.currentUser.value;
  String? get currentUserId => _authService.currentUserId;

  @override
  void onInit() {
    super.onInit();
    loadDoctors();
    // Ensure appointments are loaded when the controller initializes
    loadPatientAppointments();
  }

  // تحميل الأطباء
  Future<void> loadDoctors() async {
    try {
      isLoading.value = true;
      final doctorsList = await _firestoreService.getAllDoctors();
      doctors.value = doctorsList;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل قائمة الأطباء: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // تحميل مواعيد المريض
  Future<void> loadPatientAppointments() async {
    if (currentUserId == null) {
      print("Error: currentUserId is null, cannot load patient appointments");
      return;
    }
    try {
      print("Loading appointments for patient: $currentUserId");
      final appointmentsList = await _firestoreService.getPatientAppointments(
        currentUserId!,
      );
      print("Loaded ${appointmentsList.length} appointments for patient");
      appointments.value = appointmentsList;
      print("Appointments updated in controller");
    } catch (e) {
      print("Error loading patient appointments: $e");
      Get.snackbar('خطأ', 'فشل في تحميل المواعيد: ${e.toString()}');
    }
  }

  // تحميل وصفات لمريض مع طبيب محدد
  Future<void> loadPrescriptions(String doctorUid) async {
    if (currentUserId == null) return;
    try {
      isLoading.value = true;
      final prescriptionsList = await _firestoreService.getPatientPrescriptions(
        currentUserId!,
        doctorUid,
      );
      prescriptions.value = prescriptionsList;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل الوصفات الطبية: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // اختيار طبيب والذهاب للتفاصيل
  void selectDoctor(DoctorModel doctor) {
    selectedDoctor.value = doctor;
    Get.toNamed(AppRoutes.DOCTOR_DETAIL, arguments: doctor);
  }

  // الذهاب لواجهة الحجز
  void navigateToBooking(DoctorModel doctor) {
    selectedDoctor.value = doctor;
    selectedDate.value = null; // Reset selected date
    selectedTime.value = null; // Reset selected time
    availableTimeSlots.clear(); // Clear previous time slots
    Get.toNamed(AppRoutes.APPOINTMENT_BOOKING, arguments: doctor);
  }

  // الذهاب للوصفات
  void navigateToPrescriptions(DoctorModel doctor) {
    selectedDoctor.value = doctor;
    loadPrescriptions(doctor.uid);
    Get.toNamed(AppRoutes.PRESCRIPTION_VIEW, arguments: doctor);
  }

  // توليد الفتحات الزمنية المتاحة لليوم المحدد
  Future<void> generateAvailableTimeSlots() async {
    availableTimeSlots.clear();

    if (selectedDoctor.value == null || selectedDate.value == null) {
      print(
        "Error: selectedDoctor or selectedDate is null. Cannot generate time slots.",
      );
      return;
    }

    final String dayName = _getDayName(selectedDate.value!.weekday);
    final List<WorkingHourRange>? workingHoursRanges =
        selectedDoctor.value!.workingHours[dayName];

    if (workingHoursRanges == null || workingHoursRanges.isEmpty) {
      Get.snackbar('تنبيه', 'الطبيب غير متاح في هذا اليوم');
      return;
    }

    // جلب المواعيد المحجوزة لذاك اليوم للطبيب المحدد
    List<AppointmentModel> bookedAppointments = [];
    try {
      bookedAppointments = await _firestoreService.getDoctorAppointments(
        selectedDoctor.value!.uid,
        selectedDate.value!,
      );
    } catch (e) {
      print(
        "Error fetching booked appointments for doctor ${selectedDoctor.value!.uid}: $e",
      );
    }

    for (final range in workingHoursRanges) {
      final TimeOfDay? startTime = _parseTime(range.startTime);
      final TimeOfDay? endTime = _parseTime(range.endTime);

      if (startTime == null || endTime == null) {
        print(
          "Skipping invalid time range: ${range.startTime} - ${range.endTime}",
        );
        continue;
      }

      DateTime current = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        startTime.hour,
        startTime.minute,
      );

      DateTime end = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        endTime.hour,
        endTime.minute,
      );

      if (!current.isBefore(end)) {
        print(
          "Start time is not before end time for range: ${range.startTime} - ${range.endTime}",
        );
        continue;
      }

      while (current.isBefore(end)) {
        final slotLabel =
            '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}';

        // Check if the current slot is booked for THIS doctor
        final bool isBooked = bookedAppointments.any((appointment) {
          final t = appointment.appointmentTime;
          return t.year == current.year &&
              t.month == current.month &&
              t.day == current.day &&
              t.hour == current.hour &&
              t.minute == current.minute &&
              appointment.doctorUid ==
                  selectedDoctor
                      .value!
                      .uid; // Ensure it's for the selected doctor
        });

        availableTimeSlots.add(
          TimeSlotStatus(time: slotLabel, isBooked: isBooked),
        );

        current = current.add(const Duration(minutes: 30));
      }
    }
  }

  // حجز موعد
  Future<void> bookAppointment() async {
    print("Starting bookAppointment process...");
    if (selectedDoctor.value == null ||
        selectedDate.value == null ||
        selectedTime.value == null ||
        currentUserId == null ||
        currentUser == null) {
      print("Error: Missing required data for booking");
      print("selectedDoctor: ${selectedDoctor.value?.clinicName}");
      print("selectedDate: ${selectedDate.value}");
      print("selectedTime: ${selectedTime.value}");
      print("currentUserId: $currentUserId");
      Get.snackbar('خطأ', 'يرجى اختيار جميع البيانات المطلوبة');
      return;
    }

    try {
      isLoading.value = true;

      final DateTime appointmentDateTime = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        selectedTime.value!.hour,
        selectedTime.value!.minute,
      );

      print("Creating appointment for:");
      print("Patient: $currentUserId");
      print("Doctor: ${selectedDoctor.value!.uid}");
      print("DateTime: $appointmentDateTime");

      final appointment = AppointmentModel(
        appointmentId: "",
        patientUid: currentUserId!,
        patientName: currentUser?.fullName ?? "مستخدم غير معروف",
        patientEmail: currentUser!.email,
        doctorUid: selectedDoctor.value!.uid,
        doctorName: selectedDoctor.value!.fullName,
        appointmentTime: appointmentDateTime,
        status: "pending",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      String appointmentId = await _firestoreService.createAppointment(
        appointment,
      );
      print("Appointment created with ID: $appointmentId");

      Get.snackbar(
        'نجاح',
        'تم حجز الموعد بنجاح! سيتم مراجعته من قبل الطبيب.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh patient's appointments
      print("Refreshing patient appointments...");
      await loadPatientAppointments();
      print("Patient appointments refreshed");

      // Navigate to patient's appointments list
      Get.offNamed(AppRoutes.PATIENT_APPOINTMENTS);
    } catch (e) {
      print("Error booking appointment: $e");
      Get.snackbar(
        'خطأ',
        'فشل في حجز الموعد: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // إلغاء موعد
  Future<void> cancelAppointment(AppointmentModel appointment) async {
    try {
      isLoading.value = true;

      final updatedAppointment = appointment.copyWith(
        status: 'cancelled',
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateAppointment(updatedAppointment);

      Get.snackbar('نجح', 'تم إلغاء الموعد بنجاح');
      loadPatientAppointments();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إلغاء الموعد: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // جلب طبيب عبر uid
  Future<DoctorModel?> getDoctorByUid(String doctorUid) async {
    try {
      return await _firestoreService.getDoctor(doctorUid);
    } catch (e) {
      return null;
    }
  }

  // تحويل رقم اليوم إلى اسم بالإنجليزية
  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  // تطبيع الأرقام العربية وتحويل 12/24 ساعة عند وجود AM/PM أو ص/م
  String _normalizeDigits(String s) {
    const eastern = [
      '\u0660',
      '\u0661',
      '\u0662',
      '\u0663',
      '\u0664',
      '\u0665',
      '\u0666',
      '\u0667',
      '\u0668',
      '\u0669',
    ];
    const extended = [
      '\u06F0',
      '\u06F1',
      '\u06F2',
      '\u06F3',
      '\u06F4',
      '\u06F5',
      '\u06F6',
      '\u06F7',
      '\u06F8',
      '\u06F9',
    ];
    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(eastern[i], i.toString());
      s = s.replaceAll(extended[i], i.toString());
    }
    return s;
  }

  TimeOfDay? _parseTime(String timeString) {
    final normalized = _normalizeDigits(timeString).trim();
    final lower = normalized.toLowerCase();

    final bool hasPM = lower.contains('pm') || lower.contains('م');
    final bool hasAM = lower.contains('am') || lower.contains('ص');

    final match = RegExp(r'(\d{1,2})\s*:\s*(\d{1,2})').firstMatch(lower);
    if (match != null) {
      int hour = int.tryParse(match.group(1)!) ?? -1;
      int minute = int.tryParse(match.group(2)!) ?? -1;

      if (hour < 0 || minute < 0 || minute > 59) return null;

      if (hasPM && hour < 12) hour += 12;
      if (hasAM && hour == 12) hour = 0;

      if (hour < 0 || hour > 23) return null;

      return TimeOfDay(hour: hour, minute: minute);
    }

    // مسار احتياطي: إزالة غير الأرقام والنقطتين
    final cleaned = lower.replaceAll(RegExp(r'[^0-9:]'), '').trim();
    final parts = cleaned.split(':');
    if (parts.length == 2) {
      try {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
        return TimeOfDay(hour: hour, minute: minute);
      } catch (_) {
        print('Error parsing time string: $timeString -> $cleaned');
        return null;
      }
    } else {
      print('Invalid time string format: $timeString -> $cleaned');
      return null;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // تحديث البيانات
  Future<void> refreshData() async {
    await Future.wait([loadDoctors(), loadPatientAppointments()]);
  }
}
