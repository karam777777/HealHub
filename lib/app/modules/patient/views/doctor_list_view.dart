import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/patient_controller.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/specialty_theme.dart';

class DoctorListView extends GetView<PatientController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text(
          'قائمة الأطباء',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadDoctors,
        child: Obx(() {
          if (controller.isLoading.value && controller.doctors.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.doctors.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: controller.doctors.length,
            itemBuilder: (context, index) {
              DoctorModel doctor = controller.doctors[index];
              return _buildDoctorCard(context, doctor);
            },
          );
        }),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorModel doctor) {
    final specialtyTheme = SpecialtyThemes.getTheme(doctor.specialty);
    
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                specialtyTheme.backgroundColor.withOpacity(0.1),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: InkWell(
            onTap: () => controller.selectDoctor(doctor),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Specialty themed avatar
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: specialtyTheme.gradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: specialtyTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: doctor.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  doctor.imageUrl!,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildSpecialtyIcon(specialtyTheme);
                                  },
                                ),
                              )
                            : _buildSpecialtyIcon(specialtyTheme),
                      ),
                      SizedBox(width: 16),
                      
                      // Doctor info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.clinicName,
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: specialtyTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: specialtyTheme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    specialtyTheme.iconAsset,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    doctor.specialty,
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: specialtyTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    doctor.clinicAddress,
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Rating
                      if (doctor.totalRatings > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 18,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 4),
                              Text(
                                doctor.averageRating.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.surface),
                      ),
                      child: Text(
                        doctor.bio!,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 20),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.navigateToBooking(doctor),
                          icon: Icon(Icons.calendar_today_outlined, size: 20),
                          label: Text("حجز موعد"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: specialtyTheme.primaryColor,
                            side: BorderSide(color: specialtyTheme.primaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => controller.navigateToPrescriptions(doctor),
                          icon: Icon(Icons.receipt_long, size: 20),
                          label: Text("الوصفات"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: specialtyTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyIcon(SpecialtyTheme theme) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: theme.gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              theme.iconAsset,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 2),
            Icon(
              theme.icon,
              size: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد أطباء متاحون',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'لم يتم العثور على أي أطباء مسجلين في النظام',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.loadDoctors,
            icon: Icon(Icons.refresh),
            label: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

