import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/project_wizard_controller.dart';
import 'wizard/steps/step1_project_type.dart';
import 'wizard/steps/step2_dynamic_details.dart';
import 'wizard/steps/step3_location_area.dart';
import 'wizard/steps/step4_budget_timeline.dart';
import 'wizard/steps/step5_team.dart';
import 'wizard/steps/step6_review_timeline.dart';

const _stepLabels = [
  'Project Type',
  'Details',
  'Location & Area',
  'Budget & Timeline',
  'Team',
  'Review',
];

class NewProjectWizardScreen extends GetView<ProjectWizardController> {
  const NewProjectWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _WizardTopBar(controller: controller),
            _SegmentedProgress(controller: controller),
            const SizedBox(height: 4),
            _StepTitle(controller: controller),
            Expanded(
              child: Obx(() {
                final step = controller.currentStep.value;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve:  Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.06, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: anim, curve: Curves.easeOutCubic)),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: KeyedSubtree(
                      key: ValueKey(step), child: _stepWidget(step)),
                );
              }),
            ),
            _BottomCta(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _stepWidget(int step) => switch (step) {
        0 => const Step1ProjectType(),
        1 => const Step2DynamicDetails(),
        2 => const Step3LocationArea(),
        3 => const Step4BudgetTimeline(),
        4 => const Step5Team(),
        _ => const Step6ReviewTimeline(),
      };
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _WizardTopBar extends StatelessWidget {
  final ProjectWizardController controller;
  const _WizardTopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;

    return Container(
      color: surface,
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(
        children: [
          Obx(() => IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: controller.isFirstStep
                    ? () => Get.back()
                    : controller.prevStep,
              )),
          Expanded(
            child: Obx(() => Text(
                  _stepLabels[controller.currentStep.value],
                  style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface),
                )),
          ),
          Obx(() => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${controller.currentStep.value + 1} / ${ProjectWizardController.totalSteps}',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.primary),
                ),
              )),
        ],
      ),
    );
  }
}

// ── Segmented progress bar ────────────────────────────────────────────────────

class _SegmentedProgress extends StatelessWidget {
  final ProjectWizardController controller;
  const _SegmentedProgress({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    return Obx(() {
      final current = controller.currentStep.value;
      // Fix 5: Announce progress as a polite status for screen readers;
      // ExcludeSemantics on the visual bars (the step-counter chip already
      // announces the exact step number).
      return Semantics(
        label: 'Step ${current + 1} of ${ProjectWizardController.totalSteps}',
        liveRegion: true,
        child: ExcludeSemantics(
          child: Container(
            color: surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: List.generate(
                ProjectWizardController.totalSteps,
                (i) => Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    height: 4,
                    margin: EdgeInsets.only(
                        right: i < ProjectWizardController.totalSteps - 1
                            ? 4
                            : 0),
                    decoration: BoxDecoration(
                      color: i <= current ? cs.primary : divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ── Step title ────────────────────────────────────────────────────────────────

class _StepTitle extends StatelessWidget {
  final ProjectWizardController controller;
  const _StepTitle({required this.controller});

  static const _subtitles = [
    'What do you want to build?',
    'Tell us about your project',
    'Where is the project located?',
    'Set your budget and generate a timeline',
    'Who will manage the construction?',
    'Review everything before creating',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      final step = controller.currentStep.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: Align(
          alignment: Alignment.centerLeft,
          // Fix 5: Mark as a heading so screen readers treat it as a section start
          child: Semantics(
            header: true,
            child: Text(
              _subtitles[step],
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ),
      );
    });
  }
}

// ── Bottom CTA ────────────────────────────────────────────────────────────────

class _BottomCta extends StatelessWidget {
  final ProjectWizardController controller;
  const _BottomCta({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: divider)),
      ),
      child: Obx(() {
        final isLast     = controller.isLastStep;
        final isCreating = controller.isCreating.value;

        // Fix 5: Semantics marks the button with a meaningful action label
        return Semantics(
          button: true,
          label: isLast ? 'Create Project' : 'Continue to next step',
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact(); // POLISH 4
              if (isLast) {
                controller.createProject();
              } else {
                controller.nextStep();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: cs.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: isCreating
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  // Fix 3: FittedBox keeps button label on one line at any font scale
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isLast ? 'Create Project 🚀' : 'Continue →',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }
}
