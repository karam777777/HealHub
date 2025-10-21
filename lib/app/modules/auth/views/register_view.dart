import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class RegisterView extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed from grey[50] to white
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: controller.registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Center(
                  child: Column(
                    children: [
                      Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'أدخل بياناتك لإنشاء حساب جديد',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                
                // Full name field
                CustomTextField(
                  label: 'الاسم الكامل',
                  hint: 'أدخل اسمك الكامل',
                  controller: controller.fullNameController,
                  validator: (value) => controller.validateRequired(value, 'الاسم الكامل'),
                  prefixIcon: Icon(Icons.person_outlined),
                ),
                SizedBox(height: 20),
                
                // Phone field
                CustomTextField(
                  label: 'رقم الهاتف (اختياري)',
                  hint: 'أدخل رقم هاتفك',
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                SizedBox(height: 20),
                
                // Email field
                CustomTextField(
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل بريدك الإلكتروني',
                  controller: controller.emailController,
                  validator: controller.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                SizedBox(height: 20),
                
                // Password field
                CustomTextField(
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة المرور',
                  controller: controller.passwordController,
                  validator: controller.validatePassword,
                  obscureText: true,
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                SizedBox(height: 20),
                
                // Confirm password field
                CustomTextField(
                  label: 'تأكيد كلمة المرور',
                  hint: 'أعد إدخال كلمة المرور',
                  controller: controller.confirmPasswordController,
                  validator: (value) {
                    if (value != controller.passwordController.text) {
                      return 'كلمات المرور غير متطابقة';
                    }
                    return null;
                  },
                  obscureText: true,
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                SizedBox(height: 30),
                
                // Register button
                Obx(() => CustomButton(
                  text: 'إنشاء الحساب',
                  onPressed: controller.register,
                  isLoading: controller.isLoading.value,
                )),
                SizedBox(height: 20),
                
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟ ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary, // Using colorScheme.primary
                          fontWeight: FontWeight.w600,
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
    );
  }
}


