import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionModel {
  final String prescriptionId;
  final String appointmentId;
  final String doctorUid;
  final String patientUid;
  final String prescriptionText;
  final DateTime createdAt;
  final String? notes;
  final List<String>? medications;
  final String? diagnosis;

  PrescriptionModel({
    required this.prescriptionId,
    required this.appointmentId,
    required this.doctorUid,
    required this.patientUid,
    required this.prescriptionText,
    required this.createdAt,
    this.notes,
    this.medications,
    this.diagnosis,
  });

  factory PrescriptionModel.fromMap(Map<String, dynamic> map) {
    return PrescriptionModel(
      prescriptionId: map['prescriptionId'] ?? '',
      appointmentId: map['appointmentId'] ?? '',
      doctorUid: map['doctorUid'] ?? '',
      patientUid: map['patientUid'] ?? '',
      prescriptionText: map['prescriptionText'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      notes: map['notes'],
      medications: map['medications'] != null ? List<String>.from(map['medications']) : null,
      diagnosis: map['diagnosis'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prescriptionId': prescriptionId,
      'appointmentId': appointmentId,
      'doctorUid': doctorUid,
      'patientUid': patientUid,
      'prescriptionText': prescriptionText,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
      'medications': medications,
      'diagnosis': diagnosis,
    };
  }

  PrescriptionModel copyWith({
    String? prescriptionId,
    String? appointmentId,
    String? doctorUid,
    String? patientUid,
    String? prescriptionText,
    DateTime? createdAt,
    String? notes,
    List<String>? medications,
    String? diagnosis,
  }) {
    return PrescriptionModel(
      prescriptionId: prescriptionId ?? this.prescriptionId,
      appointmentId: appointmentId ?? this.appointmentId,
      doctorUid: doctorUid ?? this.doctorUid,
      patientUid: patientUid ?? this.patientUid,
      prescriptionText: prescriptionText ?? this.prescriptionText,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      medications: medications ?? this.medications,
      diagnosis: diagnosis ?? this.diagnosis,
    );
  }
}

