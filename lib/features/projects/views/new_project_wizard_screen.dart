import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/project_wizard_controller.dart';
import '../../../core/services/geography_service.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/common/app_text_field.dart';

class NewProjectWizardScreen extends GetView<ProjectWizardController> {
  const NewProjectWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Obx(() => Text(
              'Step ${controller.currentStep.value + 1} of ${ProjectWizardController.totalSteps}',
            )),
        leading: Obx(() => controller.isFirstStep
            ? const BackButton()
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: controller.prevStep,
              )),
      ),
      body: Column(
        children: [
          // ── Progress bar ───────────────────────────────────────────────────
          Obx(() => LinearProgressIndicator(
                value: (controller.currentStep.value + 1) /
                    ProjectWizardController.totalSteps,
                backgroundColor: AppColors.dividerLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 3,
              )),
          // ── Step content ───────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              return AnimatedSwitcher(
                duration: AppConstants.shortAnimation,
                child: KeyedSubtree(
                  key: ValueKey(controller.currentStep.value),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: _stepWidget(controller.currentStep.value, context),
                  ),
                ),
              );
            }),
          ),
          // ── Footer ─────────────────────────────────────────────────────────
          _WizardFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _stepWidget(int step, BuildContext context) => switch (step) {
        0 => _Step0Type(controller: controller),
        1 => _Step1Details(controller: controller),
        2 => _Step2Location(controller: controller),
        3 => _Step3Area(controller: controller),
        4 => _Step4Budget(controller: controller),
        5 => _Step5Timeline(controller: controller),
        6 => _Step6Team(controller: controller),
        _ => _Step7Review(controller: controller),
      };
}

// ── Step labels ───────────────────────────────────────────────────────────────
class AppConstants {
  static const shortAnimation = Duration(milliseconds: 200);
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _WizardFooter extends StatelessWidget {
  final ProjectWizardController controller;
  const _WizardFooter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.dividerLight)),
      ),
      child: Obx(() {
        final isLast    = controller.isLastStep;
        final isCreating = controller.isCreating.value;
        final isGenerating = controller.isGenerating.value;

        return AppButton.primary(
          label: isLast
              ? (isCreating ? 'Creating...' : 'Create Project')
              : (controller.currentStep.value == 5 && isGenerating
                  ? 'Generating Timeline...'
                  : 'Continue'),
          isLoading: isCreating || (controller.currentStep.value == 5 && isGenerating),
          onPressed: () {
            if (isLast) {
              controller.createProject();
            } else {
              if (controller.currentStep.value == 5 &&
                  controller.generatedStages.isEmpty) {
                controller.generateTimeline().then((_) => controller.nextStep());
              } else {
                controller.nextStep();
              }
            }
          },
        );
      }),
    );
  }
}

// ── Step 0: Project Type ──────────────────────────────────────────────────────

class _Step0Type extends StatelessWidget {
  final ProjectWizardController controller;
  const _Step0Type({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What are you building?', style: AppTextStyles.h1(context)),
        const SizedBox(height: 6),
        Text('Select the type of construction',
            style: AppTextStyles.bodySmall(context)),
        const SizedBox(height: 24),
        Obx(() => GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
              children: ProjectWizardController.projectTypes
                  .map((t) => _TypeCard(
                        type: t,
                        isSelected:
                            controller.selectedProjectType.value == t['key'],
                        onTap: () =>
                            controller.selectProjectType(t['key'] as String),
                      ))
                  .toList(),
            )),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final Map<String, String> type;
  final bool isSelected;
  final VoidCallback onTap;
  const _TypeCard(
      {required this.type, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.infoLight : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(type['icon'] ?? '🏠', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              type['label'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 1: Quick Details ─────────────────────────────────────────────────────

class _Step1Details extends StatelessWidget {
  final ProjectWizardController controller;
  const _Step1Details({required this.controller});

  static const List<String> qualityLabels = [
    'Economy', 'Standard', 'Premium', 'Luxury',
  ];
  static const List<String> qualityKeys = [
    'economy', 'standard', 'premium', 'luxury',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Project Details', style: AppTextStyles.h1(context)),
        const SizedBox(height: 6),
        Obx(() => Text(controller.projectTypeLabel,
            style: AppTextStyles.bodySmall(context))),
        const SizedBox(height: 24),
        AppTextField(
          label: 'Project Name',
          hint: 'e.g. DHA House — 10 Marla',
          controller: controller.projectNameCtrl,
        ),
        const SizedBox(height: AppDimensions.md),
        Text('Number of Floors', style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 8),
        Obx(() => Row(
              children: [1, 2, 3, 4].map((f) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => controller.floors.value = f,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 56,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: controller.floors.value == f
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                          border: Border.all(
                            color: controller.floors.value == f
                                ? AppColors.primary
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Text('$f',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: controller.floors.value == f
                                  ? Colors.white
                                  : AppColors.textPrimaryLight,
                            )),
                      ),
                    ),
                  )).toList(),
            )),
        const SizedBox(height: AppDimensions.lg),
        Text('Construction Quality', style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 8),
        Obx(() => Column(
              children: List.generate(qualityKeys.length, (i) {
                final selected =
                    controller.qualityTier.value == qualityKeys[i];
                return GestureDetector(
                  onTap: () =>
                      controller.qualityTier.value = qualityKeys[i],
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.infoLight : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSm),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.borderLight,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(qualityLabels[i],
                              style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textPrimaryLight,
                              )),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
                );
              }),
            )),
      ],
    );
  }
}

// ── Step 2: Location ──────────────────────────────────────────────────────────

class _Step2Location extends StatelessWidget {
  final ProjectWizardController controller;
  const _Step2Location({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: AppTextStyles.h1(context)),
        const SizedBox(height: 6),
        Text('Where is the project?',
            style: AppTextStyles.bodySmall(context)),
        const SizedBox(height: 24),

        // Country
        Text('Country', style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<int>(
              value: controller.selectedCountryId.value,
              onChanged: (v) {
                if (v != null) controller.selectCountry(v);
              },
              items: controller.countries
                  .map((c) => DropdownMenuItem(
                      value: c.id, child: Text(c.name)))
                  .toList(),
              decoration: const InputDecoration(),
            )),
        const SizedBox(height: AppDimensions.md),

        // City
        Text('City', style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 8),
        Obx(() {
          final cities = controller.cities;
          if (cities.isEmpty) {
            return const Text('Select a country first',
                style: TextStyle(color: AppColors.textTertiaryLight));
          }
          return DropdownButtonFormField<int>(
            value: cities.any((c) => c.id == controller.selectedCityId.value)
                ? controller.selectedCityId.value
                : cities.first.id,
            onChanged: (v) {
              if (v != null) controller.selectCity(v);
            },
            items: cities
                .map((c) => DropdownMenuItem(
                    value: c.id, child: Text(c.name)))
                .toList(),
            decoration: const InputDecoration(),
          );
        }),
        const SizedBox(height: AppDimensions.md),

        // Area (optional)
        Text('Area / Neighborhood (optional)',
            style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 8),
        Obx(() {
          final areas = controller.areas;
          if (areas.isEmpty) {
            return const Text('No areas listed for this city',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textTertiaryLight));
          }
          return DropdownButtonFormField<int>(
            value: areas.any((a) => a.id == controller.selectedAreaId.value)
                ? controller.selectedAreaId.value
                : null,
            hint: const Text('Select area'),
            onChanged: (v) => controller.selectedAreaId.value = v,
            items: areas
                .map((a) => DropdownMenuItem(
                    value: a.id, child: Text(a.name)))
                .toList(),
            decoration: const InputDecoration(),
          );
        }),
      ],
    );
  }
}

// ── Step 3: Plot & Area ───────────────────────────────────────────────────────

class _Step3Area extends StatelessWidget {
  final ProjectWizardController controller;
  const _Step3Area({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Plot & Area', style: AppTextStyles.h1(context)),
        const SizedBox(height: 6),
        Text('Enter the size of your plot',
            style: AppTextStyles.bodySmall(context)),
        const SizedBox(height: 24),

        // Plot size
        Text('Plot Size', style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller.plotSizeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'e.g. 5'),
                onChanged: controller.onPlotSizeChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Obx(() => DropdownButtonFormField<String>(
                    value: controller.plotUnit.value,
                    onChanged: (v) => controller.plotUnit.value = v ?? 'marla',
                    items: UnitConverter.pakistanUnits
                        .map((u) => DropdownMenuItem(
                            value: u,
                            child: Text(UnitConverter.label(u))))
                        .toList(),
                    decoration: const InputDecoration(),
                  )),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Obx(() {
          // Always reads plotHintText.value so Obx always has a subscription
          final hint = controller.plotHintText.value;
          if (hint.isEmpty) return const SizedBox.shrink();
          return Text('= $hint',
              style: const TextStyle(fontSize: 12, color: AppColors.accent));
        }),
        const SizedBox(height: AppDimensions.md),

        // Construction area
        Text('Construction / Covered Area',
            style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller.constructionAreaCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(hintText: 'Covered area'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Obx(() => DropdownButtonFormField<String>(
                    value: controller.constructionAreaUnit.value,
                    onChanged: (v) =>
                        controller.constructionAreaUnit.value = v ?? 'marla',
                    items: UnitConverter.pakistanUnits
                        .map((u) => DropdownMenuItem(
                            value: u,
                            child: Text(UnitConverter.label(u))))
                        .toList(),
                    decoration: const InputDecoration(),
                  )),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),

        // Dimensions (optional)
        Text('Plot Dimensions (optional)',
            style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.plotWidthCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    hintText: 'Width (ft)', suffixText: 'ft'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller.plotDepthCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    hintText: 'Depth (ft)', suffixText: 'ft'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Step 4: Budget ────────────────────────────────────────────────────────────

class _Step4Budget extends StatelessWidget {
  final ProjectWizardController controller;
  const _Step4Budget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget', style: AppTextStyles.h1(context)),
        const SizedBox(height: 6),
        Text('Set your total construction budget',
            style: AppTextStyles.bodySmall(context)),
        const SizedBox(height: 24),

        // Budget input
        Text('Total Budget (${controller.currencyCode})',
            style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 8),
        TextField(
          controller: controller.budgetCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'e.g. 5,000,000',
            prefixText: '${controller.currencyCode} ',
          ),
          onChanged: controller.onBudgetChanged,
        ),
        const SizedBox(height: AppDimensions.md),

        // Estimation result
        Obx(() {
          final est = controller.estimatedCost.value;
          if (est <= 0) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Text(
                'Complete Step 3 to see estimated cost',
                style: AppTextStyles.bodySmall(context),
              ),
            );
          }
          final validation = controller.budgetValidation.value;
          final statusColor = validation == null
              ? AppColors.info
              : switch (validation.status.name) {
                  'comfortable' => AppColors.success,
                  'onTrack'     => AppColors.success,
                  'tight'       => AppColors.warning,
                  _             => AppColors.error,
                };

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: statusColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Market Estimate:',
                        style: AppTextStyles.bodySmall(context)),
                    const Spacer(),
                    Text(
                      controller.formattedEstimatedCost,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                if (validation != null) ...[
                  const SizedBox(height: 8),
                  Text(validation.headline,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor)),
                  const SizedBox(height: 4),
                  Text(validation.message,
                      style: AppTextStyles.bodySmall(context)),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: AppDimensions.md),

        // Optional: skip notice
        Text(
          'Budget can be updated anytime after project creation.',
          style: AppTextStyles.caption(context),
        ),
      ],
    );
  }
}

// ── Step 5: Timeline ──────────────────────────────────────────────────────────

class _Step5Timeline extends StatelessWidget {
  final ProjectWizardController controller;
  const _Step5Timeline({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Timeline', style: AppTextStyles.h1(context)),
        const SizedBox(height: 6),
        Text('When do you want to start?',
            style: AppTextStyles.bodySmall(context)),
        const SizedBox(height: 24),

        // Start date picker
        Text('Start Date', style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 8),
        Obx(() => GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: controller.startDate.value,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  controller.startDate.value = picked;
                  controller.generatedStages.clear();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      '${controller.startDate.value.day} '
                      '${_monthName(controller.startDate.value.month)} '
                      '${controller.startDate.value.year}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: AppDimensions.xl),

        // Generate button / result
        Obx(() {
          final stages = controller.generatedStages;
          if (stages.isEmpty) {
            return AppButton.primary(
              label: controller.isGenerating.value
                  ? 'Generating Timeline...'
                  : 'Generate Timeline',
              isLoading: controller.isGenerating.value,
              onPressed: controller.generateTimeline,
            );
          }
          // Show preview
          final projEnd = controller.projectedEndDate;
          final months = projEnd.difference(controller.startDate.value).inDays ~/ 30;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${stages.length} stages generated',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success)),
                          Text(
                              'Est. completion: $months months · '
                              '${projEnd.day}/${projEnd.month}/${projEnd.year}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.success)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.generatedStages.clear();
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('${stages.length} Stages Preview',
                  style: AppTextStyles.labelLarge(context)),
              const SizedBox(height: 8),
              ...stages.take(5).map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(s.name,
                                style: const TextStyle(fontSize: 13))),
                        Text(
                            s.plannedEnd != null
                                ? '${s.plannedEnd!.day}/${s.plannedEnd!.month}'
                                : '',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  )),
              if (stages.length > 5)
                Text('+ ${stages.length - 5} more stages',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondaryLight)),
            ],
          );
        }),
      ],
    );
  }

  static String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return m < months.length ? months[m] : '';
  }
}

// ── Step 6: Team ──────────────────────────────────────────────────────────────

class _Step6Team extends StatelessWidget {
  final ProjectWizardController controller;
  const _Step6Team({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Team', style: AppTextStyles.h1(context)),
        const SizedBox(height: 6),
        Text('Who is managing construction?',
            style: AppTextStyles.bodySmall(context)),
        const SizedBox(height: 8),
        Text('You can skip this and add team members later.',
            style: AppTextStyles.caption(context)),
        const SizedBox(height: 24),

        // Contractor type
        Text('Contractor Type', style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 8),
        Obx(() => Column(
              children: ProjectWizardController.contractorTypes.map((t) {
                final selected =
                    controller.contractorType.value == t['key'];
                return GestureDetector(
                  onTap: () =>
                      controller.contractorType.value = t['key'] as String,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.infoLight : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.borderLight,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t['label'] as String,
                                  style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.textPrimaryLight,
                                  )),
                              Text(t['desc'] as String,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color:
                                          AppColors.textSecondaryLight)),
                            ],
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),
        const SizedBox(height: AppDimensions.md),

        // Supervisor phone (optional)
        Text('Invite Site Supervisor (optional)',
            style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 8),
        AppTextField(
          label: '',
          hint: '+92 3XX XXXXXXX',
          controller: controller.supervisorPhoneCtrl,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

// ── Step 7: Review ────────────────────────────────────────────────────────────

class _Step7Review extends StatelessWidget {
  final ProjectWizardController controller;
  const _Step7Review({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & Create', style: AppTextStyles.h1(context)),
        const SizedBox(height: 6),
        Text('Confirm your project details',
            style: AppTextStyles.bodySmall(context)),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(AppDimensions.base),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Obx(() => Column(
                children: [
                  _ReviewRow(
                      label: 'Type',
                      value: controller.projectTypeLabel,
                      context: context),
                  _ReviewRow(
                      label: 'Name',
                      value: controller.projectName.isNotEmpty
                          ? controller.projectName
                          : '(not set)',
                      context: context),
                  _ReviewRow(
                      label: 'Location',
                      value: [
                        controller.selectedCityName,
                        if (controller.selectedAreaName.isNotEmpty)
                          controller.selectedAreaName,
                      ].join(', '),
                      context: context),
                  _ReviewRow(
                      label: 'Plot Size',
                      value: controller.plotHintText.value.isNotEmpty
                          ? controller.plotHintText.value.split('  =  ').first
                          : (controller.plotSizeCtrl.text.isNotEmpty
                              ? '${controller.plotSizeCtrl.text} ${UnitConverter.label(controller.plotUnit.value)}'
                              : '—'),
                      context: context),
                  _ReviewRow(
                      label: 'Floors',
                      value: '${controller.floors.value}',
                      context: context),
                  _ReviewRow(
                      label: 'Quality',
                      value: controller.qualityLabel,
                      context: context),
                  _ReviewRow(
                      label: 'Budget',
                      value: controller.formattedBudget.isEmpty
                          ? '—'
                          : controller.formattedBudget,
                      context: context),
                  _ReviewRow(
                      label: 'Start Date',
                      value: '${controller.startDate.value.day}/'
                          '${controller.startDate.value.month}/'
                          '${controller.startDate.value.year}',
                      context: context),
                  _ReviewRow(
                      label: 'Contractor',
                      value: ProjectWizardController.contractorTypes
                              .firstWhere(
                                  (t) =>
                                      t['key'] ==
                                      controller.contractorType.value,
                                  orElse: () => {'label': 'Self'})['label'] ??
                          'Self',
                      context: context),
                  _ReviewRow(
                      label: 'Timeline',
                      value: controller.generatedStages.isEmpty
                          ? 'Not generated'
                          : '${controller.generatedStages.length} stages',
                      context: context,
                      isLast: true),
                ],
              )),
        ),
        const SizedBox(height: AppDimensions.md),
        Text(
          'After creation you can edit all details and add workers.',
          style: AppTextStyles.caption(context),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;
  final bool isLast;
  const _ReviewRow({
    required this.label,
    required this.value,
    required this.context,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext ctx) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(label,
                    style: AppTextStyles.labelMedium(context)),
              ),
              Expanded(
                child: Text(value,
                    style: AppTextStyles.bodyMedium(context)),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: AppColors.dividerLight),
      ],
    );
  }
}
