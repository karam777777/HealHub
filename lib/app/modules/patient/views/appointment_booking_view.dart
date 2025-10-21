import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/patient_controller.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/specialty_theme.dart';
import '../../shared/widgets/custom_button.dart';

class AppointmentBookingView extends GetView<PatientController> {
  @override
  Widget build(BuildContext context) {
    final DoctorModel doctor = Get.arguments as DoctorModel;
    final specialtyTheme = SpecialtyThemes.getTheme(doctor.specialty);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: specialtyTheme.primaryColor,
        elevation: 0,
        title: Text(
          'حجز موعد',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor info card
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: specialtyTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: doctor.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                doctor.imageUrl!,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    specialtyTheme.icon,
                                    color: specialtyTheme.primaryColor,
                                    size: 40,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              specialtyTheme.icon,
                              color: specialtyTheme.primaryColor,
                              size: 40,
                            ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.clinicName,
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            doctor.specialty,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: specialtyTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            doctor.clinicAddress,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Date selection
            Text(
              'اختر التاريخ',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            SizedBox(height: 16),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _selectDate(context, doctor.uid!), // Pass doctor UID
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Obx(
                    () => Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: specialtyTheme.primaryColor,
                          size: 24,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            controller.selectedDate.value != null
                                ? DateFormat('yyyy/MM/dd', 'ar').format(controller.selectedDate.value!)
                                : 'اختر التاريخ',
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: controller.selectedDate.value != null
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 32),

            // Time selection
            Obx(() {
              if (controller.selectedDate.value == null) {
                return Container();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اختر الوقت',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  SizedBox(height: 16),

                  // Loading indicator for time slots
                  if (controller.isLoading.value)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(color: specialtyTheme.primaryColor),
                      ),
                    )
                  else if (controller.availableTimeSlots.isEmpty)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_busy_outlined,
                                size: 60,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'لا توجد مواعيد متاحة في هذا اليوم',
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2.2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: controller.availableTimeSlots.length,
                          itemBuilder: (context, index) {
                            final timeSlotStatus =
                                controller.availableTimeSlots[index];
                            final String timeSlot = timeSlotStatus.time;
                            final bool isBooked = timeSlotStatus.isBooked;

                            bool isSelected =
                                controller.selectedTime.value != null &&
                                    '${controller.selectedTime.value!.hour.toString().padLeft(2, '0')}:${controller.selectedTime.value!.minute.toString().padLeft(2, '0')}' ==
                                        timeSlot;

                            return GestureDetector(
                              onTap: isBooked
                                  ? null
                                  : () {
                                      List<String> timeParts = timeSlot.split(':');
                                      controller.selectedTime.value = TimeOfDay(
                                        hour: int.parse(timeParts[0]),
                                        minute: int.parse(timeParts[1]),
                                      );
                                    },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: isBooked
                                      ? Theme.of(context).colorScheme.error.withOpacity(0.1)
                                      : isSelected
                                          ? specialtyTheme.primaryColor
                                          : Theme.of(context).colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isBooked
                                        ? Theme.of(context).colorScheme.error
                                        : (isSelected
                                            ? specialtyTheme.primaryColor
                                            : Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: specialtyTheme.primaryColor.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    isBooked ? 'محجوز' : timeSlot,
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          color: isBooked
                                              ? Theme.of(context).colorScheme.error
                                              : isSelected
                                                  ? Colors.white
                                                  : Theme.of(context).colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              );
            }),

            SizedBox(height: 40),

            // Book button
            Obx(
              () => CustomButton(
                text: 'تأكيد الحجز',
                onPressed:
                    controller.selectedDate.value != null &&
                            controller.selectedTime.value != null &&
                            !controller.isLoading.value
                        ? () => controller.bookAppointment()
                        : null,
                isLoading: controller.isLoading.value,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, String doctorUid) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)), // Allow booking for a year
      locale: Locale('ar'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Theme.of(context).colorScheme.onSurface, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectedDate.value = picked;
      controller.selectedTime.value = null;
      controller.isLoading.value = true; // Start loading
      await controller.generateAvailableTimeSlots(); // No doctorUid needed here
      controller.isLoading.value = false; // End loading
    }
  }
}
