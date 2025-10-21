import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/patient_controller.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/prescription_model.dart';

class PrescriptionView extends GetView<PatientController> {
  @override
  Widget build(BuildContext context) {
    final DoctorModel doctor = Get.arguments as DoctorModel;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text('الوصفات الطبية', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Doctor info header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: doctor.imageUrl != null
                      ? ClipOval(
                          child: Image.network(
                            doctor.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person, color: Colors.white);
                            },
                          ),
                        )
                      : Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.clinicName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        doctor.specialty,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Prescriptions list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.prescriptions.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.prescriptions.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: controller.prescriptions.length,
                itemBuilder: (context, index) {
                  PrescriptionModel prescription =
                      controller.prescriptions[index];
                  return _buildPrescriptionCard(context, prescription);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(
    BuildContext context,
    PrescriptionModel prescription,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt_long,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          'وصفة طبية',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  '${prescription.createdAt.day}/${prescription.createdAt.month}/${prescription.createdAt.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(width: 12),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  '${prescription.createdAt.hour}:${prescription.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(),
                SizedBox(height: 8),
                Text(
                  'تفاصيل الوصفة:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    prescription.prescriptionText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _sharePrescription(prescription),
                        icon: Icon(Icons.share, size: 18),
                        label: Text('مشاركة'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _printPrescription(prescription),
                        icon: Icon(Icons.print, size: 18),
                        label: Text('طباعة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'لا توجد وصفات طبية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'لم يقم الطبيب بكتابة أي وصفات طبية لك بعد',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  void _sharePrescription(PrescriptionModel prescription) {
    // Implement share functionality
    Get.snackbar(
      'مشاركة',
      'سيتم إضافة ميزة المشاركة قريباً',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _printPrescription(PrescriptionModel prescription) {
    // Implement print functionality
    Get.snackbar(
      'طباعة',
      'سيتم إضافة ميزة الطباعة قريباً',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
