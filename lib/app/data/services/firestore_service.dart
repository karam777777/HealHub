import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../models/doctor_model.dart';
import '../models/patient_model.dart';
import '../models/appointment_model.dart';
import '../models/prescription_model.dart';
import '../models/notification_model.dart';
import '../models/post_model.dart';
import '../models/rating_model.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  // Collections
  static const String USERS_COLLECTION = 'users';
  static const String DOCTORS_COLLECTION = 'doctors';
  static const String PATIENTS_COLLECTION = 'patients';
  static const String APPOINTMENTS_COLLECTION = 'appointments';
  static const String PRESCRIPTIONS_COLLECTION = 'prescriptions';
  static const String NOTIFICATIONS_COLLECTION = 'notifications';
  static const String POSTS_COLLECTION = 'posts';
  static const String RATINGS_COLLECTION = 'ratings';
  // User operations
  Future<void> createUser(UserModel user) async {
    await _db.collection(USERS_COLLECTION).doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot doc = await _db
        .collection(USERS_COLLECTION)
        .doc(uid)
        .get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection(USERS_COLLECTION).doc(user.uid).update(user.toMap());
  }

  Future<void> updateUserToken(String uid, String? token) async {
    await _db.collection(USERS_COLLECTION).doc(uid).update({
      'fcmToken': token,
      'updatedAt': Timestamp.now(),
    });
  }

  // Doctor operations
  Future<void> createDoctor(DoctorModel doctor) async {
    try {
      print('Attempting to create doctor: ${doctor.uid}');
      print('Doctor data: ${doctor.toMap()}');
      DoctorModel doctorToCreate = doctor.copyWith(
        averageRating: doctor.averageRating ?? 0.0,
        totalRatings: doctor.totalRatings ?? 0,
      );
      await _db
          .collection(DOCTORS_COLLECTION)
          .doc(doctorToCreate.uid)
          .set(doctorToCreate.toMap());
      print('Doctor created successfully in Firestore.');
    } catch (e) {
      print('Error creating doctor in Firestore: $e');
      rethrow; // إعادة رمي الخطأ ليتم التقاطه في AuthController
    }
  }

  Future<String?> getUserToken(String uid) async {
    try {
      final doc = await _db.collection(USERS_COLLECTION).doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        return data?['fcmToken'] as String?;
      }
      return null;
    } catch (e) {
      print("Error while fetching user token: $e");
      return null;
    }
  }

  Future<DoctorModel?> getDoctor(String uid) async {
    DocumentSnapshot doc = await _db
        .collection(DOCTORS_COLLECTION)
        .doc(uid)
        .get();
    if (doc.exists) {
      return DoctorModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateDoctor(DoctorModel doctor) async {
    await _db
        .collection(DOCTORS_COLLECTION)
        .doc(doctor.uid)
        .update(doctor.toMap());
  }

  Future<List<DoctorModel>> getAllDoctors() async {
    QuerySnapshot snapshot = await _db.collection(DOCTORS_COLLECTION).get();
    return snapshot.docs
        .map((doc) => DoctorModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<DoctorModel>> getDoctorsStream() {
    return _db
        .collection(DOCTORS_COLLECTION)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DoctorModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Patient operations
  Future<void> createPatient(PatientModel patient) async {
    await _db
        .collection(PATIENTS_COLLECTION)
        .doc(patient.uid)
        .set(patient.toMap());
  }

  Future<PatientModel?> getPatient(String uid) async {
    DocumentSnapshot doc = await _db
        .collection(PATIENTS_COLLECTION)
        .doc(uid)
        .get();
    if (doc.exists) {
      return PatientModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updatePatient(PatientModel patient) async {
    await _db
        .collection(PATIENTS_COLLECTION)
        .doc(patient.uid)
        .update(patient.toMap());
  }

  Future<List<String>> getAllPatientUids() async {
    QuerySnapshot snapshot = await _db.collection(PATIENTS_COLLECTION).get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Appointment operations
  Future<String> createAppointment(AppointmentModel appointment) async {
    String appointmentId = _uuid.v4();
    AppointmentModel newAppointment = appointment.copyWith(
      appointmentId: appointmentId,
    );
    await _db
        .collection(APPOINTMENTS_COLLECTION)
        .doc(appointmentId)
        .set(newAppointment.toMap());
    return appointmentId;
  }

  Future<AppointmentModel?> getAppointment(String appointmentId) async {
    DocumentSnapshot doc = await _db
        .collection(APPOINTMENTS_COLLECTION)
        .doc(appointmentId)
        .get();
    if (doc.exists) {
      return AppointmentModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateAppointment(AppointmentModel appointment) async {
    await _db
        .collection(APPOINTMENTS_COLLECTION)
        .doc(appointment.appointmentId)
        .update(appointment.toMap());
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await _db.collection(APPOINTMENTS_COLLECTION).doc(appointmentId).delete();
  }

  Future<List<AppointmentModel>> getConfirmedAppointments(
    String doctorUid,
    DateTime date,
  ) async {
    print(
      "Firestore: Getting confirmed appointments for doctor: $doctorUid on date: $date",
    );
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    print("Firestore: Date range: $startOfDay to $endOfDay");
    QuerySnapshot snapshot = await _db
        .collection(APPOINTMENTS_COLLECTION)
        .where('doctorUid', isEqualTo: doctorUid)
        .where('status', isEqualTo: 'confirmed')
        .where(
          'appointmentTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'appointmentTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
        )
        .orderBy('appointmentTime')
        .get();
    print(
      "Firestore: Found ${snapshot.docs.length} confirmed appointment documents for doctor",
    );
    List<AppointmentModel> appointments = snapshot.docs.map((doc) {
      print("Firestore: Processing confirmed appointment doc: ${doc.id}");
      return AppointmentModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
    print(
      "Firestore: Returning ${appointments.length} confirmed appointment models for doctor",
    );
    return appointments;
  }

  Stream<List<AppointmentModel>> getConfirmedAppointmentsStream(
    String doctorUid,
    DateTime date,
  ) {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return _db
        .collection(APPOINTMENTS_COLLECTION)
        .where('doctorUid', isEqualTo: doctorUid)
        .where('status', isEqualTo: 'confirmed')
        .where(
          'appointmentTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'appointmentTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
        )
        .orderBy('appointmentTime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppointmentModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<List<AppointmentModel>> getDoctorAppointments(
    String doctorUid,
    DateTime date,
  ) async {
    print(
      "Firestore: Getting appointments for doctor: $doctorUid on date: $date",
    );
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    print("Firestore: Date range: $startOfDay to $endOfDay");
    QuerySnapshot snapshot = await _db
        .collection(APPOINTMENTS_COLLECTION)
        .where('doctorUid', isEqualTo: doctorUid)
        .where(
          'appointmentTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'appointmentTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
        )
        .orderBy('appointmentTime')
        .get();
    print(
      "Firestore: Found ${snapshot.docs.length} appointment documents for doctor",
    );
    List<AppointmentModel> appointments = snapshot.docs.map((doc) {
      print("Firestore: Processing doctor appointment doc: ${doc.id}");
      return AppointmentModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
    print(
      "Firestore: Returning ${appointments.length} appointment models for doctor",
    );
    return appointments;
  }

  Stream<List<AppointmentModel>> getDoctorAppointmentsStream(
    String doctorUid,
    DateTime date,
  ) {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return _db
        .collection(APPOINTMENTS_COLLECTION)
        .where('doctorUid', isEqualTo: doctorUid)
        .where(
          'appointmentTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'appointmentTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
        )
        .orderBy('appointmentTime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppointmentModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<List<AppointmentModel>> getPatientAppointments(
    String patientUid,
  ) async {
    print("Firestore: Getting appointments for patient: $patientUid");
    QuerySnapshot snapshot = await _db
        .collection(APPOINTMENTS_COLLECTION)
        .where('patientUid', isEqualTo: patientUid)
        .orderBy('appointmentTime', descending: true)
        .get();
    print("Firestore: Found ${snapshot.docs.length} appointment documents");
    List<AppointmentModel> appointments = snapshot.docs.map((doc) {
      print("Firestore: Processing appointment doc: ${doc.id}");
      return AppointmentModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
    print("Firestore: Returning ${appointments.length} appointment models");
    return appointments;
  }

  Stream<List<AppointmentModel>> getPatientAppointmentsStream(
    String patientUid,
  ) {
    return _db
        .collection(APPOINTMENTS_COLLECTION)
        .where('patientUid', isEqualTo: patientUid)
        .orderBy('appointmentTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppointmentModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Prescription operations
  Future<String> createPrescription(PrescriptionModel prescription) async {
    String prescriptionId = _uuid.v4();
    PrescriptionModel newPrescription = prescription.copyWith(
      prescriptionId: prescriptionId,
    );
    await _db
        .collection(PRESCRIPTIONS_COLLECTION)
        .doc(prescriptionId)
        .set(newPrescription.toMap());

    // Update the corresponding appointment to mark that a prescription has been added
    await _db.collection(APPOINTMENTS_COLLECTION).doc(prescription.appointmentId).update({
      'hasPrescription': true,
      'updatedAt': Timestamp.now(),
    });

    return prescriptionId;
  }

  Future<List<PrescriptionModel>> getPatientPrescriptions(
    String patientUid,
    String doctorUid,
  ) async {
    QuerySnapshot snapshot = await _db
        .collection(PRESCRIPTIONS_COLLECTION)
        .where('patientUid', isEqualTo: patientUid)
        .where('doctorUid', isEqualTo: doctorUid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map(
          (doc) =>
              PrescriptionModel.fromMap(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<PrescriptionModel>> getAllPatientPrescriptions(
    String patientUid,
  ) async {
    QuerySnapshot snapshot = await _db
        .collection(PRESCRIPTIONS_COLLECTION)
        .where('patientUid', isEqualTo: patientUid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map(
          (doc) =>
              PrescriptionModel.fromMap(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Stream<List<PrescriptionModel>> getPatientPrescriptionsStream(
    String patientUid,
    String doctorUid,
  ) {
    return _db
        .collection(PRESCRIPTIONS_COLLECTION)
        .where('patientUid', isEqualTo: patientUid)
        .where('doctorUid', isEqualTo: doctorUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PrescriptionModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Notification operations
  Future<String> createNotification(NotificationModel notification) async {
    String notificationId = _uuid.v4();
    NotificationModel newNotification = notification.copyWith(
      notificationId: notificationId,
    );
    await _db
        .collection(NOTIFICATIONS_COLLECTION)
        .doc(notificationId)
        .set(newNotification.toMap());
    return notificationId;
  }

  Future<void> updateNotification(NotificationModel notification) async {
    await _db
        .collection(NOTIFICATIONS_COLLECTION)
        .doc(notification.notificationId)
        .update(notification.toMap());
  }

  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    QuerySnapshot snapshot = await _db
        .collection(NOTIFICATIONS_COLLECTION)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map(
          (doc) =>
              NotificationModel.fromMap(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Stream<List<NotificationModel>> getUserNotificationsStream(String userId) {
    return _db
        .collection(NOTIFICATIONS_COLLECTION)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    QuerySnapshot snapshot = await _db
        .collection(NOTIFICATIONS_COLLECTION)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    WriteBatch batch = _db.batch();
    for (DocumentSnapshot doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> clearUserNotifications(String userId) async {
    QuerySnapshot snapshot = await _db
        .collection(NOTIFICATIONS_COLLECTION)
        .where('userId', isEqualTo: userId)
        .get();

    WriteBatch batch = _db.batch();
    for (DocumentSnapshot doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Posts operations
  Future<void> createPost(PostModel post) async {
    String postId = _uuid.v4();
    PostModel postWithId = post.copyWith(id: postId);
    await _db
        .collection(POSTS_COLLECTION)
        .doc(postId)
        .set(postWithId.toFirestore());
  }

  Future<List<PostModel>> getAllPosts() async {
    QuerySnapshot snapshot = await _db
        .collection(POSTS_COLLECTION)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
  }

  Future<List<PostModel>> getDoctorPosts(String doctorId) async {
    QuerySnapshot snapshot = await _db
        .collection(POSTS_COLLECTION)
        .where('doctorId', isEqualTo: doctorId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
  }

  Future<void> updatePost(PostModel post) async {
    await _db
        .collection(POSTS_COLLECTION)
        .doc(post.id)
        .update(post.toFirestore());
  }

  Future<void> deletePost(String postId) async {
    await _db.collection(POSTS_COLLECTION).doc(postId).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<List<PostModel>> getPostsStream() {
    return _db
        .collection(POSTS_COLLECTION)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList(),
        );
  }

  // Ratings operations
  Future<void> createRating(RatingModel rating) async {
    String ratingId = _uuid.v4();
    RatingModel ratingWithId = rating.copyWith(id: ratingId);
    await _db
        .collection(RATINGS_COLLECTION)
        .doc(ratingId)
        .set(ratingWithId.toFirestore());
  }

  Future<void> updateRating(RatingModel rating) async {
    await _db
        .collection(RATINGS_COLLECTION)
        .doc(rating.id)
        .update(rating.toFirestore());
  }

  Future<List<RatingModel>> getDoctorRatings(String doctorId) async {
    QuerySnapshot snapshot = await _db
        .collection(RATINGS_COLLECTION)
        .where('doctorId', isEqualTo: doctorId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
  }

  Future<RatingModel?> getPatientRatingForDoctor(
    String patientId,
    String doctorId,
  ) async {
    QuerySnapshot snapshot = await _db
        .collection(RATINGS_COLLECTION)
        .where('patientId', isEqualTo: patientId)
        .where('doctorId', isEqualTo: doctorId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return RatingModel.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  Future<double?> getDoctorAverageRating(String doctorId) async {
    QuerySnapshot snapshot = await _db
        .collection(RATINGS_COLLECTION)
        .where('doctorId', isEqualTo: doctorId)
        .where('isActive', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) return null;

    double totalRating = 0;
    for (var doc in snapshot.docs) {
      final rating = RatingModel.fromFirestore(doc);
      totalRating += rating.rating;
    }

    return totalRating / snapshot.docs.length;
  }

  Future<bool> hasPatientAppointmentWithDoctor(
    String patientId,
    String doctorId,
  ) async {
    QuerySnapshot snapshot = await _db
        .collection(APPOINTMENTS_COLLECTION)
        .where('patientUid', isEqualTo: patientId)
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'completed')
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> deleteRating(String ratingId) async {
    await _db.collection(RATINGS_COLLECTION).doc(ratingId).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }
}
