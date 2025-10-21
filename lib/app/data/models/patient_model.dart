import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String uid;
  final String fullName;
  final DateTime? dob;
  final String? gender;
  final String? address;

  PatientModel({
    required this.uid,
    required this.fullName,
    this.dob,
    this.gender,
    this.address,
  });

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      dob: map['dob'] != null ? (map['dob'] as Timestamp).toDate() : null,
      gender: map['gender'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'gender': gender,
      'address': address,
    };
  }

  PatientModel copyWith({
    String? uid,
    String? fullName,
    DateTime? dob,
    String? gender,
    String? address,
  }) {
    return PatientModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      address: address ?? this.address,
    );
  }
}


