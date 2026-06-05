import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/common/app_card.dart';

class ProjectHandoverScreen extends StatelessWidget {
  const ProjectHandoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    const checklistItems = [
      'All snagging resolved',
      'Final inspection done',
      'Utility connections active',
      'Keys exchanged',
      'Documents handed over',
      'Final payment cleared',
    ];

    return Scaffold(
      appBar: AppBar(title: Text('project_handover'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          children: [
            // Celebration banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.xl),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.home_outlined,
                        color: AppColors.success, size: 40),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    '🎉 Construction Complete!',
                    style: AppTextStyles.h2(context)
                        .copyWith(color: AppColors.success),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'DHA House — 10 Marla · Handover on 10 Oct 2025',
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
                    child: _HandoverStat(value: '12', label: 'Months'),
                  ),
                  Container(width: 1, height: 40, color: divider),
                  Expanded(
                    child: _HandoverStat(
                      value: 'PKR\n48.5L',
                      label: 'Total cost',
                      valueColor: cs.primary,
                    ),
                  ),
                  Container(width: 1, height: 40, color: divider),
                  Expanded(
                    child: _HandoverStat(value: '10 / 10', label: 'Stages'),
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
                      const Text(
                        '6 of 6 Complete',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.md),
                  ...checklistItems.map(
                    (item) => _ChecklistRow(label: item, done: true),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.xl),

            AppButton(
              label: '🔑 Mark Project Complete',
              onPressed: () => Get.back(),
            ),

            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
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
            fontSize: 16,
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
              border: Border.all(
                  color: done ? AppColors.success : divider),
            ),
            child: done
                ? const Icon(Icons.check_rounded,
                    size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
              child: Text(label, style: AppTextStyles.bodyMedium(context))),
          if (done)
            const Text(
              'DONE',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success),
            ),
        ],
      ),
    );
  }
}
