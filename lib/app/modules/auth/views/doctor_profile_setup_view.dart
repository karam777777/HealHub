import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../../data/models/doctor_model.dart'; // للحصول على WorkingHourRange

class DoctorProfileSetupView extends GetView<AuthController> {
  final List<String> specialties = const [
    'طب عام',
    'طب الأطفال',
    'طب النساء والولادة',
    'طب القلب',
    'طب العظام',
    'طب الأعصاب',
    'طب العيون',
    'طب الأنف والأذن والحنجرة',
    'طب الجلدية',
    'طب النفسية',
  ];

  final List<String> weekDays = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'إعداد ملف الطبيب',
          style: TextStyle(color: Colors.grey[800]),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.doctorProfileFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Specialty dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التخصص',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: 'اختر التخصص',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: specialties
                          .map((specialty) =>
                              DropdownMenuItem(value: specialty, child: Text(specialty)))
                          .toList(),
                      onChanged: (value) {
                        controller.specialtyController.text = value ?? '';
                      },
                      validator: (value) =>
                          controller.validateRequired(value, 'التخصص'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Clinic name
                CustomTextField(
                  label: 'اسم العيادة',
                  hint: 'أدخل اسم العيادة',
                  controller: controller.clinicNameController,
                  validator: (value) =>
                      controller.validateRequired(value, 'اسم العيادة'),
                  prefixIcon: const Icon(Icons.local_hospital_outlined),
                ),
                const SizedBox(height: 20),

                // Clinic address
                CustomTextField(
                  label: 'عنوان العيادة',
                  hint: 'أدخل عنوان العيادة',
                  controller: controller.clinicAddressController,
                  validator: (value) =>
                      controller.validateRequired(value, 'عنوان العيادة'),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                const SizedBox(height: 20),

                // Bio
                CustomTextField(
                  label: 'نبذة عن الطبيب (اختياري)',
                  hint: 'أدخل نبذة مختصرة عنك',
                  controller: controller.bioController,
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.info_outlined),
                ),
                const SizedBox(height: 30),

                // Working hours section
                Text(
                  'ساعات العمل',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),

                // Working hours list
                Obx(
                  () => Column(
                    children: controller.workingHours.entries.map((entry) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(entry.key),
                          subtitle: Text(entry.value
                              .map((e) => '${e.startTime} - ${e.endTime}')
                              .join(', ')),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              controller.workingHours.remove(entry.key);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Add working hours button
                OutlinedButton.icon(
                  onPressed: () => _showAddWorkingHoursDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة ساعات عمل'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

                const SizedBox(height: 40),

                // Save button
                Obx(
                  () => CustomButton(
                    text: 'حفظ الملف الشخصي',
                    onPressed: controller.setupDoctorProfile,
                    isLoading: controller.isLoading.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddWorkingHoursDialog(BuildContext context) {
    String selectedDay = weekDays.first;
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة ساعات عمل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Day selection
              DropdownButtonFormField<String>(
                value: selectedDay,
                decoration: const InputDecoration(
                  labelText: 'اليوم',
                  border: OutlineInputBorder(),
                ),
                items: weekDays
                    .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDay = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Start time
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('من'),
                      subtitle: Text(_formatLocal(context, startTime)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );
                        if (picked != null) {
                          setState(() {
                            startTime = picked;
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('إلى'),
                      subtitle: Text(_formatLocal(context, endTime)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );
                        if (picked != null) {
                          setState(() {
                            endTime = picked;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                // تحقق أن النهاية بعد البداية
                final int s = startTime.hour * 60 + startTime.minute;
                final int e = endTime.hour * 60 + endTime.minute;
                if (e <= s) {
                  Get.snackbar('تنبيه', 'وقت النهاية يجب أن يكون بعد وقت البداية');
                  return;
                }

                // منع التداخل مع نطاقات موجودة لنفس اليوم
                final existing = controller.workingHours[selectedDay] ?? [];
                final newRange = WorkingHourRange(
                  startTime: _format24(startTime),
                  endTime: _format24(endTime),
                );
                final bool hasOverlap = existing.any((r) => _overlaps(r, newRange));
                if (hasOverlap) {
                  Get.snackbar('تنبيه', 'النطاق يتداخل مع نطاق موجود');
                  return;
                }

                controller.addWorkingHours(selectedDay, newRange);
                Get.back();
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  // عرض محلي فقط
  String _formatLocal(BuildContext context, TimeOfDay t) =>
      TimeOfDay(hour: t.hour, minute: t.minute).format(context);

  // تخزين ثابت 24‑ساعة
  String _format24(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // Parser بسيط لـ "HH:mm"
  TimeOfDay? _parse24(String s) {
    final parts = s.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return TimeOfDay(hour: h, minute: m);
    }

  // التداخل: aStart < bEnd && bStart < aEnd
  bool _overlaps(WorkingHourRange a, WorkingHourRange b) {
    final s1 = _parse24(a.startTime);
    final e1 = _parse24(a.endTime);
    final s2 = _parse24(b.startTime);
    final e2 = _parse24(b.endTime);
    if (s1 == null || e1 == null || s2 == null || e2 == null) return true; // في حال قيم غير صالحة
    final aStart = s1.hour * 60 + s1.minute;
    final aEnd = e1.hour * 60 + e1.minute;
    final bStart = s2.hour * 60 + s2.minute;
    final bEnd = e2.hour * 60 + e2.minute;
    return aStart < bEnd && bStart < aEnd;
  }
}