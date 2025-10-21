import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class PatientProfileSetupView extends GetView<AuthController> {
  final List<String> genders = ['ذكر', 'أنثى'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'إعداد ملف المريض',
          style: TextStyle(color: Colors.grey[800]),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: controller.patientProfileFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                
                // Info message
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600]),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'المعلومات التالية اختيارية ويمكن إضافتها لاحقاً',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                
                // Gender selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الجنس (اختياري)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Obx(() => Row(
                      children: genders.map((gender) {
                        return Expanded(
                          child: RadioListTile<String>(
                            title: Text(gender),
                            value: gender,
                            groupValue: controller.selectedGender.value,
                            onChanged: (value) {
                              controller.selectedGender.value = value ?? '';
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        );
                      }).toList(),
                    )),
                  ],
                ),
                SizedBox(height: 20),
                
                // Date of birth
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تاريخ الميلاد (اختياري)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Obx(() => InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: Colors.grey[600]),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                controller.selectedDob.value != null
                                    ? '${controller.selectedDob.value!.day}/${controller.selectedDob.value!.month}/${controller.selectedDob.value!.year}'
                                    : 'اختر تاريخ الميلاد',
                                style: TextStyle(
                                  color: controller.selectedDob.value != null
                                      ? Colors.grey[800]
                                      : Colors.grey[400],
                                ),
                              ),
                            ),
                            if (controller.selectedDob.value != null)
                              IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey[600]),
                                onPressed: () {
                                  controller.selectedDob.value = null;
                                },
                              ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
                SizedBox(height: 20),
                
                // Address
                CustomTextField(
                  label: 'العنوان (اختياري)',
                  hint: 'أدخل عنوانك',
                  controller: controller.addressController,
                  maxLines: 2,
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                SizedBox(height: 40),
                
                // Save button
                Obx(() => CustomButton(
                  text: 'حفظ الملف الشخصي',
                  onPressed: controller.setupPatientProfile,
                  isLoading: controller.isLoading.value,
                )),
                SizedBox(height: 20),
                
                // Skip button
                TextButton(
                  onPressed: controller.setupPatientProfile,
                  child: Text(
                    'تخطي وإنهاء التسجيل',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDob.value ?? DateTime.now().subtract(Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: Locale('ar'),
    );
    if (picked != null) {
      controller.selectedDob.value = picked;
    }
  }
}

