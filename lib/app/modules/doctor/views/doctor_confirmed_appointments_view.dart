import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:untitled/app/routes/app_pages.dart';
import '../controllers/doctor_confirmed_appointments_controller.dart';

class DoctorConfirmedAppointmentsView
    extends GetView<DoctorConfirmedAppointmentsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'المواعيد المؤكدة',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _showDatePicker(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: Obx(
              () => Column(
                children: [
                  Text(
                    DateFormat(
                      'EEEE، d MMMM yyyy',
                      'ar',
                    ).format(controller.selectedDate.value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'عدد المواعيد: ${controller.confirmedAppointments.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // ==================== التعديل هنا ====================
          // Current appointment indicator
          Obx(() {
            // التحقق أولاً من أن القائمة ليست فارغة
            if (controller.confirmedAppointments.isNotEmpty) {
              // إذا كانت هناك مواعيد، اعرض الموعد الحالي
              final currentAppointment =
                  controller.confirmedAppointments[controller
                      .currentAppointmentIndex
                      .value];
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF4CAF50),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'المريض الحالي',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Obx(
                            () => Text(
                              controller.currentPatientName.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat(
                              'HH:mm',
                            ).format(currentAppointment.appointmentTime),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              );
            } else {
              // إذا كانت القائمة فارغة، لا تعرض أي شيء
              return const SizedBox.shrink();
            }
          }),
          // ================= نهاية التعديل ====================

          // Appointments list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF667eea),
                    ),
                  ),
                );
              } else if (controller.confirmedAppointments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "لا توجد مواعيد مؤكدة لهذا التاريخ",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.confirmedAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = controller.confirmedAppointments[index];
                    final isCurrentAppointment =
                        index == controller.currentAppointmentIndex.value;
                    final hasPrescription = controller.hasPrescription(appointment);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isCurrentAppointment
                            ? Border.all(
                                color: const Color(0xFF4CAF50),
                                width: 2,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isCurrentAppointment
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFF667eea),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appointment.patientName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Color(0xFF718096),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('HH:mm').format(
                                              appointment.appointmentTime,
                                            ),
                                            style: const TextStyle(
                                              color: Color(0xFF718096),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCurrentAppointment)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,

                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4CAF50),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'الحالي',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Get.toNamed(
                                        AppRoutes.PRESCRIPTION_WRITE,
                                        arguments: appointment,
                                      )?.then((_) {
                                        controller.loadConfirmedAppointments(controller.selectedDate.value);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.receipt_long,
                                      color: hasPrescription
                                          ? Colors.white
                                          : const Color(0xFF667eea),
                                    ),
                                    label: Text(
                                      'وصفة طبية',
                                      style: TextStyle(
                                        color: hasPrescription
                                            ? Colors.white
                                            : const Color(0xFF667eea),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hasPrescription
                                          ? const Color(0xFF4CAF50)
                                          : Colors.white,
                                      side: BorderSide(
                                        color: hasPrescription
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFF667eea),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => controller
                                        .completeAppointment(appointment),
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),

                                    label: const Text(
                                      'إتمام الموعد',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4CAF50),
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
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != controller.selectedDate.value) {
      controller.changeDate(picked);
    }
  }
}
