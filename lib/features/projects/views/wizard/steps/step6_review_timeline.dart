import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../controllers/project_wizard_controller.dart';
import '../../../config/wizard_step_config.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../widgets/interactive_timeline.dart';

class Step6ReviewTimeline extends GetView<ProjectWizardController> {
  const Step6ReviewTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scrollable content
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // â”€â”€ Summary card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: const _SummaryCard(),
              ),
              const SizedBox(height: 20),
              // â”€â”€ Timeline section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _TimelineHeader(),
              ),
              const SizedBox(height: 12),
              // â”€â”€ Interactive timeline â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              const _TimelineList(),
              const SizedBox(height: 12),
              // â”€â”€ Timeline hint â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Obx(() => controller.editModeActive.value
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _HintBanner(),
                    )),
              const SizedBox(height: 20),
            ],
          ),
        ),
        // Toast notification (shown after timeline edits)
        const _TimelineToast(),
      ],
    );
  }
}

// â”€â”€ Summary card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SummaryCard extends GetView<ProjectWizardController> {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cfg      = controller.selectedConfig;
      final name     = controller.getFieldValue<String>('name') ?? cfg.label;
      final quality  = controller.getFieldValue<String>('quality') ?? 'Standard';
      final floors   = controller.getFieldValue<int>('floors') ?? 1;
      final city     = controller.effectiveCity;
      final country  = controller.selectedCountry.name;
      final budget   = controller.budget;
      final currency = controller.currencyCode;
      final start    = controller.startDate.value;
      final ctType   = controller.teamOptions
          .firstWhereOrNull((t) => t.key == controller.contractorType.value);

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Color.lerp(Theme.of(context).colorScheme.primary, Colors.blue, 0.3) ??
                  Theme.of(context).colorScheme.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(cfg.icon, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: GoogleFonts.inter(
                              fontSize: 18, fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      Text(cfg.label,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(quality,
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Info grid
            _SummaryGrid(items: [
              _SummaryItem(icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: city.isNotEmpty ? '$city, $country' : country),
              _SummaryItem(icon: Icons.layers_outlined,
                  label: 'Floors',
                  value: '$floors ${floors == 1 ? 'floor' : 'floors'}'),
              if (budget > 0)
                _SummaryItem(icon: Icons.payments_outlined,
                    label: 'Budget',
                    value: CurrencyFormatter.formatCompact(budget,
                        currency: currency)),
              _SummaryItem(icon: Icons.calendar_today_outlined,
                  label: 'Start',
                  value: '${start.day}/${start.month}/${start.year}'),
              if (ctType != null)
                _SummaryItem(icon: Icons.people_outline,
                    label: 'Team',
                    value: ctType.label),
              _SummaryItem(icon: Icons.task_alt_outlined,
                  label: 'Stages',
                  value: '${controller.stages.length} stages'),
            ]),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
    });
  }
}

class _SummaryGrid extends StatelessWidget {
  final List<_SummaryItem> items;
  const _SummaryGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 8,
      childAspectRatio: 2.8,
      children: items.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 13,
                    color: Colors.white.withValues(alpha: 0.7)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item.label,
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              height: 1.2,
                              color: Colors.white.withValues(alpha: 0.6))),
                      Text(item.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
    );
  }
}

class _SummaryItem {
  final IconData icon;
  final String label;
  final String value;
  const _SummaryItem({required this.icon, required this.label, required this.value});
}

// â”€â”€ Timeline section header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _TimelineHeader extends GetView<ProjectWizardController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final editMode = controller.editModeActive.value;
      return Row(
        children: [
          Expanded(
            child: Text('Construction Timeline',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
          ),
          if (editMode) ...[
            GestureDetector(
              onTap: () {
                controller.toggleEditMode();
                HapticFeedback.lightImpact();
                Get.snackbar(
                  'Timeline Updated',
                  'Stages have been reordered and dates recalculated',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(16),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Done',
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ).animate().scale(
                begin: const Offset(0.8, 0.8), end: const Offset(1, 1),
                curve: Curves.elasticOut),
          ] else ...[
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                controller.toggleEditMode();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_rounded, size: 13, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4),
                    Text('Edit',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

// â”€â”€ Timeline list (interactive) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _TimelineList extends GetView<ProjectWizardController> {
  const _TimelineList();

  @override
  Widget build(BuildContext context) {
    return Obx(() => InteractiveTimeline(
          stages: controller.stages,
          editMode: controller.editModeActive.value,
          onReorder: controller.reorderStages,
          onDelete: controller.deleteStage,
          onToggleEditMode: controller.toggleEditMode,
        ));
  }
}

// â”€â”€ Hint banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _HintBanner extends GetView<ProjectWizardController> {
  @override
  Widget build(BuildContext context) {
    if (controller.stages.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          const Text('ðŸ’¡', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Long-press any stage to enter edit mode. Drag to reorder. '
              'Tap the red circle to delete.',
              style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Toast notification â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _TimelineToast extends StatelessWidget {
  const _TimelineToast();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  // GetX snackbar is used instead for timeline update toasts
}



