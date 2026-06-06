import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/projects_controller.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/common/app_card.dart';

class ProjectHandoverScreen extends GetView<ProjectsController> {
  const ProjectHandoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Scaffold(
      appBar: AppBar(title: Text('project_handover'.tr)),
      body: Obx(() {
        final project = controller.selectedProject.value;
        if (project == null) {
          return const Center(child: Text('No project selected'));
        }

        final stages     = project.stages;
        final totalStages = stages.length;

        // Count completed stages using the override map
        int completedCount = 0;
        for (final s in stages) {
          final status = controller.stageStatus(s.id, s.status.name);
          if (status == 'completed') completedCount++;
        }

        final allDone    = totalStages > 0 && completedCount == totalStages;
        final totalCost  = project.actualCost > 0 ? project.actualCost : project.budgetAmount;
        final months     = project.startDate != null
            ? (DateTime.now().difference(project.startDate!).inDays / 30).round()
            : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            children: [
              // Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.xl),
                decoration: BoxDecoration(
                  color: allDone
                      ? AppColors.success.withValues(alpha: 0.1)
                      : cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: allDone
                            ? AppColors.success.withValues(alpha: 0.2)
                            : cs.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        allDone ? Icons.home_outlined : Icons.construction_rounded,
                        color: allDone ? AppColors.success : cs.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      allDone ? '🎉 Construction Complete!' : '🏗️ In Progress',
                      style: AppTextStyles.h2(context).copyWith(
                          color: allDone ? AppColors.success : cs.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.name,
                      style: AppTextStyles.caption(context),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.xl),

              // Stats
              AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _HandoverStat(
                          value: '$months', label: 'Months'),
                    ),
                    Container(width: 1, height: 40, color: divider),
                    Expanded(
                      child: _HandoverStat(
                        value: CurrencyFormatter.formatPKR(totalCost),
                        label: 'Total cost',
                        valueColor: cs.primary,
                      ),
                    ),
                    Container(width: 1, height: 40, color: divider),
                    Expanded(
                      child: _HandoverStat(
                          value: '$completedCount / $totalStages',
                          label: 'Stages'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.xl),

              // Checklist
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('handover_checklist'.tr,
                              style: AppTextStyles.h3(context)),
                        ),
                        Text(
                          '$completedCount of $totalStages Complete',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: allDone ? AppColors.success : cs.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    if (stages.isEmpty)
                      Text('No stages found for this project.',
                          style: AppTextStyles.bodySmall(context))
                    else
                      ...stages.map((stage) {
                        final status = controller.stageStatus(
                            stage.id, stage.status.name);
                        final done = status == 'completed';
                        return _ChecklistRow(
                            label: stage.name, done: done);
                      }),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.xl),

              AppButton(
                label: allDone
                    ? '🔑 Mark Project Complete'
                    : 'Complete all stages to finalize',
                onPressed: allDone ? () => Get.back() : null,
              ),

              const SizedBox(height: AppDimensions.xxl),
            ],
          ),
        );
      }),
    );
  }
}

class _HandoverStat extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _HandoverStat({required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? cs.primary,
          ),
        ),
        Text(label, style: AppTextStyles.caption(context)),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final String label;
  final bool done;

  const _ChecklistRow({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: done ? AppColors.success : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: done ? AppColors.success : divider),
            ),
            child: done
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium(context))),
          if (done)
            const Text('DONE',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success)),
        ],
      ),
    );
  }
}
