import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../controllers/project_wizard_controller.dart';
import '../../../config/wizard_step_config.dart';
import '../../../../../core/utils/currency_formatter.dart';

class Step4BudgetTimeline extends GetView<ProjectWizardController> {
  const Step4BudgetTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // â”€â”€ Budget section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _SectionHeader('ðŸ’° Budget'),
          const SizedBox(height: 14),
          const _BudgetInput(),
          const SizedBox(height: 10),
          const _EstimateBadge(),
          const SizedBox(height: 28),

          // â”€â”€ Timeline section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _SectionHeader('ðŸ“… Timeline'),
          const SizedBox(height: 14),
          const _StartDatePicker(),
          const SizedBox(height: 16),
          const _GenerateButton(),
          const SizedBox(height: 16),
          const _StagePreviewStrip(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);
  @override
  Widget build(BuildContext context) => Text(label,
      style: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary));
}

// â”€â”€ Budget input â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _BudgetInput extends GetView<ProjectWizardController> {
  const _BudgetInput();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currency = controller.currencyCode;
      return TextFormField(
        controller: controller.budgetCtrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Enter total budget',
          hintStyle: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Text(currency,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary)),
          ),
          prefixIconConstraints: const BoxConstraints(),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
        ),
        style: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
        onChanged: controller.onBudgetChanged,
      );
    });
  }
}

// â”€â”€ AI estimate badge â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _EstimateBadge extends GetView<ProjectWizardController> {
  const _EstimateBadge();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final range = controller.formattedEstimateRange;
      if (range.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text('Enter plot size in Step 3 to see cost estimate',
                  style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        );
      }

      final budget = controller.budget;
      final low    = controller.estimatedCostLow.value;
      final high   = controller.estimatedCostHigh.value;

      Color statusColor = const Color(0xFF16A34A);
      String statusLabel = 'Well Funded';
      IconData statusIcon = Icons.check_circle_outline_rounded;

      if (budget > 0) {
        if (budget < low * 0.8) {
          statusColor = const Color(0xFFDC2626);
          statusLabel = 'May be insufficient';
          statusIcon  = Icons.warning_amber_rounded;
        } else if (budget < low) {
          statusColor = const Color(0xFFF59E0B);
          statusLabel = 'Tight budget';
          statusIcon  = Icons.info_outline_rounded;
        }
      }

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    size: 15, color: statusColor),
                const SizedBox(width: 6),
                Text('Market Estimate',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusLabel,
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(range,
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: statusColor)),
            const SizedBox(height: 4),
            Text(
              'Based on ${controller.getFieldValue<String>('quality') ?? 'Standard'} '
              'quality Ã— covered area Ã— current Lahore rates',
              style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
    });
  }
}

// â”€â”€ Start date picker â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _StartDatePicker extends GetView<ProjectWizardController> {
  const _StartDatePicker();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final date = controller.startDate.value;
      return GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime.now().subtract(const Duration(days: 30)),
            lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
            builder: (_, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(primary: Theme.of(context).colorScheme.primary),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            controller.startDate.value = picked;
            if (controller.stages.isNotEmpty) {
              controller.generateTimeline();
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.calendar_today_rounded,
                    size: 18, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Start Date',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    Text(
                      '${date.day} ${_monthName(date.month)} ${date.year}',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      );
    });
  }

  static String _monthName(int m) {
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return m < names.length ? names[m] : '';
  }
}

// â”€â”€ Generate timeline button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GenerateButton extends GetView<ProjectWizardController> {
  const _GenerateButton();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isGenerating = controller.isGenerating.value;
      final hasStages    = controller.stages.isNotEmpty;

      return GestureDetector(
        onTap: isGenerating ? null : controller.generateTimeline,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hasStages ? Colors.white : Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: hasStages ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: hasStages ? 1.5 : 0),
          ),
          child: isGenerating
              ? SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Theme.of(context).colorScheme.primary))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(hasStages
                        ? Icons.refresh_rounded
                        : Icons.auto_awesome_rounded,
                        size: 18,
                        color: hasStages ? Theme.of(context).colorScheme.primary : Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      hasStages
                          ? 'Regenerate Timeline'
                          : 'Generate Timeline',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: hasStages ? Theme.of(context).colorScheme.primary : Colors.white),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}

// â”€â”€ Stage preview strip (horizontal scroll) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _StagePreviewStrip extends GetView<ProjectWizardController> {
  const _StagePreviewStrip();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stages = controller.stages;
      if (stages.isEmpty) return const SizedBox.shrink();

      final totalDays = stages.fold(0, (s, st) => s + st.durationDays);
      final months = (totalDays / 30).round();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${stages.length} Stages Generated',
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('~$months months',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF16A34A))),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: stages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final s = stages[i];
                final c = _hexColor(s.color);
                return _StageChip(stage: s, color: c, index: i)
                    .animate(delay: Duration(milliseconds: i * 40))
                    .fadeIn(duration: 250.ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
          ),
        ],
      );
    });
  }

  static Color _hexColor(String hex) {
    try { return Color(int.parse(hex.replaceFirst('#', '0xFF'))); }
    catch (_) { return const Color(0xFF1C3A7A); }
  }
}

class _StageChip extends StatelessWidget {
  final WizardStage stage;
  final Color color;
  final int index;
  const _StageChip({required this.stage, required this.color, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${index + 1}',
              style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          Expanded(
            child: Text(stage.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface, height: 1.3)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(stage.formattedDuration,
                style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}



