import 'package:timeago/timeago.dart' as timeago;
import 'package:untitled/app/data/models/post_type.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/cloudinary_service.dart';
import '../../../data/services/community_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/doctor_follow_service.dart';
import '../../../data/models/community_post_model.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/notification_model.dart';

class CommunityController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final CommunityService _communityService = Get.find<CommunityService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final DoctorFollowService _doctorFollowService = Get.find<DoctorFollowService>();
  final ImagePicker _imagePicker = ImagePicker();

  // Observable variables
  var isLoading = false.obs;
  var posts = <CommunityPostModel>[].obs;
  var isCreatingPost = false.obs;
  var comments = <CommentModel>[].obs;
  var showFollowedOnly = false.obs;

  // Form controllers
  final contentController = TextEditingController();
  final commentTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Media
  var selectedImage = Rx<File?>(null);
  var selectedVideo = Rx<File?>(null);

  // Current user
  UserModel? get currentUser => _authService.currentUser.value;
  String? get currentUserId => _authService.currentUserId;
  bool get isDoctor => currentUser?.userType == 'doctor';

  @override
  void onInit() {
    super.onInit();
    if (isDoctor) {
      loadDoctorPosts();
    } else {
      loadAllPosts();
    }
  }

  @override
  void onClose() {
    contentController.dispose();
    commentTextController.dispose();
    super.onClose();
  }

  void togglePostsView() {
    showFollowedOnly.value = !showFollowedOnly.value;
    if (showFollowedOnly.value) {
      loadFollowedDoctorsPosts();
    } else {
      loadAllPosts();
    }
  }

  void loadAllPosts() {
    _communityService.getAllCommunityPosts().listen(
      (data) {
        posts.value = data;
        isLoading.value = false;
      },
      onError: (e) {
        Get.snackbar('خطأ', 'فشل في تحميل المنشورات: ${e.toString()}');
        isLoading.value = false;
      },
    );
  }

  void loadFollowedDoctorsPosts() async {
    if (currentUserId == null) return;
    
    try {
      final followedDoctors = await _doctorFollowService.getFollowedDoctors(currentUserId!);
      
      if (followedDoctors.isEmpty) {
        posts.value = [];
        isLoading.value = false;
        return;
      }

      _communityService.getFollowedDoctorsPosts(followedDoctors).listen(
        (data) {
          posts.value = data;
          isLoading.value = false;
        },
        onError: (e) {
          Get.snackbar('خطأ', 'فشل في تحميل منشورات الأطباء المتابعين: ${e.toString()}');
          isLoading.value = false;
        },
      );
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل قائمة الأطباء المتابعين: ${e.toString()}');
      isLoading.value = false;
    }
  }

  void loadDoctorPosts() {
    if (currentUserId == null) return;
    _communityService
        .getDoctorCommunityPosts(currentUserId!)
        .listen(
          (data) {
            posts.value = data;
            isLoading.value = false;
          },
          onError: (e) {
            Get.snackbar('خطأ', 'فشل في تحميل منشوراتك: ${e.toString()}');
            isLoading.value = false;
          },
        );
  }

  Future<void> createPost() async {
    if (!isDoctor) {
      Get.snackbar('خطأ', 'فقط الأطباء يمكنهم إنشاء منشورات');
      return;
    }

    if (!formKey.currentState!.validate()) return;

    if (selectedImage.value == null &&
        selectedVideo.value == null &&
        contentController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى كتابة محتوى أو اختيار صورة أو فيديو للمنشور');
      return;
    }

    try {
      isCreatingPost.value = true;

      if (!CloudinaryService.isConfigured()) {
        Get.snackbar('خطأ', 'يجب إعداد Cloudinary أولاً');
        return;
      }

      final doctorProfile = await _firestoreService.getDoctor(currentUserId!);
      if (doctorProfile == null) {
        Get.snackbar('خطأ', 'لم يتم العثور على ملف الطبيب');
        return;
      }

      String? mediaUrl;
      PostType postType = PostType.text;

      if (selectedImage.value != null) {
        mediaUrl = await _uploadFile(
          selectedImage.value!,
          'community_posts/images',
        );
        postType = PostType.image;
      } else if (selectedVideo.value != null) {
        mediaUrl = await _uploadFile(
          selectedVideo.value!,
          'community_posts/videos',
        );
        postType = PostType.video;
      }

      if ((postType == PostType.image || postType == PostType.video) &&
          mediaUrl == null) {
        Get.snackbar('خطأ', 'فشل في رفع الوسائط');
        return;
      }

      final post = CommunityPostModel(
        postId: '',
        doctorUid: currentUserId!,
        doctorName: doctorProfile.clinicName,
        doctorSpecialty: doctorProfile.specialty,
        doctorLocation: doctorProfile.clinicAddress,
        doctorAverageRating: doctorProfile.averageRating,
        doctorTotalRatings: doctorProfile.totalRatings,
        postType: postType,
        mediaUrl: mediaUrl,
        content: contentController.text.trim(),
        likes: [],
        commentsCount: 0,
        createdAt: DateTime.now(),
      );

      await _communityService.addCommunityPost(post);
      _notificationService.notifyNewCommunityPost(post);

      _clearForm();
      Get.back();
      Get.snackbar('نجح', 'تم إنشاء المنشور بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إنشاء المنشور: ${e.toString()}');
    } finally {
      isCreatingPost.value = false;
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        selectedVideo.value = null;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في اختيار الصورة: ${e.toString()}');
    }
  }

  Future<void> pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        selectedVideo.value = File(video.path);
        selectedImage.value = null;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في اختيار الفيديو: ${e.toString()}');
    }
  }

  void removeSelectedMedia() {
    selectedImage.value = null;
    selectedVideo.value = null;
  }

  void _clearForm() {
    contentController.clear();
    selectedImage.value = null;
    selectedVideo.value = null;
  }

  Future<String?> _uploadFile(File file, String folder) async {
    try {
      final extension = file.path.split('.').last.toLowerCase();
      final isVideo = ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);

      if (isVideo) {
        return await CloudinaryService.uploadVideo(file, folder: folder);
      } else {
        return await CloudinaryService.uploadImage(file, folder: folder);
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> toggleLike(CommunityPostModel post) async {
    if (currentUserId == null) {
      Get.snackbar(
        'خطأ',
        'يجب تسجيل الدخول للإعجاب بالمنشورات',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      if (post.likes.contains(currentUserId)) {
        await _communityService.removeLike(post.postId, currentUserId!);
      } else {
        await _communityService.addLike(post.postId, currentUserId!);
      }
      if (isDoctor) {
        loadDoctorPosts();
      } else {
        loadAllPosts();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في الإعجاب/إلغاء الإعجاب بالمنشور: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addComment(CommunityPostModel post) async {
    if (currentUserId == null || currentUser?.fullName == null) {
      Get.snackbar(
        'خطأ',
        'يجب تسجيل الدخول للتعليق على المنشورات',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (commentTextController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'لا يمكن إضافة تعليق فارغ');
      return;
    }

    try {
      final comment = CommentModel(
        commentId: '',
        postId: post.postId,
        userId: currentUserId!,
        userName: currentUser?.fullName ?? 'مستخدم غير معروف',
        commentText: commentTextController.text.trim(),
        createdAt: DateTime.now(),
      );
      await _communityService.addComment(comment);
      _notificationService.notifyNewComment(post, comment);
      commentTextController.clear();
      loadCommentsForPost(post.postId);
      Get.snackbar('نجح', 'تم إضافة التعليق بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إضافة التعليق: ${e.toString()}');
    }
  }

  void loadCommentsForPost(String postId) {
    _communityService
        .getCommentsForPost(postId)
        .listen(
          (data) {
            comments.value = data;
          },
          onError: (e) {
            Get.snackbar('خطأ', 'فشل في تحميل التعليقات: ${e.toString()}');
          },
        );
  }

  Future<void> refreshPosts() async {
    if (isDoctor) {
      loadDoctorPosts();
    } else {
      loadAllPosts();
    }
  }

  void showCreatePostDialog() {
    if (!isDoctor) {
      Get.snackbar('خطأ', 'فقط الأطباء يمكنهم إنشاء منشورات');
      return;
    }

    Get.dialog(_CreatePostDialog(), barrierDismissible: false);
  }

  void showCommentsDialog(CommunityPostModel post) {
    loadCommentsForPost(post.postId);
    Get.dialog(_CommentsDialog(post: post), barrierDismissible: true);
  }
}

class _CreatePostDialog extends GetView<CommunityController> {
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
                const Icon(
                  Icons.add_circle,
                  color: Color(0xFF667eea),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'إنشاء منشور جديد',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: controller.contentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'محتوى المنشور',
                      hintText: 'اكتب محتوى منشورك هنا...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى كتابة محتوى المنشور';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('إضافة صورة'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.pickVideo,
                          icon: const Icon(Icons.videocam),
                          label: const Text('إضافة فيديو'),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    if (controller.selectedImage.value != null) {
                      return Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                controller.selectedImage.value!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: controller.removeSelectedMedia,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (controller.selectedVideo.value != null) {
                      return Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.videocam,
                              color: Color(0xFF667eea),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'فيديو محدد: ${controller.selectedVideo.value!.path.split('/').last}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            GestureDetector(
                              onTap: controller.removeSelectedMedia,
                              child: const Icon(Icons.close, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                      onPressed: controller.isCreatingPost.value
                          ? null
                          : controller.createPost,
                      child: controller.isCreatingPost.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('نشر'),
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

class _CommentsDialog extends GetView<CommunityController> {
  final CommunityPostModel post;

  const _CommentsDialog({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.comment, color: Color(0xFF667eea), size: 24),
                const SizedBox(width: 12),
                const Text(
                  'التعليقات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (controller.comments.isEmpty) {
                  return const Center(child: Text('لا توجد تعليقات بعد.'));
                }
                return ListView.builder(
                  itemCount: controller.comments.length,
                  itemBuilder: (context, index) {
                    final comment = controller.comments[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade50,
                            Colors.purple.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF667eea).withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                      Text(
                                        timeago.format(comment.createdAt, locale: 'ar'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                comment.commentText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2D3748),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.commentTextController,
                    decoration: InputDecoration(
                      hintText: 'أضف تعليقاً...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () => controller.addComment(post),
                  mini: true,
                  backgroundColor: const Color(0xFF667eea),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
