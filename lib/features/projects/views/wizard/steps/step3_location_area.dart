import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../controllers/project_wizard_controller.dart';
import '../../../config/wizard_step_config.dart';
import '../../../../../core/utils/unit_converter.dart';
import '../widgets/plot_3d_visualizer.dart';

class Step3LocationArea extends GetView<ProjectWizardController> {
  const Step3LocationArea({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // â”€â”€ Location section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _SectionHeader('ðŸ“ Location'),
          const SizedBox(height: 14),
          const _CountryPicker(),
          const SizedBox(height: 14),
          const _CityPicker(),
          const SizedBox(height: 14),
          _NeighbourhoodInput(),
          // â”€â”€ Plot & Area (conditional) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Obx(() => controller.showPlotArea
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _SectionHeader('ðŸ“ Plot & Area'),
                    const SizedBox(height: 14),
                    const _PlotSizeInput(),
                    const SizedBox(height: 14),
                    const _ConstructionAreaInput(),
                    const SizedBox(height: 14),
                    const _DimensionsRow(),
                    // â”€â”€ 3D Visualizer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    const SizedBox(height: 20),
                    const _VisualizerSection(),
                  ],
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

// â”€â”€ Section header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
      );
}

// â”€â”€ Input wrapper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
      );
}

// â”€â”€ Country picker â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CountryPicker extends GetView<ProjectWizardController> {
  const _CountryPicker();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Label('Country'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedCountryCode.value,
                  isExpanded: true,
                  style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                  onChanged: (v) {
                    if (v != null) controller.selectCountry(v);
                  },
                  items: kAllCountries.map((c) => DropdownMenuItem(
                        value: c.code,
                        child: Row(
                          children: [
                            Text(_flag(c.code),
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Text(c.name),
                          ],
                        ),
                      )).toList(),
                ),
              ),
            ),
          ],
        ));
  }

  static String _flag(String iso) {
    // Convert ISO code to flag emoji
    return iso.toUpperCase().runes.map((r) =>
        String.fromCharCode(r - 65 + 0x1F1E6)).join();
  }
}

// â”€â”€ City picker with custom entry â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CityPicker extends GetView<ProjectWizardController> {
  const _CityPicker();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cities = controller.citiesForCountry;
      final selected = controller.selectedCity.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('City'),
          // Preset cities as chips
          if (cities.isNotEmpty) ...[
            Wrap(
              spacing: 8, runSpacing: 8,
              children: cities.map((city) {
                final isSel = selected == city &&
                    controller.customCity.value.isEmpty;
                return GestureDetector(
                  onTap: () => controller.selectCity(city),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSel
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isSel ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                          width: isSel ? 0 : 1),
                    ),
                    child: Text(city,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isSel
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSel ? Colors.white : Theme.of(context).colorScheme.onSurface)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
          // Custom city input
          TextFormField(
            initialValue: controller.customCity.value,
            decoration: InputDecoration(
              hintText: 'Or type a custom cityâ€¦',
              hintStyle: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
              prefixIcon: Icon(Icons.search_rounded, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
            ),
            style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
            onChanged: (v) {
              controller.customCity.value = v;
              if (controller.locationError.value != null) {
                controller.locationError.value = null;
              }
            },
          ),
          // Location inline error
          Obx(() {
            final err = controller.locationError.value;
            if (err == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(err,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.error)),
            );
          }),
        ],
      );
    });
  }
}

// â”€â”€ Neighbourhood â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _NeighbourhoodInput extends GetView<ProjectWizardController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Area / Neighbourhood (optional)'),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'e.g. DHA Phase 6, Gulberg, Clifton',
            hintStyle: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).dividerColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).dividerColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
          ),
          style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
          onChanged: (v) => controller.neighbourhood.value = v,
        ),
      ],
    );
  }
}

// â”€â”€ Plot size input â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _PlotSizeInput extends GetView<ProjectWizardController> {
  const _PlotSizeInput();

  static const _units = ['marla', 'kanal', 'sqft', 'sqm', 'sqyd', 'acre'];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Label('Plot Size'),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: controller.plotSizeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco(context, 'e.g. 5'),
                    style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                    onChanged: controller.onPlotSizeChanged,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.plotUnit.value,
                        isExpanded: true,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                        onChanged: (v) {
                          if (v != null) controller.plotUnit.value = v;
                        },
                        items: _units.map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(UnitConverter.label(u)),
                            )).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Hint
            Obx(() {
              final hint = controller.plotHintText.value;
              if (hint.isEmpty) return const SizedBox.shrink();
              return Text('= $hint',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Theme.of(context).colorScheme.primary));
            }),
            // Plot size inline error (Fix 12)
            Obx(() {
              final err = controller.plotSizeError.value;
              if (err == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4, left: 2),
                child: Text(err,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error)),
              );
            }),
          ],
        ));
  }
}

// â”€â”€ Construction area input â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ConstructionAreaInput extends GetView<ProjectWizardController> {
  const _ConstructionAreaInput();

  static const _units = ['marla', 'kanal', 'sqft', 'sqm', 'sqyd'];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Label('Covered / Construction Area'),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: controller.constructionAreaCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco(context, 'Covered area'),
                    style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                    onChanged: (_) {
                      if (controller.coveredAreaError.value != null) {
                        controller.coveredAreaError.value = null;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.constructionAreaUnit.value,
                        isExpanded: true,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                        onChanged: (v) {
                          if (v != null) {
                            controller.constructionAreaUnit.value = v;
                          }
                        },
                        items: _units.map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(UnitConverter.label(u)),
                            )).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Covered area inline error (Fix 12)
            Obx(() {
              final err = controller.coveredAreaError.value;
              if (err == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4, left: 2),
                child: Text(err,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error)),
              );
            }),
          ],
        ));
  }
}

// â”€â”€ Dimensions row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _DimensionsRow extends GetView<ProjectWizardController> {
  const _DimensionsRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Plot Dimensions (optional)'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.plotWidthCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDeco(context, 'Width (ft)'),
                style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                onChanged: (_) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('×',
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
            Expanded(
              child: TextField(
                controller: controller.plotDepthCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDeco(context, 'Depth (ft)'),
                style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// â”€â”€ 3D Visualizer section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _VisualizerSection extends GetView<ProjectWizardController> {
  const _VisualizerSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Read reactive fields first â€” GetX needs at least one .value access
      // before any early return so it can subscribe correctly.
      final sqm    = controller.plotSizeSqmObs.value;
      final floors = (controller.fieldValues['floors'] as int?) ?? 1;

      if (sqm == null || sqm <= 0) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('ðŸ—ï¸', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('Plot Preview',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E3A8A).withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Plot3DVisualizer(
                plotSizeSqm: sqm,
                coveredAreaSqm: controller.constructionAreaSqm,
                widthM: controller.plotWidthM,
                depthM: controller.plotDepthM,
                floors: floors,
              ),
            ),
          ).animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms,
                  curve: Curves.easeOutCubic),
          const SizedBox(height: 8),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: const Color(0xFF93C5FD).withValues(alpha: 0.5),
                  label: 'Plot Area'),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFF2563EB),
                  label: 'Covered Area'),
              if (floors > 1) ...[
                const SizedBox(width: 16),
                _LegendDot(color: const Color(0xFF4F46E5),
                    label: '$floors Floors'),
              ],
            ],
          ),
        ],
      );
    });
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      );
}

// â”€â”€ Shared input decoration â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

InputDecoration _inputDeco(BuildContext context, String hint) => InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
    );



