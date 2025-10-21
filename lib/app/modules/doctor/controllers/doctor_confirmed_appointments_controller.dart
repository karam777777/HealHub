import 'package:get/get.dart';
import 'package:untitled/app/data/models/appointment_model.dart';
import 'package:untitled/app/data/services/firestore_service.dart';
import 'package:untitled/app/data/services/auth_service.dart';
import 'package:untitled/app/data/models/user_model.dart';

class DoctorConfirmedAppointmentsController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  var isLoading = false.obs;
  var selectedDate = DateTime.now().obs;
  var confirmedAppointments = <AppointmentModel>[].obs;
  var currentAppointmentIndex = (-1).obs;
  var currentPatientName = ''.obs; // Observable for current patient name

  @override
  void onInit() {
    super.onInit();
    _authService.firebaseUser.listen((user) {
      if (user != null) {
        loadConfirmedAppointments(selectedDate.value);
      }
    });
    // Listen to changes in confirmedAppointments to update current patient name
    ever(confirmedAppointments, (_) => _updateCurrentPatientName());
  }

  Future<void> loadConfirmedAppointments(DateTime date) async {
    if (_authService.currentUserId == null) return;
    isLoading.value = true;
    try {
      final appointments = await _firestoreService.getConfirmedAppointments(
        _authService.currentUserId!,
        date,
      );
      confirmedAppointments.assignAll(appointments);
      _updateCurrentAppointmentIndex();
      _updateCurrentPatientName(); // Update patient name after loading appointments
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل المواعيد المؤكدة: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void changeDate(DateTime newDate) {
    selectedDate.value = newDate;
    loadConfirmedAppointments(newDate);
  }

  void _updateCurrentAppointmentIndex() {
    final now = DateTime.now();
    int index = -1;
    // Sort appointments by time to ensure correct order
    confirmedAppointments.sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));

    for (int i = 0; i < confirmedAppointments.length; i++) {
      final appointmentTime = confirmedAppointments[i].appointmentTime;
      // Find the first appointment that is at or after the current time
      if (appointmentTime.isAfter(now) || appointmentTime.isAtSameMomentAs(now)) {
        index = i;
        break;
      }
    }
    // If no future appointments, set to the last appointment
    if (index == -1 && confirmedAppointments.isNotEmpty) {
      index = confirmedAppointments.length - 1;
    }
    currentAppointmentIndex.value = index;
  }

  Future<void> _updateCurrentPatientName() async {
    if (currentAppointmentIndex.value != -1 && confirmedAppointments.isNotEmpty) {
      final currentAppointment = confirmedAppointments[currentAppointmentIndex.value];
      final patientUid = currentAppointment.patientUid;
      try {
        final UserModel? patient = await _firestoreService.getUser(patientUid);
        currentPatientName.value = patient?.fullName ?? 'مريض غير معروف';
      } catch (e) {
        print('Error fetching patient name: $e');
        currentPatientName.value = 'مريض غير معروف';
      }
    } else {
      currentPatientName.value = '';
    }
  }

  Future<void> completeAppointment(AppointmentModel appointment) async {
    try {
      final updatedAppointment = appointment.copyWith(status: 'completed');
      await _firestoreService.updateAppointment(updatedAppointment);
      Get.snackbar('نجاح', 'تم إتمام الموعد بنجاح');
      loadConfirmedAppointments(selectedDate.value);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إتمام الموعد: ${e.toString()}');
    }
  }

  bool hasPrescription(AppointmentModel appointment) {
    return appointment.hasPrescription;
  }

  void markPrescriptionAdded(String appointmentId) {
    // This method would update the UI to reflect that a prescription has been added
    // For now, it's a placeholder.
    print('Prescription added for appointment: $appointmentId');
  }
}
