import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/projects_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/common/app_text_field.dart';

class NewProjectWizardScreen extends GetView<ProjectsController> {
  const NewProjectWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('new_project'.tr),
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'Step ${controller.wizardStep.value + 1} of 4',
                  style: AppTextStyles.labelMedium(context),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step indicator
          Obx(() => _StepIndicator(currentStep: controller.wizardStep.value)),
          Expanded(
            child: Obx(() {
              switch (controller.wizardStep.value) {
                case 0:
                  return _Step1Details(controller: controller);
                case 1:
                  return _Step2Budget();
                case 2:
                  return _Step3Contractor();
                case 3:
                  return _Step4Review(controller: controller);
                default:
                  return const SizedBox();
              }
            }),
          ),
          _WizardFooter(controller: controller),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final labels = ['Details', 'Budget', 'Contractor', 'Review'];
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isActive = i == currentStep;
          final isCompleted = i < currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCompleted || isActive
                              ? AppColors.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted || isActive
                                ? AppColors.primary
                                : AppColors.borderLight,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check_rounded,
                                  size: 14, color: Colors.white)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.textTertiaryLight,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondaryLight,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 18),
                      color: i < currentStep
                          ? AppColors.primary
                          : AppColors.borderLight,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Step1Details extends StatelessWidget {
  final ProjectsController controller;
  const _Step1Details({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical: AppDimensions.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('project_details'.tr, style: AppTextStyles.h2(context)),
          const SizedBox(height: 4),
          Text('tell_us_about_project'.tr, style: AppTextStyles.bodySmall(context)),
          const SizedBox(height: AppDimensions.xl),

          Text('project_type'.tr, style: AppTextStyles.labelMedium(context)),
          const SizedBox(height: AppDimensions.sm),
          Obx(
            () => GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppDimensions.md,
              mainAxisSpacing: AppDimensions.md,
              childAspectRatio: 2.5,
              children: ['House', 'Commercial', 'Renovation', 'Single Room']
                  .map(
                    (type) => _TypeCard(
                      label: type,
                      icon: _typeIcon(type),
                      selected: controller.selectedProjectType.value == type,
                      onTap: () => controller.selectedProjectType.value = type,
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: AppDimensions.xl),
          AppTextField(
            label: 'project_name'.tr,
            hint: 'DHA House — 10 Marla',
            onChanged: (v) => controller.projectName.value = v,
          ),
          const SizedBox(height: AppDimensions.md),
          AppTextField(
            label: 'city'.tr,
            hint: 'Lahore',
            onChanged: (v) => controller.projectCity.value = v,
            suffix: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          ),
          const SizedBox(height: AppDimensions.md),
          AppTextField(
            label: 'area_neighborhood'.tr,
            hint: 'DHA Phase 6',
            onChanged: (v) => controller.projectArea.value = v,
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AppTextField(
                  label: 'plot_size'.tr,
                  hint: '10',
                  keyboardType: TextInputType.number,
                  onChanged: (v) => controller.projectPlotSize.value = v,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: AppTextField(
                  label: ' ',
                  hint: 'Marla',
                  readOnly: true,
                  suffix: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          AppTextField(
            label: 'estimated_start_date'.tr,
            hint: 'Select date',
            readOnly: true,
            suffix: const Icon(Icons.calendar_today_outlined, size: 18),
            onTap: () async {
              await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'House': return Icons.home_outlined;
      case 'Commercial': return Icons.business_outlined;
      case 'Renovation': return Icons.chair_outlined;
      case 'Single Room': return Icons.sensor_window_outlined;
      default: return Icons.home_outlined;
    }
  }
}

class _TypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? AppColors.infoLight : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.primary : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step2Budget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Budget & Timeline', style: AppTextStyles.h2(context)),
          const SizedBox(height: AppDimensions.xl),
          AppTextField(
            label: 'Total Budget (PKR)',
            hint: '50,00,000',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppDimensions.md),
          AppTextField(
            label: 'Target Completion Date',
            hint: 'Select date',
            readOnly: true,
            suffix: const Icon(Icons.calendar_today_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}

class _Step3Contractor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assign Contractor', style: AppTextStyles.h2(context)),
          const SizedBox(height: AppDimensions.xl),
          AppTextField(
            label: 'Contractor Name or Phone',
            hint: 'Search contractor...',
            suffix: const Icon(Icons.search_rounded, size: 20),
          ),
          const SizedBox(height: AppDimensions.xl),
          Text('Skip for now — assign later', style: AppTextStyles.bodySmall(context)),
        ],
      ),
    );
  }
}

class _Step4Review extends StatelessWidget {
  final ProjectsController controller;
  const _Step4Review({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review', style: AppTextStyles.h2(context)),
          const SizedBox(height: 4),
          Text('Confirm your project details', style: AppTextStyles.bodySmall(context)),
          const SizedBox(height: AppDimensions.xl),
          Obx(
            () => _ReviewRow('Project Type', controller.selectedProjectType.value),
          ),
          Obx(
            () => _ReviewRow('Name', controller.projectName.value.isEmpty ? '—' : controller.projectName.value),
          ),
          Obx(
            () => _ReviewRow('City', controller.projectCity.value),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: AppTextStyles.labelMedium(context)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium(context))),
        ],
      ),
    );
  }
}

class _WizardFooter extends StatelessWidget {
  final ProjectsController controller;
  const _WizardFooter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.dividerLight),
        ),
      ),
      child: Obx(
        () => AppButton(
          label: controller.wizardStep.value == 3
              ? 'Create Project'
              : 'next_budget_timeline'.tr,
          onPressed: () {
            if (controller.wizardStep.value < 3) {
              controller.nextWizardStep();
            } else {
              Get.back();
            }
          },
        ),
      ),
    );
  }
}
