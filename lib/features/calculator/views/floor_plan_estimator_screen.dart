import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/floor_plan_estimator_controller.dart';

class FloorPlanEstimatorScreen extends StatelessWidget {
  const FloorPlanEstimatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(FloorPlanEstimatorController());
    final cs   = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(cs: cs),
            Expanded(
              child: Obx(() => _buildBody(context, ctrl, cs)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FloorPlanEstimatorController ctrl, ColorScheme cs) {
    return switch (ctrl.currentStep.value) {
      0 => _StepUpload(ctrl: ctrl, cs: cs),
      1 => _StepProcessing(ctrl: ctrl, cs: cs),
      2 => _StepResults(ctrl: ctrl, cs: cs),
      _ => const SizedBox.shrink(),
    };
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final ColorScheme cs;
  const _Header({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Floor Plan Estimator',
                    style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('AI-Powered • Upload your architectural drawings',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
                const SizedBox(width: 4),
                Text('AI',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Upload ────────────────────────────────────────────────────────────

class _StepUpload extends StatelessWidget {
  final FloorPlanEstimatorController ctrl;
  final ColorScheme cs;
  const _StepUpload({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intro card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('🤖', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How it works',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface)),
                      const SizedBox(height: 4),
                      Text(
                        'Upload your floor plans → Our system analyzes room dimensions, wall lengths, and areas → Generates accurate material quantities and cost estimates.',
                        style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: cs.onSurfaceVariant,
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Upload Floor Plans',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface)),
          const SizedBox(height: 4),
          Text('You can upload one or more floor plans (Ground Floor, First Floor, etc.)',
              style: GoogleFonts.inter(
                  fontSize: 12.5, color: cs.onSurfaceVariant, height: 1.4)),
          const SizedBox(height: 20),

          // Upload drop zone
          GestureDetector(
            onTap: () => ctrl.pickFile(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.4),
                  width: 2,
                  // dashed would need CustomPainter — using solid here
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.upload_file_rounded,
                        size: 32, color: Color(0xFF0F766E)),
                  ),
                  const SizedBox(height: 14),
                  Text('Tap to Upload Floor Plan',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                  const SizedBox(height: 6),
                  Text('PDF, JPG, PNG supported',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('Max file size: 20 MB',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Supported formats row
          Row(
            children: [
              _FormatBadge(label: 'PDF', color: const Color(0xFFDC2626)),
              const SizedBox(width: 8),
              _FormatBadge(label: 'JPG', color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              _FormatBadge(label: 'PNG', color: const Color(0xFF7C3AED)),
              const SizedBox(width: 8),
              _FormatBadge(label: 'DWG', color: const Color(0xFF64748B), comingSoon: true),
            ],
          ),
          const SizedBox(height: 24),

          // Uploaded plans list
          Obx(() {
            if (ctrl.uploadedPlans.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Uploaded Plans (${ctrl.uploadedPlans.length})',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface)),
                const SizedBox(height: 10),
                ...ctrl.uploadedPlans.asMap().entries.map(
                      (e) => _UploadedPlanTile(
                        plan: e.value,
                        index: e.key,
                        cs: cs,
                        onRemove: () => ctrl.removePlan(e.key),
                      ),
                    ),
                const SizedBox(height: 14),
                // Add another plan button
                GestureDetector(
                  onTap: () => ctrl.pickFile(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF0F766E).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_rounded,
                            size: 18, color: Color(0xFF0F766E)),
                        const SizedBox(width: 6),
                        Text('Add Another Floor Plan',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F766E))),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // City selector
          Text('Construction City',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
          const SizedBox(height: 10),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: FloorPlanEstimatorController.cities.map((city) {
                  final selected = ctrl.selectedCity.value == city;
                  return GestureDetector(
                    onTap: () => ctrl.selectedCity.value = city,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF0F766E)
                            : cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF0F766E)
                              : cs.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(city,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : cs.onSurface)),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 28),

          // Analyze button
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: ctrl.uploadedPlans.isNotEmpty
                      ? () => ctrl.analyzeAndEstimate()
                      : null,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(
                    ctrl.uploadedPlans.isEmpty
                        ? 'Upload a plan to continue'
                        : 'Analyze & Generate Estimate',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        cs.outline.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FormatBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool comingSoon;
  const _FormatBadge(
      {required this.label, required this.color, this.comingSoon = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: comingSoon ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: color.withValues(alpha: comingSoon ? 0.2 : 0.4)),
      ),
      child: Column(
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: comingSoon
                      ? color.withValues(alpha: 0.5)
                      : color)),
          if (comingSoon)
            Text('soon',
                style: GoogleFonts.inter(
                    fontSize: 8, color: color.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}

class _UploadedPlanTile extends StatelessWidget {
  final UploadedPlan plan;
  final int index;
  final ColorScheme cs;
  final VoidCallback onRemove;
  const _UploadedPlanTile(
      {required this.plan,
      required this.index,
      required this.cs,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final iconColor = plan.fileType == 'PDF'
        ? const Color(0xFFDC2626)
        : const Color(0xFF2563EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(plan.fileType,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: iconColor)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.displayName,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface)),
                Text(plan.fileSize,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              size: 18, color: Color(0xFF0F766E)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close_rounded,
                  size: 14, color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Processing / AI analyzing ────────────────────────────────────────

class _StepProcessing extends StatelessWidget {
  final FloorPlanEstimatorController ctrl;
  final ColorScheme cs;
  const _StepProcessing({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Obx(() => _AnimatedScanIcon(
                    progress: ctrl.analyzeProgress.value,
                  )),
            ),
            const SizedBox(height: 28),
            Obx(() => Text(
                  _stepLabel(ctrl.analyzeProgress.value),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface),
                )),
            const SizedBox(height: 10),
            Text(
              'Please wait while we analyze your floor plans\nand calculate material requirements.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13, color: cs.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 28),
            // Progress bar
            Obx(() => ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: ctrl.analyzeProgress.value,
                    minHeight: 6,
                    backgroundColor:
                        const Color(0xFF0F766E).withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF0F766E)),
                  ),
                )),
            const SizedBox(height: 12),
            Obx(() => Text(
                  '${(ctrl.analyzeProgress.value * 100).toInt()}%',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F766E)),
                )),
            const SizedBox(height: 32),
            // Processing steps
            ..._processingSteps(ctrl.analyzeProgress.value).map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      s.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 16,
                      color: s.done
                          ? const Color(0xFF0F766E)
                          : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(s.label,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: s.done ? FontWeight.w600 : FontWeight.w400,
                            color: s.done ? cs.onSurface : cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepLabel(double p) {
    if (p < 0.25) return 'Reading floor plan...';
    if (p < 0.5)  return 'Detecting room dimensions...';
    if (p < 0.75) return 'Calculating material quantities...';
    if (p < 1.0)  return 'Generating cost estimate...';
    return 'Done!';
  }

  List<({String label, bool done})> _processingSteps(double p) => [
        (label: 'Uploading & reading file',           done: p > 0.10),
        (label: 'Identifying rooms & spaces',         done: p > 0.30),
        (label: 'Measuring wall & floor areas',       done: p > 0.55),
        (label: 'Fetching city material prices',      done: p > 0.70),
        (label: 'Calculating material quantities',    done: p > 0.85),
        (label: 'Generating detailed cost report',    done: p >= 1.0),
      ];
}

class _AnimatedScanIcon extends StatelessWidget {
  final double progress;
  const _AnimatedScanIcon({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: progress,
          strokeWidth: 3,
          backgroundColor: const Color(0xFF0F766E).withValues(alpha: 0.2),
          valueColor:
              const AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
        ),
        const Icon(Icons.document_scanner_rounded,
            size: 40, color: Color(0xFF0F766E)),
      ],
    );
  }
}

// ── Step 3: Results ───────────────────────────────────────────────────────────

class _StepResults extends StatelessWidget {
  final FloorPlanEstimatorController ctrl;
  final ColorScheme cs;
  const _StepResults({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    final result = ctrl.result.value;
    if (result == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              children: [
                Text('Total Estimated Cost',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 6),
                Text(result.formattedTotal,
                    style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  '${ctrl.selectedCity.value}  ·  ${ctrl.uploadedPlans.length} floor plan${ctrl.uploadedPlans.length > 1 ? 's' : ''}',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.75)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _HeroStat(label: 'Grey Structure', value: result.formattedGrey),
                    _HeroStat(label: 'Finishing', value: result.formattedFinishing),
                    _HeroStat(label: 'Labour', value: result.formattedLabour),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Floor-wise breakdown
          if (result.floorBreakdowns.isNotEmpty) ...[
            _SectionHeader('Floor-wise Breakdown'),
            const SizedBox(height: 10),
            ...result.floorBreakdowns.map(
              (f) => _FloorBreakdownCard(floor: f, cs: cs),
            ),
            const SizedBox(height: 16),
          ],

          // Material list
          _SectionHeader('Material Quantities'),
          const SizedBox(height: 10),
          ...result.materials.map((m) => _MaterialRow(m: m, cs: cs)),
          const SizedBox(height: 16),

          // Upload another / recalculate
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ctrl.reset(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text('New Estimate',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F766E),
                    side: const BorderSide(color: Color(0xFF0F766E)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'These estimations are generated based on the information provided by the user. Actual material consumption and project costs may vary depending on design specifications, site conditions, construction methods, and market fluctuations.',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Text(title,
      style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface));
}

class _FloorBreakdownCard extends StatelessWidget {
  final FloorBreakdown floor;
  final ColorScheme cs;
  const _FloorBreakdownCard({required this.floor, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(floor.icon,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(floor.name,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface)),
                Text('${floor.areaSqft.toInt()} sqft  ·  ${floor.rooms} rooms detected',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Text(floor.formattedCost,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
        ],
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  final PlanMaterialResult m;
  final ColorScheme cs;
  const _MaterialRow({required this.m, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(m.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface)),
                Text('${m.quantity.toStringAsFixed(0)} ${m.unit}',
                    style: GoogleFonts.inter(
                        fontSize: 10, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Text(m.formattedCost,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
        ],
      ),
    );
  }
}
