import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String appointmentId;
  final String patientUid;
  final String patientName;
  final String patientEmail;
  final String doctorUid;
  final String doctorName;
  final DateTime appointmentTime;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hasPrescription; // New fi
  AppointmentModel({
    required this.appointmentId,
    required this.patientUid,
    required this.patientName,
    required this.patientEmail,
    required this.doctorUid,
    required this.doctorName,
    required this.appointmentTime,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.hasPrescription = false, // Default value
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      appointmentId: map['appointmentId'] ?? '',
      patientUid: map['patientUid'] ?? '',
      patientName: map['patientName'] ?? '',
      patientEmail: map["patientEmail"] ?? "",
      doctorUid: map["doctorUid"] ?? "",
      doctorName: map["doctorName"] ?? "",
      appointmentTime: (map["appointmentTime"] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      hasPrescription: map['hasPrescription'] ?? false, // Read new field 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'patientUid': patientUid,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'doctorUid': doctorUid,
      'doctorName': doctorName,
      'appointmentTime': Timestamp.fromDate(appointmentTime),
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'hasPrescription': hasPrescription, // Write new field
    };
  }

  AppointmentModel copyWith({
    String? appointmentId,
    String? patientUid,
    String? patientName,
    String? patientEmail,
    String? doctorUid,
    String? doctorName,
    DateTime? appointmentTime,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasPrescription,
  }) {
    return AppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,
      patientUid: patientUid ?? this.patientUid,
      patientName: patientName ?? this.patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      doctorUid: doctorUid ?? this.doctorUid,
      doctorName: doctorName ?? this.doctorName,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasPrescription: hasPrescription ?? this.hasPrescription,
    );
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}


