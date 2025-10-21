import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/doctor_controller.dart';
import '../../../data/models/appointment_model.dart';

class DoctorAppointmentsView extends GetView<DoctorController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text('جميع المواعيد', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Date selector
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => Text(
                      'المواعيد ليوم ${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.edit_calendar, size: 18),
                  label: Text('تغيير'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Appointments list
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadAppointmentsForDate,
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.todayAppointments.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                if (controller.todayAppointments.isEmpty) {
                  return _buildEmptyState(context);
                }
              
                // Group appointments by status
                Map<String, List<AppointmentModel>> groupedAppointments = {};
                for (var appointment in controller.todayAppointments) {
                  String status = appointment.status;
                  groupedAppointments
                      .putIfAbsent(status, () => [])
                      .add(appointment);
                }
                return ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    if (groupedAppointments.containsKey('confirmed'))
                      _buildAppointmentSection(
                        context,
                        'المواعيد المؤكدة',
                        groupedAppointments['confirmed']!,
                        Colors.green,
                        Icons.check_circle,
                      ),
                    if (groupedAppointments.containsKey('pending'))
                      _buildAppointmentSection(
                        context,
                        'المواعيد في الانتظار',
                        groupedAppointments['pending']!,
                        Colors.orange,
                        Icons.schedule,
                      ),
                    if (groupedAppointments.containsKey('completed'))
                      _buildAppointmentSection(
                        context,
                        'المواعيد المكتملة',
                        groupedAppointments['completed']!,
                        Colors.blue,
                        Icons.done_all,
                      ),
                    if (groupedAppointments.containsKey('cancelled'))
                      _buildAppointmentSection(
                        context,
                        'المواعيد الملغية',
                        groupedAppointments['cancelled']!,
                        Colors.red,
                        Icons.cancel,
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentSection(
    BuildContext context,
    String title,
    List<AppointmentModel> appointments,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${appointments.length}',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...appointments.map(
          (appointment) => _buildAppointmentCard(context, appointment, color),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    AppointmentModel appointment,
    Color statusColor,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Time
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${appointment.appointmentTime.hour.toString().padLeft(2, '0')}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Patient name
            FutureBuilder<String>(
              future: controller.getPatientName(appointment.patientUid),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'جاري التحميل...',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                );
              },
            ),

            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'ملاحظات: ${appointment.notes}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // Action buttons
            if (appointment.status == 'confirmed' ||
                appointment.status == 'pending') ...[
              SizedBox(height: 16),
              Row(
                children: [
                  if (appointment.status == 'pending') ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showRejectDialog(context, appointment),
                        icon: Icon(Icons.close, size: 18),
                        label: Text('رفض'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showConfirmDialog(context, appointment),
                        icon: Icon(Icons.check, size: 18),
                        label: Text('تأكيد'),
                      ),
                    ),
                    SizedBox(width: 8),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showCancelDialog(context, appointment),
                        icon: Icon(Icons.cancel, size: 18),
                        label: Text('إلغاء'),
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          controller.navigateToPrescriptionWrite(appointment),
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('كتابة وصفة'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showCompleteDialog(context, appointment),
                      icon: Icon(Icons.check_circle_outline, size: 18),
                      label: Text('إتمام'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 100,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
          ),
          SizedBox(height: 24),
          Text(
            'لا توجد مواعيد لهذا اليوم',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'يمكنك اختيار يوم آخر لعرض المواعيد.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _selectDate(context),
            icon: Icon(Icons.calendar_today),
            label: Text('اختيار يوم آخر'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('إلغاء الموعد'),
        content: Text('هل أنت متأكد من رغبتك في إلغاء هذا الموعد؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('لا')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelAppointment(appointment);
            },
            child: Text('نعم، إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('إتمام الموعد'),
        content: Text('هل تم الانتهاء من هذا الموعد؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('لا')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.completeAppointment(appointment);
            },
            child: Text('نعم، إتمام'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تأكيد الموعد'),
        content: Text('هل أنت متأكد من رغبتك في تأكيد هذا الموعد؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('لا')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.confirmAppointment(appointment);
            },
            child: Text('نعم، تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('رفض الموعد'),
        content: Text('هل أنت متأكد من رغبتك في رفض هذا الموعد؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('لا')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.rejectAppointment(appointment);
            },
            child: Text('نعم، رفض'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now().add(Duration(days: 30)),
      locale: Locale('ar'),
    );
    if (picked != null) {
      controller.changeDate(picked);
    }
  }
}
