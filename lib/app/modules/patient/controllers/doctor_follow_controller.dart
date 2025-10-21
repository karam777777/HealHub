import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/doctor_follow_service.dart';

class DoctorFollowController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DoctorFollowService _doctorFollowService = Get.find<DoctorFollowService>();

  var isFollowing = <String, bool>{}.obs;
  var followersCount = <String, int>{}.obs;
  var isLoading = <String, bool>{}.obs;

  String? get currentUserId => _authService.currentUserId;

  // Check if patient is following a doctor
  Future<void> checkFollowStatus(String doctorUid) async {
    if (currentUserId == null) return;

    try {
      final following = await _doctorFollowService.isFollowingDoctor(
        currentUserId!,
        doctorUid,
      );
      isFollowing[doctorUid] = following;
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  // Get followers count for a doctor
  Future<void> getFollowersCount(String doctorUid) async {
    try {
      final count = await _doctorFollowService.getDoctorFollowersCount(doctorUid);
      followersCount[doctorUid] = count;
    } catch (e) {
      print('Error getting followers count: $e');
    }
  }

  // Toggle follow/unfollow
  Future<void> toggleFollow(String doctorUid) async {
    if (currentUserId == null) {
      Get.snackbar('خطأ', 'يجب تسجيل الدخول أولاً');
      return;
    }

    try {
      isLoading[doctorUid] = true;
      
      final currentlyFollowing = isFollowing[doctorUid] ?? false;
      
      if (currentlyFollowing) {
        await _doctorFollowService.unfollowDoctor(currentUserId!, doctorUid);
        isFollowing[doctorUid] = false;
        followersCount[doctorUid] = (followersCount[doctorUid] ?? 1) - 1;
        Get.snackbar(
          'تم إلغاء المتابعة',
          'تم إلغاء متابعة الطبيب بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        await _doctorFollowService.followDoctor(currentUserId!, doctorUid);
        isFollowing[doctorUid] = true;
        followersCount[doctorUid] = (followersCount[doctorUid] ?? 0) + 1;
        Get.snackbar(
          'تمت المتابعة',
          'تمت متابعة الطبيب بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديث حالة المتابعة: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading[doctorUid] = false;
    }
  }

  // Initialize follow status and count for a doctor
  Future<void> initializeDoctorData(String doctorUid) async {
    await Future.wait([
      checkFollowStatus(doctorUid),
      getFollowersCount(doctorUid),
    ]);
  }

  // Get follow status for a doctor
  bool getFollowStatus(String doctorUid) {
    return isFollowing[doctorUid] ?? false;
  }

  // Get followers count for a doctor
  int getFollowersCountValue(String doctorUid) {
    return followersCount[doctorUid] ?? 0;
  }

  // Check if loading for a doctor
  bool isLoadingForDoctor(String doctorUid) {
    return isLoading[doctorUid] ?? false;
  }
}

