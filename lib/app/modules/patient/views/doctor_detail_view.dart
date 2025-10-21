import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/patient_controller.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/specialty_theme.dart';
import '../../shared/widgets/rating_widget.dart';
import '../../shared/controllers/rating_controller.dart';

class DoctorDetailView extends GetView<PatientController> {
  @override
  Widget build(BuildContext context) {
    final DoctorModel doctor = Get.arguments as DoctorModel;
    final specialtyTheme = SpecialtyThemes.getTheme(doctor.specialty);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // App bar with doctor image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: specialtyTheme.primaryColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      specialtyTheme.primaryColor.withOpacity(0.8),
                      specialtyTheme.primaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: doctor.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(35),
                                child: Image.network(
                                  doctor.imageUrl!,
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildSpecialtyIcon(specialtyTheme);
                                  },
                                ),
                              )
                            : _buildSpecialtyIcon(specialtyTheme),
                      ),
                      SizedBox(height: 20),
                      Text(
                        doctor.clinicName,
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              specialtyTheme.iconAsset,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              doctor.specialty,
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Doctor details
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating card
                  if (doctor.totalRatings > 0)
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [specialtyTheme.primaryColor.withOpacity(0.05), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: specialtyTheme.primaryColor.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: specialtyTheme.primaryColor.withOpacity(0.15),
                            blurRadius: 15,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: specialtyTheme.primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.star,
                              color: specialtyTheme.primaryColor,
                              size: 32,
                            ),
                          ),
                          SizedBox(width: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.averageRating.toStringAsFixed(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: specialtyTheme.primaryColor,
                                    ),
                              ),
                              Text(
                                
'${doctor.totalRatings} تقييمات',
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Clinic info
                  _buildInfoSection(
                    title: 'معلومات العيادة',
                    theme: specialtyTheme,
                    children: [
                      _buildInfoRow(
                        icon: Icons.local_hospital,
                        label: 'اسم العيادة',
                        value: doctor.clinicName,
                        theme: specialtyTheme,
                      ),
                      _buildInfoRow(
                        icon: Icons.location_on,
                        label: 'العنوان',
                        value: doctor.clinicAddress,
                        theme: specialtyTheme,
                      ),
                      if (doctor.latitude != null && doctor.longitude != null)
                        _buildLocationRow(doctor, specialtyTheme),
                      _buildInfoRow(
                        icon: specialtyTheme.icon,
                        label: 'التخصص',
                        value: doctor.specialty,
                        theme: specialtyTheme,
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Bio section
                  if (doctor.bio != null && doctor.bio!.isNotEmpty)
                    _buildInfoSection(
                      title: 'نبذة عن الطبيب',
                      theme: specialtyTheme,
                      children: [
                        Container(
                          padding: EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: specialtyTheme.backgroundColor.withOpacity(
                              0.2,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            doctor.bio!,
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onBackground.withOpacity(0.85),
                                  height: 1.6,
                                ),
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 20),

                  // Working hours
                  _buildInfoSection(
                    title: 'ساعات العمل',
                    theme: specialtyTheme,
                    children: doctor.workingHours.entries.map((entry) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: specialtyTheme.backgroundColor.withOpacity(
                            0.2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 90,
                              child: Text(
                                entry.key,
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: specialtyTheme.primaryColor,
                                    ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value
                                    .map(
                                      (range) =>
                                          '${range.startTime} - ${range.endTime}',
                                    )
                                    .join(', '),
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                          .withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Ratings section
                  GetBuilder<RatingController>(
                    init: RatingController(),
                    builder: (ratingController) => RatingWidget(
                      doctorId: doctor.uid,
                      doctorName: doctor.clinicName,
                      showAddRating: true,
                    ),
                  ),

                  SizedBox(height: 20),



                  SizedBox(height: 40), // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              controller.navigateToPrescriptions(doctor),
                          icon: Icon(Icons.receipt_long, size: 22),
                          label: Text('عرض الوصفات'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: specialtyTheme.primaryColor,
                            side: BorderSide(
                              color: specialtyTheme.primaryColor,
                              width: 2,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: specialtyTheme.gradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: specialtyTheme.primaryColor.withOpacity(
                                  0.4,
                                ),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                controller.navigateToBooking(doctor),
                            icon: Icon(Icons.calendar_today_outlined, size: 22),
                            label: Text('حجز موعد'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyIcon(SpecialtyTheme theme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: theme.gradient,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(theme.iconAsset, style: TextStyle(fontSize: 32)),
            SizedBox(height: 4),
            Icon(theme.icon, size: 28, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
    required SpecialtyTheme theme,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(theme.icon, color: theme.primaryColor, size: 24),
                ),
                SizedBox(width: 16),
                Text(
                  title,
                  style: Theme.of(Get.context!).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required SpecialtyTheme theme,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.primaryColor, size: 20),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(Get.context!).textTheme.bodySmall!.copyWith(
                    color: Theme.of(
                      Get.context!,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(DoctorModel doctor, SpecialtyTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.map, color: theme.primaryColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الموقع على الخريطة',
                  style: Theme.of(Get.context!).textTheme.bodySmall!.copyWith(
                    color: Theme.of(Get.context!).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openInMaps(doctor),
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('الحصول على الاتجاهات'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      side: BorderSide(color: theme.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInMaps(DoctorModel doctor) async {
    final String googleMapsUrl = doctor.latitude != null && doctor.longitude != null
        ? 'https://www.google.com/maps/search/?api=1&query=${doctor.latitude},${doctor.longitude}'
        : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(doctor.clinicAddress)}';
    
    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('خطأ', 'لا يمكن فتح خرائط Google');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في فتح خرائط Google: ${e.toString()}');
    }
  }
}


  Widget _buildSocialMediaSection({
    required String title,
    required SpecialtyTheme theme,
    required Map<String, String> socialMedia,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Get.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: socialMedia.entries.map((entry) {
            IconData iconData;
            switch (entry.key.toLowerCase()) {
              case 'facebook':
                iconData = Icons.facebook;
                break;
              case 'twitter':
                iconData = Icons.account_circle; // Using a generic icon for Twitter
                break;
              case 'instagram':
                iconData = Icons.camera_alt; // Using a generic icon for Instagram
                break;
              case 'linkedin':
                iconData = Icons.link; // Assuming you have a custom icon or using a generic one
                break;
              case 'website':
                iconData = Icons.language;
                break;
              case 'phone':
                iconData = Icons.phone;
                break;
              case 'email':
                iconData = Icons.email;
                break;
              default:
                iconData = Icons.link;
            }
            return _buildSocialMediaButton(
              icon: iconData,
              label: entry.key,
              url: entry.value,
              color: theme.primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSocialMediaButton({
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return InkWell(
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          Get.snackbar(
            'خطأ',
            'لا يمكن فتح الرابط $url',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }



