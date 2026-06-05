import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../controllers/project_wizard_controller.dart';
import '../../../config/wizard_step_config.dart';

class Step2DynamicDetails extends GetView<ProjectWizardController> {
  const Step2DynamicDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fields = controller.selectedConfig.step2Fields;
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
        itemCount: fields.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (_, i) => _FieldWidget(field: fields[i])
            .animate(delay: Duration(milliseconds: i * 60))
            .fadeIn(duration: 250.ms)
            .slideY(
                begin: 0.08, end: 0,
                duration: 250.ms, curve: Curves.easeOut),
      );
    });
  }
}

// ── Field dispatcher ──────────────────────────────────────────────────────────

class _FieldWidget extends StatelessWidget {
  final FieldConfig field;
  const _FieldWidget({required this.field});

  @override
  Widget build(BuildContext context) => switch (field.type) {
        FieldType.textInput       => _TextInputField(field: field),
        FieldType.textArea        => _TextAreaField(field: field),
        FieldType.numberCounter   => _CounterField(field: field),
        FieldType.qualitySelector => _QualityField(field: field),
        FieldType.chipSelector    => _ChipField(field: field),
        FieldType.yesNoToggle     => _YesNoField(field: field),
        FieldType.areaInput       => _AreaField(field: field),
      };
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface)),
      );
}

InputDecoration _inputDeco(BuildContext context, {String? hint}) {
  final cs      = Theme.of(context).colorScheme;
  final surface = cs.surface;
  final divider = Theme.of(context).dividerColor;
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
    filled: true,
    fillColor: surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: divider)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: divider)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cs.primary, width: 1.5)),
  );
}

// ── Text input ────────────────────────────────────────────────────────────────

class _TextInputField extends GetView<ProjectWizardController> {
  final FieldConfig field;
  const _TextInputField({required this.field});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(field.label),
        TextFormField(
          initialValue: controller.getFieldValue<String>(field.key) ?? '',
          decoration: _inputDeco(context,
              hint: field.hint ?? 'Enter ${field.label.toLowerCase()}'),
          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
          onChanged: (v) => controller.setFieldValue(field.key, v),
        ),
      ],
    );
  }
}

// ── Text area ─────────────────────────────────────────────────────────────────

class _TextAreaField extends GetView<ProjectWizardController> {
  final FieldConfig field;
  const _TextAreaField({required this.field});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(field.label),
        TextFormField(
          maxLines: 4,
          initialValue: controller.getFieldValue<String>(field.key) ?? '',
          decoration: _inputDeco(context, hint: field.hint ?? '').copyWith(
              contentPadding: const EdgeInsets.all(14)),
          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
          onChanged: (v) => controller.setFieldValue(field.key, v),
        ),
      ],
    );
  }
}

// ── Number counter ────────────────────────────────────────────────────────────

class _CounterField extends GetView<ProjectWizardController> {
  final FieldConfig field;
  const _CounterField({required this.field});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    return Obx(() {
      final val = controller.getFieldValue<int>(field.key) ?? field.min ?? 1;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(field.label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: divider),
            ),
            child: Row(
              children: [
                _CounterButton(
                  icon: Icons.remove_rounded,
                  enabled: val > (field.min ?? 1),
                  primary: cs.primary,
                  onTap: () => controller.setFieldValue(field.key,
                      (val - 1).clamp(field.min ?? 1, field.max ?? 99)),
                ),
                Expanded(
                  child: Text('$val',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: cs.primary)),
                ),
                _CounterButton(
                  icon: Icons.add_rounded,
                  enabled: val < (field.max ?? 99),
                  primary: cs.primary,
                  onTap: () => controller.setFieldValue(field.key,
                      (val + 1).clamp(field.min ?? 1, field.max ?? 99)),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color primary;
  final VoidCallback onTap;
  const _CounterButton({
    required this.icon,
    required this.enabled,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38, height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? primary : cs.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20,
            color: enabled ? Colors.white : cs.onSurfaceVariant),
      ),
    );
  }
}

// ── Quality selector ──────────────────────────────────────────────────────────

class _QualityField extends GetView<ProjectWizardController> {
  final FieldConfig field;
  const _QualityField({required this.field});

  static const _details = {
    'Economy':  ('Basic finishes, standard materials', '💰'),
    'Standard': ('Good quality, mid-range finishes', '🏠'),
    'Premium':  ('High quality, imported materials', '⭐'),
    'Luxury':   ('Top-of-line, custom everything', '👑'),
  };

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    return Obx(() {
      final selected =
          controller.getFieldValue<String>(field.key) ?? 'Standard';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(field.label),
          ...kQualityTiers.map((tier) {
            final isSelected = selected == tier;
            final det = _details[tier]!;
            return GestureDetector(
              onTap: () => controller.setFieldValue(field.key, tier),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.primary.withValues(alpha: 0.06)
                      : surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? cs.primary : divider,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(det.$2, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tier,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? cs.primary
                                      : cs.onSurface)),
                          Text(det.$1,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded,
                          color: cs.primary, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}

// ── Chip selector ─────────────────────────────────────────────────────────────

class _ChipField extends GetView<ProjectWizardController> {
  final FieldConfig field;
  const _ChipField({required this.field});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;
    final options = field.options ?? [];

    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel(field.label),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: options.map((opt) {
                final sel = controller.isChipSelected(field.key, opt);
                return GestureDetector(
                  onTap: () =>
                      controller.toggleChipValue(field.key, opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? cs.primary : surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? cs.primary : divider,
                          width: sel ? 0 : 1),
                    ),
                    child: Text(opt,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: sel
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color:
                                sel ? Colors.white : cs.onSurface)),
                  ),
                );
              }).toList(),
            ),
          ],
        ));
  }
}

// ── Yes/No toggle ─────────────────────────────────────────────────────────────

class _YesNoField extends GetView<ProjectWizardController> {
  final FieldConfig field;
  const _YesNoField({required this.field});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      final val = controller.getFieldValue<bool>(field.key) ?? false;
      return Row(
        children: [
          Expanded(
            child: Text(field.label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface)),
          ),
          _YesNoButton(
              label: 'Yes', selected: val, primary: cs.primary,
              onTap: () => controller.setFieldValue(field.key, true)),
          const SizedBox(width: 8),
          _YesNoButton(
              label: 'No', selected: !val, primary: cs.primary,
              onTap: () => controller.setFieldValue(field.key, false)),
        ],
      );
    });
  }
}

class _YesNoButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;
  const _YesNoButton({
    required this.label,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary : surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? primary : divider,
              width: selected ? 0 : 1),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : cs.onSurface)),
      ),
    );
  }
}

// ── Area input ────────────────────────────────────────────────────────────────

class _AreaField extends GetView<ProjectWizardController> {
  final FieldConfig field;
  const _AreaField({required this.field});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(field.label),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: _inputDeco(context, hint: field.hint ?? '0'),
                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                onChanged: (v) => controller.setFieldValue(field.key, v),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: divider),
              ),
              child: Text('ft',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ],
    );
  }
}
