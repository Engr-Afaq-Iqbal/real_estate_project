import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_card.dart';
import '../../../presentation/widgets/common/app_text_field.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_profile'.tr),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz_rounded)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.xl),
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Obx(() => Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            controller.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit_rounded, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Obx(() => Text(controller.name, style: AppTextStyles.h2(context))),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          controller.isHomeowner ? 'HOMEOWNER' : 'DEVELOPER',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      )),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondaryLight),
                      const Text('Lahore, PK', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  Obx(() => AppCard(
                    child: Row(
                      children: [
                        Expanded(child: _StatCell(value: '${controller.projectCount}', label: 'Project')),
                        Container(width: 1, height: 40, color: AppColors.dividerLight),
                        Expanded(child: _StatCell(value: '${controller.updatesCount}', label: 'Updates')),
                        Container(width: 1, height: 40, color: AppColors.dividerLight),
                        Expanded(child: _StatCell(value: '${controller.rating} ★', label: 'Rating')),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('verification_status'.tr, style: AppTextStyles.overline(context)),
                  const SizedBox(height: AppDimensions.md),

                  AppCard(
                    child: Column(
                      children: [
                        _VerificationRow(
                          icon: Icons.phone_android_rounded,
                          label: 'Phone Number',
                          status: controller.isPhoneVerified ? 'verified' : 'unverified',
                        ),
                        Divider(height: AppDimensions.xl, color: AppColors.dividerLight),
                        _VerificationRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          status: controller.isEmailVerified ? 'verified' : 'pending',
                        ),
                        Divider(height: AppDimensions.xl, color: AppColors.dividerLight),
                        _VerificationRow(
                          icon: Icons.credit_card_outlined,
                          label: 'CNIC',
                          status: controller.isCnicVerified ? 'verified' : 'unsubmitted',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.xl),
                  Text('personal_details'.tr, style: AppTextStyles.overline(context)),
                  const SizedBox(height: AppDimensions.md),

                  Obx(() => AppTextField(
                    label: 'full_name'.tr,
                    hint: 'Ahmed Khan',
                    readOnly: !controller.isEditing.value,
                  )),
                  const SizedBox(height: AppDimensions.md),
                  Obx(() => AppTextField(
                    label: 'email'.tr,
                    hint: 'ahmed.khan@gmail.com',
                    readOnly: !controller.isEditing.value,
                    keyboardType: TextInputType.emailAddress,
                  )),
                  const SizedBox(height: AppDimensions.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h3(context)),
        Text(label, style: AppTextStyles.caption(context)),
      ],
    );
  }
}

class _VerificationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;

  const _VerificationRow({
    required this.icon,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(child: Text(label, style: AppTextStyles.labelLarge(context))),
        _StatusBadge(status: status),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'verified':
        return const Text('✓ VERIFIED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success));
      case 'pending':
        return const Text('Verify', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning));
      default:
        return const Text('Submit', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight));
    }
  }
}
