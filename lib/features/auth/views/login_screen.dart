import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/utils/validators.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/common/app_text_field.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.pagePaddingV,
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: Get.back,
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: AppColors.textPrimaryLight,
                  ),
                ),

                const SizedBox(height: AppDimensions.xl),

                // Logo
                Center(
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Build',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(
                          text: 'OS',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.xl),

                Text('welcome_back'.tr, style: AppTextStyles.h1(context))
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: AppDimensions.xs),
                Text(
                  'sign_in_subtitle'.tr,
                  style: AppTextStyles.bodySmall(context),
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                const SizedBox(height: AppDimensions.xl),

                // Phone field
                AppTextField(
                  label: 'phone_number'.tr,
                  hint: '345 1234567',
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixText: 'PK +92  ',
                  validator: Validators.phone,
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: AppDimensions.md),

                // Password field
                AppTextField(
                  label: 'password'.tr,
                  hint: '••••••••',
                  controller: passCtrl,
                  obscureText: true,
                  validator: Validators.password,
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'forgot_password'.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: AppDimensions.sm),

                // Sign in button
                Obx(
                  () => AppButton(
                    label: 'sign_in'.tr,
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        controller.loginWithPhone(
                          phone: phoneCtrl.text,
                          password: passCtrl.text,
                        );
                      }
                    },
                  ),
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                const SizedBox(height: AppDimensions.xl),

                // OR divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: AppTextStyles.caption(context),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: AppDimensions.xl),

                // OTP + Google row
                Row(
                  children: [
                    Expanded(
                      child: AppButton.outline(
                        label: 'otp_login'.tr,
                        leading: const Text('📱', style: TextStyle(fontSize: 16)),
                        onPressed: () => controller.loginWithOtp(phoneCtrl.text),
                        height: AppDimensions.buttonHeightMd,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: AppButton.outline(
                        label: 'google_login'.tr,
                        leading: const Text('G', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.error)),
                        onPressed: () {},
                        height: AppDimensions.buttonHeightMd,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: AppDimensions.xxxl),

                // Create account
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'new_here'.tr,
                        style: AppTextStyles.bodySmall(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'create_account'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: AppDimensions.sm),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.textTertiaryLight),
                      const SizedBox(width: 4),
                      Text(
                        'secured'.tr,
                        style: AppTextStyles.caption(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
