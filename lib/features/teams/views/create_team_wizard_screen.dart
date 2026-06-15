import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../controllers/team_controller.dart';
import '../data/models/team_model.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';

const _uuid = Uuid();
const _kViolet = Color(0xFF7C3AED);

// ── Wizard screen ─────────────────────────────────────────────────────────────

class CreateTeamWizardScreen extends StatefulWidget {
  const CreateTeamWizardScreen({super.key});

  @override
  State<CreateTeamWizardScreen> createState() =>
      _CreateTeamWizardScreenState();
}

class _CreateTeamWizardScreenState extends State<CreateTeamWizardScreen> {
  int _step = 0;

  // Step 1 state
  final _nameCtrl        = TextEditingController();
  final _leaderCtrl      = TextEditingController();
  final _leaderPhoneCtrl = TextEditingController();
  final _descCtrl        = TextEditingController();
  final _contactCtrl     = TextEditingController();
  TeamType _type         = TeamType.general;
  final _formKey1        = GlobalKey<FormState>();

  // Step 2 state
  final _workers = <TeamWorkerModel>[];

  bool _isCreating = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _leaderCtrl.dispose();
    _leaderPhoneCtrl.dispose();
    _descCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _next() {
    if (_step == 0 && !(_formKey1.currentState?.validate() ?? false)) return;
    if (_step < 2) setState(() => _step++);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Get.back();
    }
  }

  Future<void> _create() async {
    setState(() => _isCreating = true);
    final teamId = _uuid.v4();
    final workers = _workers
        .map((w) => TeamWorkerModel(
              id: w.id,
              teamId: teamId,
              name: w.name,
              phone: w.phone,
              skillType: w.skillType,
              dailyWage: w.dailyWage,
              monthlySalary: w.monthlySalary,
              joiningDate: w.joiningDate,
              status: w.status,
            ))
        .toList();

    final team = TeamModel(
      id: teamId,
      name: _nameCtrl.text.trim(),
      leaderName: _leaderCtrl.text.trim(),
      leaderPhone: _leaderPhoneCtrl.text.trim().isEmpty
          ? null
          : _leaderPhoneCtrl.text.trim(),
      description:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      type: _type,
      status: TeamStatus.active,
      contactNumber: _contactCtrl.text.trim().isEmpty
          ? null
          : _contactCtrl.text.trim(),
      workers: workers,
      assignedProjectIds: [],
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );

    await Get.find<TeamController>().createTeam(team);
    setState(() => _isCreating = false);

    Get.back();
    Get.snackbar(
      'Team Created',
      '"${team.name}" is ready to manage your workforce.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      backgroundColor: _kViolet,
      colorText: Colors.white,
      icon: const Icon(Icons.groups_rounded, color: Colors.white),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _WizardHeader(
                step: _step, onBack: _back, isDark: isDark, cs: cs),

            // Step content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: anim, curve: Curves.easeOutCubic)),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _stepContent(),
                ),
              ),
            ),

            // Bottom navigation
            _BottomNav(
              step: _step,
              isCreating: _isCreating,
              onBack: _back,
              onNext: _next,
              onCreate: _create,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepContent() {
    return switch (_step) {
      0 => _Step1BasicInfo(
          formKey: _formKey1,
          nameCtrl: _nameCtrl,
          leaderCtrl: _leaderCtrl,
          leaderPhoneCtrl: _leaderPhoneCtrl,
          descCtrl: _descCtrl,
          contactCtrl: _contactCtrl,
          selectedType: _type,
          onTypeChanged: (t) => setState(() => _type = t),
        ),
      1 => _Step2AddWorkers(
          workers: _workers,
          onAdd: (w) => setState(() => _workers.add(w)),
          onRemove: (id) =>
              setState(() => _workers.removeWhere((w) => w.id == id)),
        ),
      _ => _Step3Review(
          name: _nameCtrl.text.trim(),
          leaderName: _leaderCtrl.text.trim(),
          type: _type,
          workers: _workers,
        ),
    };
  }
}

// ── Wizard header ─────────────────────────────────────────────────────────────

class _WizardHeader extends StatelessWidget {
  final int step;
  final VoidCallback onBack;
  final bool isDark;
  final ColorScheme cs;

  const _WizardHeader({
    required this.step,
    required this.onBack,
    required this.isDark,
    required this.cs,
  });

  static const _titles  = ['Team Details', 'Add Workers', 'Review & Create'];
  static const _subtitles = [
    'Basic information about the team',
    'Build your workforce',
    'Confirm before creating',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH, 14,
          AppDimensions.pagePaddingH, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + title
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? cs.surfaceContainerHighest
                        : Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: cs.onSurface),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_titles[step],
                        style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface)),
                    Text(_subtitles[step],
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Text('${step + 1}/3',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kViolet)),
            ],
          ),
          const SizedBox(height: 14),

          // Step indicator
          Row(
            children: List.generate(3, (i) {
              final done   = i < step;
              final active = i == step;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: done
                        ? _kViolet
                        : active
                            ? _kViolet.withValues(alpha: 0.50)
                            : (isDark
                                ? cs.surfaceContainerHighest
                                : const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Basic info ────────────────────────────────────────────────────────

class _Step1BasicInfo extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController leaderCtrl;
  final TextEditingController leaderPhoneCtrl;
  final TextEditingController descCtrl;
  final TextEditingController contactCtrl;
  final TeamType selectedType;
  final ValueChanged<TeamType> onTypeChanged;

  const _Step1BasicInfo({
    required this.formKey,
    required this.nameCtrl,
    required this.leaderCtrl,
    required this.leaderPhoneCtrl,
    required this.descCtrl,
    required this.contactCtrl,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WizardField(
              controller: nameCtrl,
              label: 'Team Name',
              hint: 'e.g. Alpha Structural Team',
              icon: Icons.groups_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppDimensions.md),
            _WizardField(
              controller: leaderCtrl,
              label: 'Team Leader',
              hint: 'Full name of the leader',
              icon: Icons.person_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppDimensions.md),
            _WizardField(
              controller: leaderPhoneCtrl,
              label: 'Leader Phone',
              hint: '+92 300 0000000',
              icon: Icons.phone_rounded,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: AppDimensions.md),

            // Team type selector
            _SectionLabel('Team Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TeamType.values.map((t) {
                final selected = t == selectedType;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTypeChanged(t);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? _kViolet
                          : _kViolet.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? _kViolet
                            : _kViolet.withValues(alpha: 0.20),
                        width: 1,
                      ),
                    ),
                    child: Text(t.label,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : _kViolet)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.md),
            _WizardField(
              controller: contactCtrl,
              label: 'Contact Number',
              hint: 'Main contact for the team',
              icon: Icons.contact_phone_rounded,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: AppDimensions.md),
            _WizardField(
              controller: descCtrl,
              label: 'Description (Optional)',
              hint:
                  'Brief description of the team\'s specialisation',
              icon: Icons.notes_rounded,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: Add workers ───────────────────────────────────────────────────────

class _Step2AddWorkers extends StatefulWidget {
  final List<TeamWorkerModel> workers;
  final void Function(TeamWorkerModel) onAdd;
  final void Function(String id) onRemove;

  const _Step2AddWorkers({
    required this.workers,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_Step2AddWorkers> createState() => _Step2AddWorkersState();
}

class _Step2AddWorkersState extends State<_Step2AddWorkers> {
  bool _showForm = false;

  final _wNameCtrl  = TextEditingController();
  final _wPhoneCtrl = TextEditingController();
  final _wWageCtrl  = TextEditingController(text: '2000');
  String _wSkill    = 'Mason';
  final _wFormKey   = GlobalKey<FormState>();

  static const _skills = [
    'Mason', 'Plasterer', 'Painter', 'Electrician',
    'Plumber', 'Tile Expert', 'Carpenter', 'Helper',
    'Shuttering Carpenter', 'Welder', 'Iron Bender',
  ];

  void _addWorker() {
    if (!(_wFormKey.currentState?.validate() ?? false)) return;
    final w = TeamWorkerModel(
      id: _uuid.v4(),
      teamId: '',
      name: _wNameCtrl.text.trim(),
      phone: _wPhoneCtrl.text.trim(),
      skillType: _wSkill,
      dailyWage: double.tryParse(_wWageCtrl.text.trim()) ?? 2000,
      joiningDate: DateTime.now(),
      status: WorkerStatus.active,
    );
    widget.onAdd(w);
    setState(() {
      _showForm = false;
      _wNameCtrl.clear();
      _wPhoneCtrl.clear();
      _wWageCtrl.text = '2000';
      _wSkill = 'Mason';
    });
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _wNameCtrl.dispose();
    _wPhoneCtrl.dispose();
    _wWageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Worker count chip
          Row(
            children: [
              Text('Workers Added',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _kViolet.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${widget.workers.length}',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kViolet)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Added workers list
          if (widget.workers.isEmpty && !_showForm)
            _EmptyWorkersHint()
          else ...[
            ...widget.workers.map((w) => _AddedWorkerChip(
                worker: w, onRemove: widget.onRemove)),
            const SizedBox(height: 4),
          ],

          // Add worker form
          if (_showForm) ...[
            const SizedBox(height: 12),
            _AddWorkerForm(
              formKey: _wFormKey,
              nameCtrl: _wNameCtrl,
              phoneCtrl: _wPhoneCtrl,
              wageCtrl: _wWageCtrl,
              skill: _wSkill,
              skills: _skills,
              onSkillChanged: (s) => setState(() => _wSkill = s ?? _wSkill),
              onSave: _addWorker,
              onCancel: () => setState(() => _showForm = false),
            ),
          ] else ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _showForm = true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _kViolet.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _kViolet.withValues(alpha: 0.20),
                      width: 1.5,
                      style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_alt_1_rounded,
                        size: 18, color: _kViolet),
                    const SizedBox(width: 8),
                    Text('Add Worker',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _kViolet)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
              'You can also add or edit workers after creating the team.',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _EmptyWorkersHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: _kViolet.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline_rounded,
              size: 32,
              color: _kViolet.withValues(alpha: 0.50)),
          const SizedBox(height: 8),
          Text('No workers yet',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text('Add workers below to build your team',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: cs.onSurfaceVariant
                      .withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

class _AddedWorkerChip extends StatelessWidget {
  final TeamWorkerModel worker;
  final void Function(String) onRemove;

  const _AddedWorkerChip(
      {required this.worker, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: _kViolet.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: _kViolet.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: _kViolet.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                worker.name.isNotEmpty
                    ? worker.name.split(' ').map((s) => s[0]).take(2).join()
                    : '?',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _kViolet),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(worker.name,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface)),
                Text(
                    '${worker.skillType} · PKR ${worker.dailyWage.toStringAsFixed(0)}/day',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onRemove(worker.id),
            icon: Icon(Icons.remove_circle_outline_rounded,
                size: 18, color: const Color(0xFFEF4444)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }
}

class _AddWorkerForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController wageCtrl;
  final String skill;
  final List<String> skills;
  final ValueChanged<String?> onSkillChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _AddWorkerForm({
    required this.formKey,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.wageCtrl,
    required this.skill,
    required this.skills,
    required this.onSkillChanged,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kViolet.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _kViolet.withValues(alpha: 0.18), width: 1),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Worker',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
            const SizedBox(height: 10),
            _WizardField(
              controller: nameCtrl,
              label: 'Name',
              hint: 'Full name',
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            _WizardField(
              controller: phoneCtrl,
              label: 'Phone',
              hint: '+92 300 0000000',
              icon: Icons.phone_outlined,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            // Skill dropdown
            DropdownButtonFormField<String>(
              value: skill,
              decoration: _inputDecoration(context,
                  label: 'Skill Type',
                  icon: Icons.work_outline_rounded),
              items: skills
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: onSkillChanged,
              style: GoogleFonts.inter(
                  fontSize: 13, color: cs.onSurface),
            ),
            const SizedBox(height: 10),
            _WizardField(
              controller: wageCtrl,
              label: 'Daily Wage (PKR)',
              hint: '2000',
              icon: Icons.payments_outlined,
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) return 'Enter a number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.onSurface,
                      side: BorderSide(
                          color: cs.onSurface.withValues(alpha: 0.25)),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kViolet,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Add',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 3: Review ────────────────────────────────────────────────────────────

class _Step3Review extends StatelessWidget {
  final String name;
  final String leaderName;
  final TeamType type;
  final List<TeamWorkerModel> workers;

  const _Step3Review({
    required this.name,
    required this.leaderName,
    required this.type,
    required this.workers,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _kViolet.withValues(alpha: 0.12),
                  _kViolet.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: _kViolet.withValues(alpha: 0.20), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: _kViolet.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.groups_rounded,
                          size: 22, color: _kViolet),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name.isEmpty ? 'Unnamed Team' : name,
                              style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface)),
                          Text(type.label,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: _kViolet,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ReviewRow(
                    icon: Icons.person_rounded,
                    label: 'Leader',
                    value: leaderName.isEmpty ? '—' : leaderName),
                const SizedBox(height: 8),
                _ReviewRow(
                    icon: Icons.people_alt_rounded,
                    label: 'Workers',
                    value: '${workers.length} added'),
                const SizedBox(height: 8),
                _ReviewRow(
                    icon: Icons.payments_outlined,
                    label: 'Est. Daily Cost',
                    value:
                        'PKR ${workers.fold(0.0, (s, w) => s + w.dailyWage).toStringAsFixed(0)}'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (workers.isNotEmpty) ...[
            Text('Workers (${workers.length})',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
            const SizedBox(height: 10),
            ...workers.map((w) => _ReviewWorkerRow(worker: w)),
          ] else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16,
                      color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No workers added. You can add them after creating the team.',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReviewRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: _kViolet),
        const SizedBox(width: 8),
        Text('$label:',
            style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurfaceVariant)),
        const SizedBox(width: 6),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface)),
      ],
    );
  }
}

class _ReviewWorkerRow extends StatelessWidget {
  final TeamWorkerModel worker;
  const _ReviewWorkerRow({required this.worker});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(worker.name,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _kViolet.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(worker.skillType,
                style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _kViolet)),
          ),
          const Spacer(),
          Text(
              'PKR ${worker.dailyWage.toStringAsFixed(0)}/day',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── Bottom navigation ─────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int step;
  final bool isCreating;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final Future<void> Function() onCreate;

  const _BottomNav({
    required this.step,
    required this.isCreating,
    required this.onBack,
    required this.onNext,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH, 12,
          AppDimensions.pagePaddingH, 20),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFF0F2F5)
                .withValues(alpha: isDark ? 0.1 : 1.0),
          ),
        ),
      ),
      child: Row(
        children: [
          if (step > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: _kViolet,
                  side: const BorderSide(color: _kViolet),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Back',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          if (step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isCreating
                  ? null
                  : (step == 2 ? onCreate : onNext),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: _kViolet,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    _kViolet.withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: isCreating
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : Text(
                      step == 2 ? 'Create Team' : 'Continue',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared form widgets ───────────────────────────────────────────────────────

class _WizardField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboard;
  final String? Function(String?)? validator;

  const _WizardField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboard = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 13),
      decoration: _inputDecoration(context, label: label, icon: icon),
    );
  }
}

InputDecoration _inputDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
}) {
  final cs     = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.inter(
        fontSize: 12, color: cs.onSurfaceVariant),
    prefixIcon: Icon(icon, size: 18, color: _kViolet),
    filled: true,
    fillColor: isDark
        ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
        : _kViolet.withValues(alpha: 0.04),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
          color: _kViolet.withValues(alpha: 0.20)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
          color: _kViolet.withValues(alpha: 0.18)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _kViolet, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFEF4444)),
    ),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant));
  }
}
