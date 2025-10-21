import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ما نعمل Get.find هنا حتى لا  يفشل وقت الإنشاء
  late final FirestoreService _firestoreService;

  // حالتان تفاعليتان
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();

    // تأكد أن FirestoreService مسجّل قبل استعماله (تحصين ضد ترتيب التسجيل)
    if (!Get.isRegistered<FirestoreService>()) {
      // لو بدك تتجنّب التسجيل التلقائي واحترام الـ InitialBinding فقط، اشطب السطر التالي
      Get.put<FirestoreService>(FirestoreService(), permanent: true);
    }
    _firestoreService = Get.find<FirestoreService>();

    // اربط ستريم المستخدم
    firebaseUser.bindStream(_auth.userChanges());

    // راقب التغيّرات وبدّل الشاشة وفق الحالة
    ever<User?>(firebaseUser, _setInitialScreen);
  }

  Future<void> _setInitialScreen(User? user) async {
    try {
      if (user == null) {
        currentUser.value = null;
        Get.offAllNamed('/login');
        return;
      }

      // جلب نموذج المستخدم من فايرستور
      final userModel = await _firestoreService.getUser(user.uid);

      if (userModel != null) {
        currentUser.value = userModel;
        if (userModel.userType == 'doctor') {
          Get.offAllNamed('/doctor-home');
        } else {
          Get.offAllNamed('/patient-home');
        }
      } else {
        // مستخدم جديد بدون بروفايل
        Get.offAllNamed('/user-type-selection');
      }
    } catch (e) {
      // لو صار خطأ (مثلاً لم تُهيأ الفايرستور)، رجّع المستخدم لشاشة البداية الآمنة
      Get.snackbar('خطأ', 'حدث خطأ أثناء تحديد الشاشة: $e');
      Get.offAllNamed('/login');
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      if (user != null) {
        currentUser.value = await _firestoreService.getUser(user.uid);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تسجيل الدخول: ${e.toString()}');
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user != null;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إنشاء الحساب: ${e.toString()}');
      return false;
    }
  }

  Future<bool> createUserProfile({
    required String fullName,
    required String userType,
    String? phoneNumber,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // في حالة Email/Password يكون الإيميل غير null عادةً
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        userType: userType,
        fullName: fullName,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.createUser(userModel);
      currentUser.value = userModel;
      return true;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إنشاء الملف الشخصي: ${e.toString()}');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      currentUser.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تسجيل الخروج: ${e.toString()}');
    }
  }

  bool get isLoggedIn => firebaseUser.value != null;
  String? get currentUserId => firebaseUser.value?.uid;
}