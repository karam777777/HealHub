import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/patient_controller.dart';
import '../../../data/models/appointment_model.dart';

class PatientAppointmentsView extends GetView<PatientController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text(
          'مواعيدي',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadPatientAppointments,
        child: Obx(() {
          print("PatientAppointmentsView: Rebuilding with ${controller.appointments.length} appointments");
          if (controller.appointments.isEmpty) {
            print("PatientAppointmentsView: No appointments found, showing empty state");
            return _buildEmptyState(context);
          }

          print("PatientAppointmentsView: Showing ${controller.appointments.length} appointments");
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: controller.appointments.length,
            itemBuilder: (context, index) {
              AppointmentModel appointment = controller.appointments[index];
              print("PatientAppointmentsView: Building card for appointment ${appointment.appointmentId}");
              return _buildAppointmentCard(context, appointment);
            },
          );
        }),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, AppointmentModel appointment) {
    final Color statusColor = _getStatusColor(appointment.status);
    final String statusText = _getStatusText(appointment.status);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: AlwaysStoppedAnimation(1), curve: Curves.easeOutCubic)), // Placeholder for actual animation controller
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            // Optional: Navigate to appointment details or doctor profile
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status indicator dot
                    Container(
                      width: 10,
                      height: 10,
                      margin: EdgeInsets.only(top: 4, right: 8),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    
                    // Doctor info
                    Expanded(
                      child: FutureBuilder(
                        future: controller.getDoctorByUid(appointment.doctorUid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              'جاري التحميل...',
                              style: Theme.of(context).textTheme.bodyMedium,
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'خطأ في التحميل',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.error),
                            );
                          } else if (snapshot.hasData) {
                            final doctor = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.clinicName,
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  doctor.specialty,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),
                    
                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Date and time
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${appointment.appointmentTime.day}/${appointment.appointmentTime.month}/${appointment.appointmentTime.year}',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                
                if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    'ملاحظات: ${appointment.notes}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                
                // Action buttons for pending/confirmed appointments
                if (appointment.status == 'confirmed' || appointment.status == 'pending') ...[
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showCancelDialog(context, appointment),
                          icon: Icon(Icons.cancel_outlined, size: 20),
                          label: Text('إلغاء الموعد'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                            side: BorderSide(color: Theme.of(context).colorScheme.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            controller.getDoctorByUid(appointment.doctorUid).then((doctor) {
                              if (doctor != null) {
                                controller.navigateToPrescriptions(doctor);
                              }
                            });
                          },
                          icon: Icon(Icons.receipt_long, size: 20),
                          label: Text('الوصفات'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
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
            'لا توجد مواعيد',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'لم تقم بحجز أي مواعيد بعد. ابدأ بحجز موعدك الأول!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.back(), // Assuming Get.back() navigates to doctor list or home
            icon: Icon(Icons.add_circle_outline),
            label: Text('حجز موعد جديد'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إلغاء الموعد'),
        content: Text('هل أنت متأكد من رغبتك في إلغاء هذا الموعد؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('لا'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelAppointment(appointment);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('نعم، إلغاء'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'مؤكد';
      case 'pending':
        return 'في الانتظار';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'غير معروف';
    }
  }
}

