import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/doctor_controller.dart';
import '../../../data/models/appointment_model.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';

class PrescriptionWriteView extends GetView<DoctorController> {
  final AppointmentModel appointment = Get.arguments as AppointmentModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          'كتابة وصفة طبية',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.prescriptionFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'معلومات المريض',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            appointment.patientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${DateFormat('HH:mm').format(appointment.appointmentTime)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Removed appointment time as it's not directly available from patientUid
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Doctor info
              Obx(() {
                final doctor = controller.doctorProfile.value;
                if (doctor == null) return const SizedBox.shrink();

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'معلومات الطبيب',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.local_hospital,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              doctor.clinicName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.medical_services,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              doctor.specialty,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Prescription form
              const Text(
                'نص الوصفة الطبية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'اكتب الوصفة الطبية بالتفصيل:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A5568),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: controller.prescriptionController,
                        validator: controller.validatePrescription,
                        maxLines: 10,
                        decoration: InputDecoration(
                          hintText:
                              'مثال:\n\n1. دواء الباراسيتامول 500 مجم\n   - قرص واحد كل 8 ساعات\n   - بعد الأكل\n   - لمدة 5 أيام\n\n2. مضاد حيوي أموكسيسيلين 250 مجم\n   - كبسولة واحدة كل 12 ساعة\n   - قبل الأكل بساعة\n   - لمدة 7 أيام\n\nملاحظات:\n- الراحة التامة\n- شرب السوائل بكثرة\n- مراجعة الطبيب في حالة عدم التحسن',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFEDF2F7),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF2D3748),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tips
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF8FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF90CDF4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: const Color(0xFF3182CE),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'نصائح لكتابة وصفة طبية فعالة:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2B6CB0),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '• اذكر اسم الدواء والجرعة بوضوح\n• حدد عدد مرات تناول الدواء يومياً\n• اذكر مدة العلاج\n• أضف تعليمات خاصة (قبل/بعد الأكل)\n• اكتب ملاحظات إضافية إذا لزم الأمر',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF4299E1),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Send button
              // Send button
              Obx(
                () => CustomButton(
                  text: 'إرسال الوصفة الطبية',
                  onPressed: () => controller.writePrescription(),
                  isLoading: controller.isLoading.value,
                ),
              ),
              const SizedBox(height: 16),

              // Cancel button
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
