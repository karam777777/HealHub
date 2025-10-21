import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorFollowModel {
  final String followId;
  final String patientUid;
  final String doctorUid;
  final DateTime followedAt;

  DoctorFollowModel({
    required this.followId,
    required this.patientUid,
    required this.doctorUid,
    required this.followedAt,
  });

  factory DoctorFollowModel.fromMap(Map<String, dynamic> map) {
    return DoctorFollowModel(
      followId: map['followId'] ?? '',
      patientUid: map['patientUid'] ?? '',
      doctorUid: map['doctorUid'] ?? '',
      followedAt: (map['followedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'followId': followId,
      'patientUid': patientUid,
      'doctorUid': doctorUid,
      'followedAt': Timestamp.fromDate(followedAt),
    };
  }

  DoctorFollowModel copyWith({
    String? followId,
    String? patientUid,
    String? doctorUid,
    DateTime? followedAt,
  }) {
    return DoctorFollowModel(
      followId: followId ?? this.followId,
      patientUid: patientUid ?? this.patientUid,
      doctorUid: doctorUid ?? this.doctorUid,
      followedAt: followedAt ?? this.followedAt,
    );
  }
}

