import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../controllers/team_controller.dart';
import '../data/models/team_model.dart';
import '../../labor/data/models/labor_model.dart';
import '../../../presentation/theme/app_colors.dart';

const _uuid = Uuid();

class AddWorkerScreen extends StatefulWidget {
  const AddWorkerScreen({super.key});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  late final TeamModel _team;
  final _formKey  = GlobalKey<FormState>();
  final _nameFocus = FocusNode();

  final _nameCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _wageCtrl     = TextEditingController();

  String _selectedSkill  = 'Mason';
  WorkerStatus _status   = WorkerStatus.active;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _team = Get.arguments as TeamModel;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _wageCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final worker = TeamWorkerModel(
      id:          _uuid.v4(),
      teamId:      _team.id,
      name:        _nameCtrl.text.trim(),
      phone:       _phoneCtrl.text.trim(),
      skillType:   _selectedSkill,
      dailyWage:   double.parse(_wageCtrl.text.trim()),
      joiningDate: DateTime.now(),
      status:      _status,
    );

    await Get.find<TeamController>().addWorkerToTeam(_team.id, worker);

    setState(() => _saving = false);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _teamAccent(_team.type);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Add Worker',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_saving)
            TextButton(
              onPressed: _save,
              child: Text(
                'Save',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            // Team context chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: accent.withValues(alpha: 0.18), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.group_rounded, size: 15, color: accent),
                  const SizedBox(width: 8),
                  Text(
                    _team.name,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),

            _SectionLabel('Worker Details'),
            const SizedBox(height: 10),

            // Full name
            _FieldCard(
              child: TextFormField(
                controller: _nameCtrl,
                focusNode: _nameFocus,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                decoration: _inputDecoration(
                  context,
                  label: 'Full Name',
                  hint: 'e.g. Ali Hassan',
                  icon: Icons.person_outline_rounded,
                  accent: accent,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Worker name is required';
                  }
                  if (v.trim().length < 2) return 'Name too short';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 10),

            // Phone
            _FieldCard(
              child: TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.allow(
                    RegExp(r'[\d\+\-\s]'))],
                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                decoration: _inputDecoration(
                  context,
                  label: 'Phone Number',
                  hint: '+92 300 0000000',
                  icon: Icons.phone_outlined,
                  accent: accent,
                  optional: true,
                ),
              ),
            ),
            const SizedBox(height: 24),

            _SectionLabel('Role & Wage'),
            const SizedBox(height: 10),

            // Skill / Role dropdown
            _FieldCard(
              child: DropdownButtonFormField<String>(
                value: _selectedSkill,
                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                dropdownColor: isDark
                    ? AppColors.surfaceDark
                    : cs.surface,
                decoration: _inputDecoration(
                  context,
                  label: 'Skill / Role',
                  hint: '',
                  icon: Icons.construction_rounded,
                  accent: accent,
                ),
                items: LaborModel.roles
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedSkill = v);
                },
              ),
            ),
            const SizedBox(height: 10),

            // Daily wage
            _FieldCard(
              child: TextFormField(
                controller: _wageCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                decoration: _inputDecoration(
                  context,
                  label: 'Daily Wage (PKR)',
                  hint: 'e.g. 2000',
                  icon: Icons.payments_outlined,
                  accent: accent,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Daily wage is required';
                  }
                  final val = double.tryParse(v.trim());
                  if (val == null || val <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),

            _SectionLabel('Status'),
            const SizedBox(height: 10),

            Row(
              children: WorkerStatus.values.map((s) {
                final selected = _status == s;
                final color = _statusColor(s);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _status = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(
                          right: s != WorkerStatus.values.last ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: 0.12)
                            : (isDark
                                ? cs.surfaceContainerHighest
                                : cs.surfaceContainerLow),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? color
                              : cs.outlineVariant,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          s.label,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: selected ? color : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: accent.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Add Worker',
                        style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    required Color accent,
    bool optional = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: optional ? '$label (optional)' : label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: accent),
      labelStyle: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
      hintStyle: GoogleFonts.inter(
          fontSize: 13, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _teamAccent(TeamType t) => switch (t) {
      TeamType.structural  => const Color(0xFFF97316),
      TeamType.finishing   => const Color(0xFF22C55E),
      TeamType.electrical  => const Color(0xFFEAB308),
      TeamType.plumbing    => const Color(0xFF3B82F6),
      TeamType.general     => const Color(0xFF6B7280),
      TeamType.specialized => const Color(0xFF8B5CF6),
    };

Color _statusColor(WorkerStatus s) => switch (s) {
      WorkerStatus.active   => const Color(0xFF16A34A),
      WorkerStatus.inactive => const Color(0xFF6B7280),
      WorkerStatus.onLeave  => const Color(0xFFF59E0B),
    };

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.6,
        ),
      );
}

class _FieldCard extends StatelessWidget {
  final Widget child;
  const _FieldCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: child,
    );
  }
}
