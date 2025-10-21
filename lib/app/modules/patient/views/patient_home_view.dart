import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../routes/app_pages.dart';
import '../controllers/patient_controller.dart';

class PatientHomeView extends GetView<PatientController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xfff8fafc),
        elevation: 0,
        centerTitle: true,
        title: Obx(() {
          return Text(
            "مرحباً، ${controller.currentUser?.fullName ?? ''} 👋",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          );
        }),
        actions: [
          Obx(
            () => Stack(
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.NOTIFICATIONS),
                ),
                if (controller.notificationService.unreadCount.value > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        controller.notificationService.unreadCount.value
                            .toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: controller.signOut,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        currentIndex: 0, // You might want to manage this with a controller
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAllNamed(AppRoutes.PATIENT_HOME);
              break;
            case 1:
              Get.toNamed(AppRoutes.COMMUNITY);
              break;
            case 2:
              Get.toNamed(AppRoutes.PATIENT_APPOINTMENTS);
              break;
            case 3:
              // Assuming a profile page route exists or needs to be created
              // For now, let\'s navigate to a placeholder or the home itself
              Get.toNamed(
                AppRoutes.PATIENT_PROFILE_SETUP,
              ); // Or a dedicated profile view
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'المجتمع',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'المواعيد',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===== القسم المتحرك الجديد =====
              _AnimatedHeader(),

              SizedBox(height: 30),

              // Quick actions
              Text(
                'الخدمات السريعة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context: context,
                      title: 'حجز موعد',
                      subtitle: '     احجز موعد مع طبيب',
                      icon: Icons.calendar_today,
                      color: Colors.blue,
                      onTap: () => Get.toNamed(AppRoutes.DOCTOR_LIST),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      context: context,
                      title: 'مواعيدي',
                      subtitle: 'عرض المواعيد المحجوزة',
                      icon: Icons.schedule,
                      color: Colors.green,
                      onTap: () => Get.toNamed(AppRoutes.PATIENT_APPOINTMENTS),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Recent appointments
              Text(
                'المواعيد الأخيرة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),

              Obx(() {
                if (controller.appointments.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.calendar_today_outlined,
                    title: 'لا توجد مواعيد',
                    subtitle: 'لم تقم بحجز أي مواعيد بعد',
                  );
                }

                return Column(
                  children: controller.appointments
                      .take(3)
                      .map((appointment) => _buildAppointmentCard(appointment))
                      .toList(),
                );
              }),

              SizedBox(height: 20),

              if (controller.appointments.isNotEmpty)
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Get.toNamed(AppRoutes.PATIENT_APPOINTMENTS),
                    child: Text(
                      'عرض جميع المواعيد',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== Widget الكارد للأكشن =====
  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(18),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 34, color: color),
              ),
              SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== Widget الكارد للمواعيد =====
  Widget _buildAppointmentCard(appointment) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(appointment.status),
          child: Icon(Icons.medical_services, color: Colors.white, size: 20),
        ),
        title: FutureBuilder(
          future: controller.getDoctorByUid(appointment.doctorUid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data?.clinicName ?? 'طبيب');
            }
            return Text('جاري التحميل...');
          },
        ),
        subtitle: Text(
          '${appointment.appointmentTime.day}/${appointment.appointmentTime.month}/${appointment.appointmentTime.year} - ${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}',
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(appointment.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(appointment.status),
            style: TextStyle(
              color: _getStatusColor(appointment.status),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// ===== حالة فارغة =====
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
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

/// ===== Widget مخصص للقسم العلوي المتحرك =====
class _AnimatedHeader extends StatefulWidget {
  @override
  State<_AnimatedHeader> createState() => _AnimatedHeaderState();
}

class _AnimatedHeaderState extends State<_AnimatedHeader> {
  PageController _pageController = PageController();
  int _index = 0;
  late Timer _timer;

  final List<Map<String, dynamic>> tips = [
    {
      "text": "اشرب 8 أكواب ماء يومياً 🌊",
      "color": Colors.blue,
      "icon": Icons.water_drop,
    },
    {
      "text": "مارس الرياضة نصف ساعة يومياً 🏃",
      "color": Colors.green,
      "icon": Icons.fitness_center,
    },
    {
      "text": "نم جيداً لتحافظ على صحتك ",
      "color": Colors.purple,
      "icon": Icons.bed,
    },
    {
      "text": "قلل السكر لتحمي قلبك ❤️",
      "color": Colors.red,
      "icon": Icons.favorite,
    },
    {
      "text": "تناول الخضار والفواكه 🍎",
      "color": Colors.orange,
      "icon": Icons.restaurant,
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _index = (_index + 1) % tips.length;
        _pageController.animateToPage(
          _index,
          duration: Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ///جسم متحرك يأشر
        SizedBox(
          height: 200,
          child: Lottie.asset(
            "assets/animations/ph1.json",
            fit: BoxFit.contain,
          ),
        ),

        /// نصائح طبية في PageView
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: tips.length,
            itemBuilder: (context, i) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 500),
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tips[i]["color"].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: tips[i]["color"].withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(tips[i]["icon"], color: tips[i]["color"], size: 38),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        tips[i]["text"],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: tips[i]["color"],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        /// مؤشر صغير أسفل النصائح
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            tips.length,
            (i) => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              width: _index == i ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _index == i ? tips[i]["color"] : Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
