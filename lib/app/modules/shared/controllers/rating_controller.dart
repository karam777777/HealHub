import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/models/rating_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/patient_model.dart';

class RatingController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Observable variables
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var selectedRating = 0.0.obs;
  var doctorRatings = <RatingModel>[].obs;
  var doctorStats = Rx<DoctorRatingStats?>(null);

  // Form controllers
  final commentController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Current user
  UserModel? get currentUser => _authService.currentUser.value;
  String? get currentUserId => _authService.currentUserId;
  bool get isPatient => currentUser?.userType == 'patient';

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  // Load doctor ratings
  Future<void> loadDoctorRatings(String doctorId) async {
    try {
      isLoading.value = true;

      final ratings = await _firestoreService.getDoctorRatings(doctorId);
      doctorRatings.value = ratings;
      doctorStats.value = DoctorRatingStats.fromRatings(ratings);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل التقييمات: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Submit rating
  Future<void> submitRating(String doctorId) async {
    if (!isPatient) {
      Get.snackbar('خطأ', 'فقط المرضى يمكنهم تقييم الأطباء');
      return;
    }

    if (selectedRating.value == 0) {
      Get.snackbar('خطأ', 'يرجى اختيار تقييم');
      return;
    }

    if (!formKey.currentState!.validate()) return;

    try {
      isSubmitting.value = true;

      // Check if patient already rated this doctor
      final existingRating = await _firestoreService.getPatientRatingForDoctor(
        currentUserId!,
        doctorId,
      );

      // Get patient profile for name
      final patientProfile = await _firestoreService.getPatient(currentUserId!);
      if (patientProfile == null) {
        Get.snackbar('خطأ', 'لم يتم العثور على ملف المريض');
        return;
      }

      final rating = RatingModel(
        id: existingRating?.id ?? '',
        doctorId: doctorId,
        patientId: currentUserId!,
        patientName: patientProfile.uid,
        rating: selectedRating.value,
        comment: commentController.text.trim(),
        createdAt: existingRating?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (existingRating != null) {
        // Update existing rating
        await _firestoreService.updateRating(rating);
        Get.snackbar('نجح', 'تم تحديث التقييم بنجاح');
      } else {
        // Create new rating
        await _firestoreService.createRating(rating);
        _notificationService.notifyDoctorNewRating(rating);
        Get.snackbar('نجح', 'تم إضافة التقييم بنجاح');
      }

      // Clear form
      _clearForm();

      Get.back(); // Close rating dialog

      // Reload ratings
      loadDoctorRatings(doctorId);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إرسال التقييم: ${e.toString()}');
    } finally {
      isSubmitting.value = false;
    }
  }

  // Check if patient can rate doctor
  Future<bool> canRateDoctor(String doctorId) async {
    if (!isPatient || currentUserId == null) return false;

    // Check if patient has had an appointment with this doctor
    final hasAppointment = await _firestoreService
        .hasPatientAppointmentWithDoctor(currentUserId!, doctorId);

    return hasAppointment;
  }

  // Load existing rating for editing
  Future<void> loadExistingRating(String doctorId) async {
    if (!isPatient || currentUserId == null) return;

    try {
      final existingRating = await _firestoreService.getPatientRatingForDoctor(
        currentUserId!,
        doctorId,
      );

      if (existingRating != null) {
        selectedRating.value = existingRating.rating;
        commentController.text = existingRating.comment;
      }
    } catch (e) {
      print('Error loading existing rating: $e');
    }
  }

  // Clear form
  void _clearForm() {
    selectedRating.value = 0.0;
    commentController.clear();
  }

  // Show rating dialog
  void showRatingDialog(String doctorId, String doctorName) {
    if (!isPatient) {
      Get.snackbar('خطأ', 'فقط المرضى يمكنهم تقييم الأطباء');
      return;
    }

    // Load existing rating if any
    loadExistingRating(doctorId);

    Get.dialog(
      _RatingDialog(doctorId: doctorId, doctorName: doctorName),
      barrierDismissible: false,
    );
  }

  // Get rating color
  Color getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.5) return Colors.orange;
    if (rating >= 3.0) return Colors.deepOrange;
    return Colors.red;
  }
}

// Rating Dialog Widget
class _RatingDialog extends GetView<RatingController> {
  final String doctorId;
  final String doctorName;

  const _RatingDialog({required this.doctorId, required this.doctorName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,

        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Color(0xFF667eea),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تقييم الطبيب',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        'د. $doctorName',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Star rating
                  const Text(
                    'التقييم',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        final isSelected =
                            controller.selectedRating.value >= starValue;

                        return GestureDetector(
                          onTap: () =>
                              controller.selectedRating.value = starValue,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              isSelected ? Icons.star : Icons.star_border,
                              size: 32,
                              color: isSelected
                                  ? Colors.amber
                                  : Colors.grey[400],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Comment field
                  TextFormField(
                    controller: controller.commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'تعليق (اختياري)',
                      hintText: 'شاركنا تجربتك مع الطبيب...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      // Comment is optional
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () => controller.submitRating(doctorId),
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('إرسال'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
