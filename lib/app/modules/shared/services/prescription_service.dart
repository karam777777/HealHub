import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../../../data/models/appointment_model.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/prescription_model.dart';
import '../../../data/services/firestore_service.dart';

class PrescriptionService extends GetxService {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // Generate prescription PDF content
  String generatePrescriptionPDF(
    PrescriptionModel prescription,
    DoctorModel doctor,
    String patientName,
    AppointmentModel? appointment,
  ) {
    StringBuffer content = StringBuffer();
    
    content.writeln('=== وصفة طبية ===\n');
    
    // Doctor info
    content.writeln('معلومات الطبيب:');
    content.writeln('الاسم: ${doctor.clinicName}');
    content.writeln('التخصص: ${doctor.specialty}');
    content.writeln('العيادة: ${doctor.clinicAddress}');
    content.writeln('');
    
    // Patient info
    content.writeln('معلومات المريض:');
    content.writeln('الاسم: $patientName');
    if (appointment != null) {
      content.writeln('تاريخ الزيارة: ${appointment.appointmentTime.day}/${appointment.appointmentTime.month}/${appointment.appointmentTime.year}');
    }
    content.writeln('');
    
    // Prescription content
    content.writeln('الوصفة الطبية:');
    content.writeln(prescription.prescriptionText);
    content.writeln('');
    
    // Additional info
    if (prescription.diagnosis != null && prescription.diagnosis!.isNotEmpty) {
      content.writeln('التشخيص: ${prescription.diagnosis}');
      content.writeln('');
    }
    
    if (prescription.notes != null && prescription.notes!.isNotEmpty) {
      content.writeln('ملاحظات إضافية: ${prescription.notes}');
      content.writeln('');
    }
    
    // Date and signature
    content.writeln('تاريخ الوصفة: ${prescription.createdAt.day}/${prescription.createdAt.month}/${prescription.createdAt.year}');
    content.writeln('');
    content.writeln('توقيع الطبيب: ________________');
    
    return content.toString();
  }

  // Share prescription text
  Future<void> sharePrescription(
    PrescriptionModel prescription,
    DoctorModel doctor,
    String patientName,
    AppointmentModel? appointment,
  ) async {
    try {
      String content = generatePrescriptionPDF(prescription, doctor, patientName, appointment);
      
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: content));
      
      Get.snackbar(
        'تم النسخ',
        'تم نسخ الوصفة الطبية إلى الحافظة',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في مشاركة الوصفة الطبية',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Print prescription (simulate)
  Future<void> printPrescription(
    PrescriptionModel prescription,
    DoctorModel doctor,
    String patientName,
    AppointmentModel? appointment,
  ) async {
    try {
      String content = generatePrescriptionPDF(prescription, doctor, patientName, appointment);
      
      // In a real app, this would integrate with a printing service
      // For now, we'll just show the content in a dialog
      Get.dialog(
        AlertDialog(
          title: Text('معاينة الطباعة'),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('إغلاق'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'طباعة',
                  'سيتم إرسال الوصفة للطباعة',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Text('طباعة'),
            ),
          ],
        ),
      );
      
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في طباعة الوصفة الطبية',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get prescription history for patient
  Future<List<PrescriptionModel>> getPrescriptionHistory(String patientUid) async {
    try {
      return await _firestoreService.getAllPatientPrescriptions(patientUid);
    } catch (e) {
      print('Error getting prescription history: $e');
      return [];
    }
  }

  // Search prescriptions by medication
  List<PrescriptionModel> searchPrescriptionsByMedication(
    List<PrescriptionModel> prescriptions,
    String medication,
  ) {
    return prescriptions.where((prescription) {
      if (prescription.medications != null) {
        return prescription.medications!.any(
          (med) => med.toLowerCase().contains(medication.toLowerCase()),
        );
      }
      return prescription.prescriptionText.toLowerCase().contains(medication.toLowerCase());
    }).toList();
  }

  // Get prescriptions by date range
  List<PrescriptionModel> getPrescriptionsByDateRange(
    List<PrescriptionModel> prescriptions,
    DateTime startDate,
    DateTime endDate,
  ) {
    return prescriptions.where((prescription) {
      return prescription.createdAt.isAfter(startDate) &&
             prescription.createdAt.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  // Extract medications from prescription text
  List<String> extractMedications(String prescriptionText) {
    List<String> medications = [];
    
    // Simple extraction based on common patterns
    List<String> lines = prescriptionText.split('\n');
    
    for (String line in lines) {
      line = line.trim();
      
      // Look for numbered items or bullet points
      if (RegExp(r'^\d+\.').hasMatch(line) || 
          RegExp(r'^[•-]').hasMatch(line)) {
        
        // Extract medication name (first few words)
        List<String> words = line.split(' ');
        if (words.length > 1) {
          // Remove numbering and get medication name
          String medication = words.skip(1).take(3).join(' ');
          if (medication.isNotEmpty) {
            medications.add(medication);
          }
        }
      }
    }
    
    return medications;
  }

  // Validate prescription format
  bool validatePrescriptionFormat(String prescriptionText) {
    if (prescriptionText.trim().length < 10) {
      return false;
    }
    
    // Check for basic structure
    bool hasNumbering = RegExp(r'\d+\.').hasMatch(prescriptionText);
    bool hasBullets = RegExp(r'[•-]').hasMatch(prescriptionText);
    bool hasBasicStructure = hasNumbering || hasBullets;
    
    return hasBasicStructure;
  }

  // Get prescription statistics for doctor
  Map<String, dynamic> getPrescriptionStats(List<PrescriptionModel> prescriptions) {
    Map<String, dynamic> stats = {
      'total': prescriptions.length,
      'thisMonth': 0,
      'thisWeek': 0,
      'commonMedications': <String, int>{},
    };
    
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    for (PrescriptionModel prescription in prescriptions) {
      // Count this month
      if (prescription.createdAt.isAfter(startOfMonth)) {
        stats['thisMonth']++;
      }
      
      // Count this week
      if (prescription.createdAt.isAfter(startOfWeek)) {
        stats['thisWeek']++;
      }
      
      // Count medications
      if (prescription.medications != null) {
        for (String medication in prescription.medications!) {
          stats['commonMedications'][medication] = 
              (stats['commonMedications'][medication] ?? 0) + 1;
        }
      }
    }
    
    return stats;
  }
}

