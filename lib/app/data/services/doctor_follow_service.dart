import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/doctor_follow_model.dart';

class DoctorFollowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  static const String DOCTOR_FOLLOWS_COLLECTION = 'doctor_follows';

  // Follow a doctor
  Future<void> followDoctor(String patientUid, String doctorUid) async {
    final followId = _uuid.v4();
    final follow = DoctorFollowModel(
      followId: followId,
      patientUid: patientUid,
      doctorUid: doctorUid,
      followedAt: DateTime.now(),
    );

    await _firestore
        .collection(DOCTOR_FOLLOWS_COLLECTION)
        .doc(followId)
        .set(follow.toMap());
  }

  // Unfollow a doctor
  Future<void> unfollowDoctor(String patientUid, String doctorUid) async {
    final querySnapshot = await _firestore
        .collection(DOCTOR_FOLLOWS_COLLECTION)
        .where('patientUid', isEqualTo: patientUid)
        .where('doctorUid', isEqualTo: doctorUid)
        .get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Check if patient is following a doctor
  Future<bool> isFollowingDoctor(String patientUid, String doctorUid) async {
    final querySnapshot = await _firestore
        .collection(DOCTOR_FOLLOWS_COLLECTION)
        .where('patientUid', isEqualTo: patientUid)
        .where('doctorUid', isEqualTo: doctorUid)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Get list of doctors that a patient is following
  Future<List<String>> getFollowedDoctors(String patientUid) async {
    final querySnapshot = await _firestore
        .collection(DOCTOR_FOLLOWS_COLLECTION)
        .where('patientUid', isEqualTo: patientUid)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data()['doctorUid'] as String)
        .toList();
  }

  // Get followers count for a doctor
  Future<int> getDoctorFollowersCount(String doctorUid) async {
    final querySnapshot = await _firestore
        .collection(DOCTOR_FOLLOWS_COLLECTION)
        .where('doctorUid', isEqualTo: doctorUid)
        .get();

    return querySnapshot.docs.length;
  }

  // Get list of patients following a doctor
  Future<List<String>> getDoctorFollowers(String doctorUid) async {
    final querySnapshot = await _firestore
        .collection(DOCTOR_FOLLOWS_COLLECTION)
        .where('doctorUid', isEqualTo: doctorUid)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data()['patientUid'] as String)
        .toList();
  }

  // Stream to listen to follow status changes
  Stream<bool> isFollowingDoctorStream(String patientUid, String doctorUid) {
    return _firestore
        .collection(DOCTOR_FOLLOWS_COLLECTION)
        .where('patientUid', isEqualTo: patientUid)
        .where('doctorUid', isEqualTo: doctorUid)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  // Stream to listen to followers count changes
  Stream<int> getDoctorFollowersCountStream(String doctorUid) {
    return _firestore
        .collection(DOCTOR_FOLLOWS_COLLECTION)
        .where('doctorUid', isEqualTo: doctorUid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

