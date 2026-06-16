import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:io';
import '../controllers/projects_controller.dart';
import '../data/models/stage_model.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_badge.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/routes/app_routes.dart';
import '../../../presentation/widgets/common/animated_counter.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../teams/controllers/team_controller.dart';
import '../../teams/data/models/team_model.dart';

// ── Shared helpers ────────────────────────────────────────────────────────────

const _kSuccess = Color(0xFF16A34A);
const _kError   = Color(0xFFEF4444);
const _kWarning = Color(0xFFF59E0B);

/// Distributes budget across stages using simple proportional weights.
double _stageAllocation(double totalBudget, int stageIndex, int totalStages) {
  if (totalStages == 0) return 0;
  // Rough construction cost distribution (early stages heavier)
  const w = [0.03, 0.05, 0.12, 0.12, 0.08, 0.07, 0.10, 0.10, 0.12, 0.08, 0.08, 0.05];
  if (totalStages > w.length) return totalBudget / totalStages;
  final slice = w.sublist(0, totalStages);
  final sum   = slice.fold(0.0, (a, b) => a + b);
  return totalBudget * (slice[stageIndex] / sum);
}

String _fmtDate(DateTime dt) {
  const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
}

// ═══════════════════════════════════════════════════════════════════════════════
// Main Screen
// ═══════════════════════════════════════════════════════════════════════════════

// ── Workforce visibility modes ─────────────────────────────────────────────────

enum _WorkforceMode {
  /// Contractor user: show Teams tab (project-assigned teams only).
  teams,
  /// Owner/developer + self-managed: show Labor tab.
  labor,
  /// Owner/developer + contractor-managed: hide workforce section entirely.
  none,
}

_WorkforceMode _resolveWorkforceMode(dynamic project) {
  final auth = Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : null;
  final user = auth?.currentUser.value;

  // Contractor users always see their Teams, never Labor.
  if (user != null && user.isContractor) return _WorkforceMode.teams;

  // Developer / homeowner: depends on project execution type.
  final ct = (project.contractorType as String?) ?? 'self';
  if (ct == 'self') return _WorkforceMode.labor;

  // 'local' or 'company' — workforce is managed by the contractor.
  return _WorkforceMode.none;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Main Screen
// ═══════════════════════════════════════════════════════════════════════════════

class ProjectStageTrackerScreen extends GetView<ProjectsController> {
  const ProjectStageTrackerScreen({super.key});

  // PK2: Thekedar is in Labor tab  PK3: Permits is 7th tab
  // Static base tabs — workforce tab injected dynamically by _resolveWorkforceMode.
  static const _basePre  = ['Stages', 'Updates', 'Budget'];
  static const _basePost = ['Photos', 'Materials', 'Permits'];

  @override
  Widget build(BuildContext context) {
    final project = controller.selectedProject.value;
    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project')),
        body: const Center(child: Text('No project selected')),
      );
    }

    final wMode = _resolveWorkforceMode(project);

    // Build tab labels and tab views in lock-step so lengths always match.
    final tabLabels = <String>[..._basePre];
    final tabViews  = <Widget>[
      _StagesList(project: project),
      _UpdatesTab(project: project),
      _BudgetTab(project: project),
    ];

    switch (wMode) {
      case _WorkforceMode.labor:
        tabLabels.add('Labor');
        tabViews.add(_LaborTab(project: project)); // PK2: thekedar mode
        break;
      case _WorkforceMode.teams:
        tabLabels.add('Teams');
        tabViews.add(_ProjectTeamsTab(project: project));
        break;
      case _WorkforceMode.none:
        // No workforce tab — nothing added.
        break;
    }

    tabLabels.addAll(_basePost);
    tabViews.addAll([
      _PhotosTab(project: project),
      _MaterialsTab(project: project),
      _PermitsTab(project: project), // PK3
    ]);

    return DefaultTabController(
      length: tabLabels.length,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              pinned: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(project.name.split(' — ').first),
                  Obx(() => Text(
                    controller.syncLabel.value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )),
                ],
              ),
              actions: [
                // F3: Share progress
                Semantics(
                  label: 'Share project progress',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.share_rounded),
                    tooltip: 'Share progress',
                    onPressed: () => _shareProgress(project),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded),
                  tooltip: 'More options',
                  onSelected: (val) {
                    if (val == 'handover') {
                      final progress = controller.overallProgress;
                      if (progress < 90) {
                        _showHandoverBlockedDialog(context, progress);
                      } else {
                        Get.toNamed(AppRoutes.projectHandover);
                      }
                    } else if (val == 'report') {
                      Get.toNamed(AppRoutes.projectReport);
                    } else if (val == 'team') {
                      _showSupervisorsSheet(context);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: 'report',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.picture_as_pdf_rounded, size: 18),
                          title: Text('Generate Report'),
                          dense: true,
                        )),
                    PopupMenuItem(
                        value: 'team',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.engineering_rounded, size: 18),
                          title: Text('Team & Supervisors'),
                          dense: true,
                        )),
                    PopupMenuItem(
                        value: 'handover',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.key_rounded, size: 18),
                          title: Text('Project Handover'),
                          dense: true,
                        )),
                  ],
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: tabLabels.map((t) => Tab(text: t)).toList(),
              ),
            ),
          ],
          body: TabBarView(children: tabViews),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.dividerLight)),
          ),
          child: AppButton(
            label: 'request_update'.tr,
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  // ── F3: Share ──────────────────────────────────────────────────────────────
  // ── POLISH 3: Supervisors sheet ──────────────────────────────────────────
  void _showSupervisorsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SupervisorsSheet(),
    );
  }

  void _shareProgress(dynamic project) {
    final ctrl = Get.find<ProjectsController>();
    final pct  = ctrl.overallProgress.toStringAsFixed(0);
    final budget = CurrencyFormatter.formatPKR(
        (project.budgetAmount as double?) ?? 0);
    final spent  = CurrencyFormatter.formatPKR(
        (project.actualCost as double?) ?? 0);
    final date = project.lastUpdated != null
        ? DateFormatter.formatDateShort(project.lastUpdated as DateTime)
        : 'Recently';

    final text = '${project.name}\n'
        'Location: ${project.area}, ${project.city}\n'
        'Current Stage: ${project.currentStage}\n'
        'Overall Progress: $pct%\n'
        'Budget: $budget | Spent: $spent\n'
        'Last Update: $date\n\n'
        'Shared via BuildOS 🏗';

    Share.share(text, subject: '${project.name} — Progress Update');
  }

  // ── Handover guard ─────────────────────────────────────────────────────────
  void _showHandoverBlockedDialog(BuildContext context, double progress) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: _kWarning.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: _kWarning, size: 30),
            ),
            const SizedBox(height: 16),
            Text('Handover Not Available',
                style: AppTextStyles.h3(context)),
            const SizedBox(height: 8),
            Text(
              'Handover is available when the project is at least 90% complete.\n'
              'Current progress: ${progress.toStringAsFixed(0)}%',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(context),
            ),
            const SizedBox(height: 24),
            AppButton(label: 'Close', onPressed: () => Get.back()),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// F1 + F5: Stages tab with payment milestones + delay log
// ═══════════════════════════════════════════════════════════════════════════════

class _DelayEntry {
  final String type;
  final int days;
  final DateTime startDate;
  final DateTime endDate;
  final String? note;
  const _DelayEntry({
    required this.type,
    required this.days,
    required this.startDate,
    required this.endDate,
    this.note,
  });
}

class _StagesList extends StatefulWidget {
  final dynamic project;
  const _StagesList({required this.project});
  @override
  State<_StagesList> createState() => _StagesListState();
}

class _StagesListState extends State<_StagesList> {
  final _delays = <_DelayEntry>[];

  @override
  Widget build(BuildContext context) {
    final stages = widget.project.stages as List<StageModel>;
    final total  = (widget.project.budgetAmount as double?) ?? 0;
    final ctrl   = Get.find<ProjectsController>();
    final cs     = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        // Project summary card
        Container(
          padding: const EdgeInsets.all(AppDimensions.base),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(color: divider),
          ),
          child: Row(
            children: [
              Icon(Icons.home_outlined, color: cs.primary, size: 40),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.project.name as String,
                        style: AppTextStyles.h4(context)),
                    Text(
                      '${widget.project.area} · Started ${DateFormatter.formatDateShort(widget.project.startDate as DateTime)}',
                      style: AppTextStyles.caption(context),
                    ),
                    Text(
                      'Est. completion ${DateFormatter.formatDateShort(widget.project.estimatedEndDate as DateTime)}',
                      style: AppTextStyles.caption(context),
                    ),
                  ],
                ),
              ),
              Obx(() => CircularPercentIndicator(
                    radius: 28,
                    lineWidth: 4,
                    percent: (ctrl.overallProgress / 100).clamp(0.0, 1.0),
                    center: Text(
                      '${ctrl.overallProgress.toStringAsFixed(0)}%',
                      style: AppTextStyles.labelSmall(context),
                    ),
                    progressColor: cs.primary,
                    backgroundColor: divider,
                  )),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.md),

        // F1: Payment released summary card
        Obx(() {
          // Access the observable map unconditionally so GetX always registers
          // this Obx as a dependent — without this, an empty stages list means
          // no observable is read during build, which triggers the "improper use" error.
          final _ = ctrl.paymentStatusMap.length;
          double released = 0;
          for (int i = 0; i < stages.length; i++) {
            if (ctrl.isPaymentReleased(stages[i].id)) {
              released += _stageAllocation(total, i, stages.length);
            }
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _kSuccess.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: _kSuccess.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded,
                    color: _kSuccess, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Total Released: ${CurrencyFormatter.formatPKR(released)} of ${CurrencyFormatter.formatPKR(total)}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kSuccess),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: AppDimensions.xl),

        // Stage timeline rows — staggered slide-in (POLISH 2)
        ...stages.asMap().entries.map((e) =>
            _StageRow(stage: e.value, stageIndex: e.key,
                totalStages: stages.length, totalBudget: total)
                .animate(delay: Duration(milliseconds: e.key * 50))
                .slideX(begin: 0.12, end: 0, duration: 380.ms,
                    curve: Curves.easeOutCubic)
                .fadeIn(duration: 350.ms)),
        const SizedBox(height: AppDimensions.xl),

        // F5: Delay log section
        _DelaySection(
          delays: _delays,
          onAdd: () => _openDelayForm(context),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // F5: Log Delay form
  void _openDelayForm(BuildContext context) {
    String selectedType = 'Rain';
    int days = 1;
    DateTime start = DateTime.now();
    DateTime end   = DateTime.now().add(const Duration(days: 1));
    final noteCtrl = TextEditingController();
    const types = ['Rain', 'Eid Holiday', 'Public Holiday',
                   'Material Shortage', 'Owner Decision', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Log Delay', style: AppTextStyles.h3(context)),
                const SizedBox(height: 16),

                // Type chips
                Text('Delay Type', style: AppTextStyles.labelLarge(context)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: types.map((t) {
                    final sel = selectedType == t;
                    return GestureDetector(
                      onTap: () => setSheet(() => selectedType = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel ? _kWarning : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: sel ? _kWarning : Theme.of(context).dividerColor),
                        ),
                        child: Text(t,
                            style: TextStyle(
                                fontSize: 12,
                                color: sel ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Duration stepper
                Text('Duration (days)', style: AppTextStyles.labelLarge(context)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setSheet(() { if (days > 1) days--; }),
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text('$days',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h3(context)),
                    ),
                    IconButton(
                      onPressed: () => setSheet(() => days++),
                      icon: const Icon(Icons.add_circle_outline_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date range
                Row(
                  children: [
                    Expanded(
                      child: _DatePickerField(
                        label: 'Start Date',
                        value: start,
                        onChanged: (d) => setSheet(() {
                          start = d;
                          days  = end.difference(start).inDays + 1;
                          if (days < 1) days = 1;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DatePickerField(
                        label: 'End Date',
                        value: end,
                        onChanged: (d) => setSheet(() {
                          end  = d;
                          days = end.difference(start).inDays + 1;
                          if (days < 1) days = 1;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Note
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _delays.insert(0, _DelayEntry(
                          type:      selectedType,
                          days:      days,
                          startDate: start,
                          endDate:   end,
                          note:      noteCtrl.text.trim().isEmpty
                              ? null
                              : noteCtrl.text.trim(),
                        ));
                      });
                      noteCtrl.dispose();
                      Navigator.of(sheetCtx).pop();
                    },
                    child: const Text('Log Delay'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// F5: Delay section widget
class _DelaySection extends StatelessWidget {
  final List<_DelayEntry> delays;
  final VoidCallback onAdd;
  const _DelaySection({required this.delays, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Delays & Stoppages',
                  style: AppTextStyles.h3(context)),
            ),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 14),
              label: const Text('Log Delay'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                textStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
        if (delays.isEmpty) ...[
          const SizedBox(height: 8),
          Text('No delays logged.',
              style: AppTextStyles.caption(context)),
        ] else ...[
          const SizedBox(height: 10),
          ...delays.map((d) => _DelayCard(entry: d)),
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _kWarning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kWarning.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: _kWarning),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Timeline adjustment: +${delays.fold(0, (s, d) => s + d.days)} day(s) added to remaining stages',
                    style: TextStyle(
                        fontSize: 11,
                        color: _kWarning,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DelayCard extends StatelessWidget {
  final _DelayEntry entry;
  const _DelayCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _kWarning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(entry.type,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _kWarning)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${entry.days} day${entry.days > 1 ? 's' : ''} · '
                    '${_fmtDate(entry.startDate)} – ${_fmtDate(entry.endDate)}',
                    style: AppTextStyles.labelLarge(context)),
                if (entry.note != null)
                  Text(entry.note!,
                      style: AppTextStyles.caption(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Small date-picker field for the delay form
class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption(context)),
            const SizedBox(height: 2),
            Text(_fmtDate(value),
                style: AppTextStyles.labelLarge(context)),
          ],
        ),
      ),
    );
  }
}

// ── Stage timeline row ────────────────────────────────────────────────────────
class _StageRow extends StatelessWidget {
  final StageModel stage;
  final int stageIndex;
  final int totalStages;
  final double totalBudget;
  const _StageRow({
    required this.stage,
    required this.stageIndex,
    required this.totalStages,
    required this.totalBudget,
  });

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                _StageIndicator(stage: stage),
                if (stage.order < 10)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Get.find<ProjectsController>()
                              .isStageCompleted(stage.id)
                          ? AppColors.success
                          : divider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.md),
              child: _StageContent(
                stage: stage,
                stageIndex: stageIndex,
                totalStages: totalStages,
                totalBudget: totalBudget,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageIndicator extends StatelessWidget {
  final StageModel stage;
  const _StageIndicator({required this.stage});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Obx(() {
      final ctrl   = Get.find<ProjectsController>();
      final status = ctrl.stageStatus(stage.id, stage.status.name);

      if (status == 'completed') {
        return Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(
              color: AppColors.success, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
        );
      }
      if (status == 'inProgress' || stage.isInProgress) {
        return Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
          child: Center(
            child: Container(
              width: 10, height: 10,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        );
      }
      return Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: divider, width: 2)),
        child: Center(
          child: Text(
            '${stage.order}',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ),
      );
    });
  }
}

// ── Stage card (F1: includes payment milestone) ───────────────────────────────
class _StageContent extends StatefulWidget {
  final StageModel stage;
  final int stageIndex;
  final int totalStages;
  final double totalBudget;
  const _StageContent({
    required this.stage,
    required this.stageIndex,
    required this.totalStages,
    required this.totalBudget,
  });

  @override
  State<_StageContent> createState() => _StageContentState();
}

class _StageContentState extends State<_StageContent> {
  bool _justCompleted = false;

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    final milestone = _stageAllocation(
        widget.totalBudget, widget.stageIndex, widget.totalStages);

    return Obx(() {
      final ctrl   = Get.find<ProjectsController>();
      final status = ctrl.stageStatus(widget.stage.id, widget.stage.status.name);
      final progressPct = ctrl.stageProgress(widget.stage.id, widget.stage.progress);
      final isCompleted  = status == 'completed';
      final isInProgress = status == 'inProgress' ||
          (status == 'notStarted' && widget.stage.isInProgress);
      final isPending    = status == 'notStarted' &&
          !widget.stage.isInProgress && !widget.stage.isCompleted;
      final paymentReleased = ctrl.isPaymentReleased(widget.stage.id);

      if (isPending) {
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.stage.name,
                  style: AppTextStyles.labelLarge(context)),
              if (widget.stage.estimatedEndDate != null)
                Text(
                  'Starts ${DateFormatter.formatDateShort(widget.stage.estimatedEndDate!)}',
                  style: AppTextStyles.caption(context),
                ),
              const SizedBox(height: 6),
              SizedBox(
                height: 28,
                child: OutlinedButton(
                  onPressed: () => ctrl.markStageInProgress(widget.stage.id),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                  child: const Text('Mark In Progress'),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(AppDimensions.base),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.05)
              : surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isCompleted
                ? AppColors.success.withValues(alpha: 0.3)
                : isInProgress
                    ? cs.primary.withValues(alpha: 0.3)
                    : divider,
            width: (isInProgress || isCompleted) ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(child: Text(widget.stage.name,
                    style: AppTextStyles.h4(context))),
                if (isInProgress)
                  const AppBadge(
                      label: 'IN PROGRESS', variant: BadgeVariant.inProgress),
                if (isCompleted)
                  const AppBadge(label: 'DONE', variant: BadgeVariant.completed),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isCompleted ? 'Completed' : 'In progress · ${widget.stage.daysLeft} days left',
              style: AppTextStyles.caption(context),
            ),

            // Progress bar — animates to current value (POLISH 2)
            const SizedBox(height: AppDimensions.md),
            AnimatedProgressBar(
              value: (progressPct / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: divider,
              valueColor: isCompleted ? AppColors.success : cs.primary,
              duration: const Duration(milliseconds: 800),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${progressPct.toStringAsFixed(0)}%',
                  style: AppTextStyles.labelSmall(context)),
            ),

            if (!isCompleted) ...[
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7),
                  overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14),
                ),
                child: Slider(
                  value: progressPct.clamp(0.0, 100.0),
                  min: 0, max: 100, divisions: 20,
                  activeColor: cs.primary,
                  inactiveColor: divider,
                  onChanged: (val) =>
                      ctrl.updateStageProgress(widget.stage.id, val),
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.photo_library_outlined, size: 14),
                    label: Text('Photos (${widget.stage.photoCount})'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact(); // POLISH 4
                      setState(() => _justCompleted = true);
                      ctrl.markStageComplete(widget.stage.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('✓ Mark Complete',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],

            if (isCompleted && _justCompleted) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.celebration_rounded,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: 4),
                  Text('Stage completed!',
                      style: AppTextStyles.caption(context)
                          .copyWith(color: AppColors.success)),
                ],
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
            ],

            if (isCompleted && !_justCompleted) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ctrl.markStageInProgress(widget.stage.id);
                    ctrl.updateStageProgress(widget.stage.id,
                        widget.stage.completionPct < 100
                            ? widget.stage.completionPct
                            : 90);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                  child: const Text('Reopen'),
                ),
              ),
            ],

            // ── F1: Payment milestone section ─────────────────────────────
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 14, color: _kWarning),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Milestone: ${CurrencyFormatter.formatPKR(milestone)}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      Text(
                        paymentReleased ? 'Released to contractor' : 'Pending approval',
                        style: TextStyle(
                            fontSize: 10,
                            color: paymentReleased ? _kSuccess : _kWarning),
                      ),
                    ],
                  ),
                ),
                if (!paymentReleased && isCompleted)
                  ElevatedButton(
                    onPressed: () => _showPaymentConfirm(context, ctrl, milestone),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                    child: const Text('Approve & Release',
                        style: TextStyle(color: Colors.white)),
                  ),
                if (paymentReleased)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kSuccess.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded,
                            size: 12, color: _kSuccess),
                        SizedBox(width: 4),
                        Text('Released',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _kSuccess)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showPaymentConfirm(
      BuildContext context, ProjectsController ctrl, double amount) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: AppColors.success, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Approve Payment?',
                style: AppTextStyles.h3(context)),
            const SizedBox(height: 8),
            Text(
              'Approve ${widget.stage.name} and release '
              '${CurrencyFormatter.formatPKR(amount)} to contractor?',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(context),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact(); // POLISH 4
                      ctrl.releaseStagePayment(widget.stage.id);
                      Get.back();
                      Get.snackbar('Payment Released',
                          '${CurrencyFormatter.formatPKR(amount)} released for ${widget.stage.name}',
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          backgroundColor:
                              AppColors.success.withValues(alpha: 0.9),
                          colorText: Colors.white);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success),
                    child: const Text('Approve',
                        style: TextStyle(color: Colors.white)),
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

// ═══════════════════════════════════════════════════════════════════════════════
// F7: Updates tab with Daily Diary sub-section
// ═══════════════════════════════════════════════════════════════════════════════

class _DiaryEntry {
  final DateTime date;
  final String weather;
  final String workDone;
  final int workersPresent;
  final String? visitors;
  final String? issues;
  const _DiaryEntry({
    required this.date,
    required this.weather,
    required this.workDone,
    required this.workersPresent,
    this.visitors,
    this.issues,
  });
}

class _UpdatesTab extends StatefulWidget {
  final dynamic project;
  const _UpdatesTab({required this.project});

  @override
  State<_UpdatesTab> createState() => _UpdatesTabState();
}

class _UpdatesTabState extends State<_UpdatesTab> {
  final _updates = <_UpdateEntry>[
    _UpdateEntry(
      author: 'Bashir Ahmed', initials: 'BA', role: 'Site Supervisor',
      text: 'Foundation work completed. Plinth beam started today.',
      stageName: 'Foundation', date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    _UpdateEntry(
      author: 'Ahmed Khan', initials: 'AK', role: 'Owner',
      text: 'Reviewed progress photos. Good work this week.',
      stageName: null, date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final _diary = <_DiaryEntry>[
    _DiaryEntry(
      date: DateTime.now().subtract(const Duration(days: 1)),
      weather: 'Sunny',
      workDone: 'Column casting completed on ground floor. Shuttering removed.',
      workersPresent: 12,
      visitors: 'Owner visited, approved tile selection',
      issues: null,
    ),
  ];

  bool _showDiary = true;
  final _textCtrl = TextEditingController();

  @override
  void dispose() { _textCtrl.dispose(); super.dispose(); }

  void _openAddSheet(BuildContext context) {
    _textCtrl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetCtx) => _AddUpdateSheet(
        ctrl: _textCtrl,
        onSubmit: () {
          if (_textCtrl.text.trim().isEmpty) return;
          setState(() {
            _updates.insert(0, _UpdateEntry(
              author: 'You', initials: 'YO', role: 'Owner',
              text: _textCtrl.text.trim(),
              stageName: null, date: DateTime.now(),
            ));
          });
          _textCtrl.clear();
          Navigator.of(sheetCtx).pop();
        },
      ),
    );
  }

  void _openDiaryForm(BuildContext context) {
    String weather = 'Sunny';
    final workCtrl    = TextEditingController();
    final visitCtrl   = TextEditingController();
    final issueCtrl   = TextEditingController();
    int workers = 0;
    const weathers = ['Sunny', 'Cloudy', 'Rainy', 'Extreme Heat'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                        child: Text("Today's Log — ${_fmtDate(DateTime.now())}",
                            style: AppTextStyles.h3(context))),
                    GestureDetector(
                      onTap: () => Navigator.of(sheetCtx).pop(),
                      child: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text('Weather', style: AppTextStyles.labelLarge(context)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: weathers.map((w) {
                    final sel = weather == w;
                    final icons = const {'Sunny': '☀️', 'Cloudy': '☁️',
                        'Rainy': '🌧️', 'Extreme Heat': '🥵'};
                    return GestureDetector(
                      onTap: () => setSheet(() => weather = w),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: sel
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).dividerColor),
                        ),
                        child: Text('${icons[w]} $w',
                            style: TextStyle(
                                fontSize: 12,
                                color: sel ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: workCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Work done today *',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Text('Workers present',
                          style: AppTextStyles.labelLarge(context)),
                    ),
                    IconButton(
                      onPressed: () =>
                          setSheet(() { if (workers > 0) workers--; }),
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text('$workers',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h3(context)),
                    ),
                    IconButton(
                      onPressed: () => setSheet(() => workers++),
                      icon: const Icon(Icons.add_circle_outline_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: visitCtrl,
                  decoration: InputDecoration(
                    labelText: 'Visitors (optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: issueCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Issues / Notes (optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (workCtrl.text.trim().isEmpty) return;
                      setState(() {
                        _diary.insert(0, _DiaryEntry(
                          date: DateTime.now(),
                          weather: weather,
                          workDone: workCtrl.text.trim(),
                          workersPresent: workers,
                          visitors: visitCtrl.text.trim().isEmpty
                              ? null : visitCtrl.text.trim(),
                          issues: issueCtrl.text.trim().isEmpty
                              ? null : issueCtrl.text.trim(),
                        ));
                      });
                      workCtrl.dispose();
                      visitCtrl.dispose();
                      issueCtrl.dispose();
                      Navigator.of(sheetCtx).pop();
                    },
                    child: const Text('Save Log Entry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // ── F7: Daily Diary section ────────────────────────────────────
            _SectionHeader(
              title: 'Site Diary',
              trailing: GestureDetector(
                onTap: () => setState(() => _showDiary = !_showDiary),
                child: Text(_showDiary ? 'Hide' : 'Show',
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.primary,
                        fontWeight: FontWeight.w500)),
              ),
            ),
            if (_showDiary) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _openDiaryForm(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text("Add Today's Log"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              ..._diary.map((d) => _DiaryCard(entry: d)),
            ],
            const SizedBox(height: 20),

            // ── Updates feed ───────────────────────────────────────────────
            _SectionHeader(title: 'Site Updates'),
            const SizedBox(height: 10),
            ..._updates.map((u) => _UpdateCard(entry: u)),
          ],
        ),
        // FAB to add update
        Positioned(
          right: 20, bottom: 20,
          child: GestureDetector(
            onTap: () => _openAddSheet(context),
            child: Container(
              width: 52, height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 26),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.h4(context))),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _DiaryCard extends StatelessWidget {
  final _DiaryEntry entry;
  const _DiaryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    const weatherColors = {
      'Sunny': Color(0xFFF59E0B),
      'Cloudy': Color(0xFF6B7280),
      'Rainy': Color(0xFF3B82F6),
      'Extreme Heat': Color(0xFFEF4444),
    };
    const weatherIcons = {
      'Sunny': '☀️', 'Cloudy': '☁️', 'Rainy': '🌧️', 'Extreme Heat': '🥵',
    };

    final wColor = weatherColors[entry.weather] ?? cs.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(weatherIcons[entry.weather] ?? '☀️',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_fmtDate(entry.date),
                    style: AppTextStyles.h4(context)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: wColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(entry.weather,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: wColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(entry.workDone, style: AppTextStyles.bodyMedium(context)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.people_outline_rounded,
                  size: 13, color: _kSuccess),
              const SizedBox(width: 4),
              Text('${entry.workersPresent} workers',
                  style: AppTextStyles.caption(context)),
              if (entry.visitors != null) ...[
                const SizedBox(width: 12),
                const Icon(Icons.person_pin_outlined,
                    size: 13, color: AppColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(entry.visitors!,
                      style: AppTextStyles.caption(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ],
          ),
          if (entry.issues != null) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_outlined,
                    size: 13, color: _kWarning),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(entry.issues!,
                      style: AppTextStyles.caption(context)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _UpdateEntry {
  final String author, initials, role, text;
  final String? stageName;
  final DateTime date;
  const _UpdateEntry({
    required this.author, required this.initials, required this.role,
    required this.text, required this.stageName, required this.date,
  });
}

class _UpdateCard extends StatelessWidget {
  final _UpdateEntry entry;
  const _UpdateCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34, height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(entry.initials,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cs.primary)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.author,
                        style: AppTextStyles.labelLarge(context)),
                    Text(entry.role, style: AppTextStyles.caption(context)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_relTime(entry.date),
                      style: AppTextStyles.caption(context)),
                  if (entry.stageName != null) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(entry.stageName!,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: cs.primary)),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(entry.text, style: AppTextStyles.bodyMedium(context)),
        ],
      ),
    );
  }

  String _relTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _AddUpdateSheet extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSubmit;
  const _AddUpdateSheet({required this.ctrl, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('Add Update', style: AppTextStyles.h3(context)),
              const Spacer(),
              Semantics(
                label: 'Close',
                button: true,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondaryLight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: ctrl,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "What's happening on site today?",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.borderLight)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40, height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Icon(Icons.attach_file_rounded,
                    size: 18, color: AppColors.textSecondaryLight),
              ),
              AppButton.primary(
                label: 'Post Update',
                isFullWidth: false,
                onPressed: onSubmit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// F6: Budget tab — per-stage breakdown
// ═══════════════════════════════════════════════════════════════════════════════

class _BudgetTab extends StatelessWidget {
  final dynamic project;
  const _BudgetTab({required this.project});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;
    final stages  = (project.stages as List<StageModel>);
    final budget  = (project.budgetAmount as double?) ?? 0.0;
    final spent   = (project.actualCost   as double?) ?? 0.0;
    final pct     = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    // Build per-stage actual spend (mock: distribute actualCost proportionally)
    final stageSpends = List<double>.generate(stages.length, (i) {
      final alloc = _stageAllocation(budget, i, stages.length);
      final ctrl  = Get.find<ProjectsController>();
      final stStatus = ctrl.stageStatus(stages[i].id, stages[i].status.name);
      if (stStatus == 'completed') return alloc;
      if (stStatus == 'inProgress') {
        final pctDone = ctrl.stageProgress(stages[i].id, stages[i].completionPct) / 100;
        return alloc * pctDone * 0.85; // 85% efficiency mock
      }
      return 0.0;
    });

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        // Summary card
        Container(
          padding: const EdgeInsets.all(AppDimensions.base),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(color: divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Budget Overview', style: AppTextStyles.h3(context)),
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  Expanded(
                    child: _BudgetStat(
                        label: 'Total',
                        value: CurrencyFormatter.formatPKR(budget),
                        color: cs.primary),
                  ),
                  Expanded(
                    child: _BudgetStat(
                        label: 'Spent',
                        value: CurrencyFormatter.formatPKR(spent),
                        color: pct > 0.8 ? AppColors.error : AppColors.success),
                  ),
                  Expanded(
                    child: _BudgetStat(
                        label: 'Left',
                        value: CurrencyFormatter.formatPKR(budget - spent),
                        color: cs.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 8,
                  backgroundColor: divider,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      pct > 0.8 ? AppColors.error : cs.primary),
                ),
              ),
              const SizedBox(height: 6),
              Text('${(pct * 100).toStringAsFixed(0)}% of budget used',
                  style: AppTextStyles.caption(context)),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.xl),

        // Per-stage breakdown (F6)
        Text('Cost Breakdown by Stage',
            style: AppTextStyles.h4(context)),
        const SizedBox(height: 10),
        if (stages.isEmpty)
          Text('No stages available.',
              style: AppTextStyles.caption(context))
        else ...[
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              border: Border.all(color: divider),
            ),
            child: Column(
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text('Stage',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                      const Expanded(
                          child: Text('Budget',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600))),
                      const Expanded(
                          child: Text('Actual',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600))),
                      const Expanded(
                          child: Text('Variance',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                Divider(height: 1, color: divider),
                ...stages.asMap().entries.map((e) {
                  final i       = e.key;
                  final stage   = e.value;
                  final alloc   = _stageAllocation(budget, i, stages.length);
                  final actual  = stageSpends[i];
                  final variance = alloc - actual;
                  final ctrl    = Get.find<ProjectsController>();
                  final stStatus = ctrl.stageStatus(
                      stage.id, stage.status.name);
                  final isNotStarted = stStatus == 'notStarted' &&
                      !stage.isInProgress;

                  Color varColor;
                  if (isNotStarted) {
                    varColor = Colors.grey;
                  } else if (variance >= 0) {
                    varColor = _kSuccess;
                  } else {
                    varColor = _kError;
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(stage.name,
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2),
                            ),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  CurrencyFormatter.formatPKR(alloc),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  isNotStarted
                                      ? '—'
                                      : CurrencyFormatter.formatPKR(actual),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: isNotStarted
                                          ? Colors.grey
                                          : null),
                                ),
                              ),
                            ),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  isNotStarted
                                      ? '—'
                                      : '${variance >= 0 ? '+' : ''}${CurrencyFormatter.formatPKR(variance)}',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: varColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i < stages.length - 1)
                        Divider(height: 1, color: divider),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.xl),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: '+ Log Expense',
                onPressed: () => Get.toNamed(AppRoutes.logExpense),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton.outline(
                label: 'Full Budget',
                onPressed: () => Get.toNamed(AppRoutes.budgetTracker),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.xl),
        _ExpensesEmptyState(),
      ],
    );
  }
}

class _BudgetStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _BudgetStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: color),
                textAlign: TextAlign.center,
                maxLines: 1),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption(context)),
        ],
      );
}

class _ExpensesEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 40,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('No Expenses Logged',
              style: AppTextStyles.h4(context),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            'Start tracking your construction spending stage by stage',
            style: AppTextStyles.caption(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 190,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.logExpense),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add First Expense'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PK2: Labor tab — Daily Wage + Thekedar (contract) modes
// ═══════════════════════════════════════════════════════════════════════════════

class _ThekedarEntry {
  final String name;
  final String workType;
  final String rateType;
  final double rateAmount;
  final String workAssigned;
  final String paymentTerms;
  final double advancePaid;
  final double totalEstimate;
  const _ThekedarEntry({
    required this.name, required this.workType, required this.rateType,
    required this.rateAmount, required this.workAssigned,
    required this.paymentTerms, required this.advancePaid,
    required this.totalEstimate,
  });
  double get balanceDue => totalEstimate - advancePaid;
}

class _LaborTab extends StatefulWidget {
  final dynamic project;
  const _LaborTab({required this.project});
  @override
  State<_LaborTab> createState() => _LaborTabState();
}

class _LaborTabState extends State<_LaborTab> {
  bool _isThekedarMode = false;
  final _thekadars = <_ThekedarEntry>[
    const _ThekedarEntry(
      name: 'Ustad Bashir Ahmed',
      workType: 'Brickwork',
      rateType: 'Per 1000 Bricks',
      rateAmount: 1800,
      workAssigned: 'Ground floor boundary wall + columns',
      paymentTerms: 'Milestone-Based',
      advancePaid: 30000,
      totalEstimate: 120000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final workerCount = (widget.project.workerCount as int?) ?? 0;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        // Segmented control
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _SegmentChip(
                label: 'Daily Wage Workers',
                selected: !_isThekedarMode,
                onTap: () => setState(() => _isThekedarMode = false),
              ),
              _SegmentChip(
                label: 'Thekedar (Contract)',
                selected: _isThekedarMode,
                onTap: () => setState(() => _isThekedarMode = true),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.xl),

        if (!_isThekedarMode) ...[
          // Daily Wage section — existing navigation tiles
          Container(
            padding: const EdgeInsets.all(AppDimensions.base),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.people_outline, color: cs.primary, size: 28),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$workerCount Active Workers',
                          style: AppTextStyles.h4(context)
                              .copyWith(color: cs.primary)),
                      Text('Manage attendance and payroll',
                          style: AppTextStyles.caption(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
          _LaborActionTile(
            icon: Icons.people_alt_outlined,
            title: 'Manage Workers',
            subtitle: 'Add, edit or release site workers',
            color: cs.primary,
            onTap: () => Get.toNamed(AppRoutes.laborList),
          ),
          const SizedBox(height: AppDimensions.md),
          _LaborActionTile(
            icon: Icons.checklist_rounded,
            title: 'Mark Attendance',
            subtitle: 'Sat–Thu weekly attendance grid',
            color: AppColors.success,
            onTap: () => Get.toNamed(AppRoutes.laborAttendance),
          ),
          const SizedBox(height: AppDimensions.md),
          _LaborActionTile(
            icon: Icons.payments_outlined,
            title: 'Payroll',
            subtitle: 'Generate and approve weekly wages',
            color: const Color(0xFF7C3AED),
            onTap: () => Get.toNamed(AppRoutes.payroll),
          ),
        ] else ...[
          // Thekedar section
          Row(
            children: [
              Expanded(
                child: Text('Thekedar / Contractors',
                    style: AppTextStyles.h4(context)),
              ),
              ElevatedButton.icon(
                onPressed: () => _openThekedarForm(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Thekedar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_thekadars.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No thekedar entries yet.',
                    style: AppTextStyles.caption(context)),
              ),
            )
          else
            ..._thekadars.map((t) => _ThekedarCard(entry: t)),
        ],
      ],
    );
  }

  void _openThekedarForm(BuildContext context) {
    const workTypes = ['Brickwork', 'Concrete', 'Plastering', 'Tiling',
                       'Electrical', 'Plumbing', 'Full Labour Contract'];
    const rateTypes = ['Per 1000 Bricks', 'Per Cubic Ft', 'Per Sq Ft', 'Lump Sum'];
    const payTerms  = ['Daily', 'Weekly', 'On Completion', 'Milestone-Based'];

    String workType = workTypes[0];
    String rateType = rateTypes[0];
    String payTerm  = payTerms[3];
    final nameCtrl    = TextEditingController();
    final workCtrl    = TextEditingController();
    final rateCtrl    = TextEditingController();
    final totalCtrl   = TextEditingController();
    final advCtrl     = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                )),
                const SizedBox(height: 14),
                Text('Add Thekedar', style: AppTextStyles.h3(context)),
                const SizedBox(height: 16),

                _FormField(label: 'Thekedar Name', ctrl: nameCtrl,
                    hint: 'e.g. Ustad Malik'),
                const SizedBox(height: 12),

                _ChipSelector<String>(
                    label: 'Work Type',
                    options: workTypes,
                    current: workType,
                    onSelect: (v) => setSheet(() => workType = v)),
                const SizedBox(height: 12),

                _ChipSelector<String>(
                    label: 'Rate Type',
                    options: rateTypes,
                    current: rateType,
                    onSelect: (v) => setSheet(() => rateType = v)),
                const SizedBox(height: 12),

                Row(children: [
                  Expanded(child: _FormField(
                      label: 'Rate (PKR)', ctrl: rateCtrl,
                      hint: 'e.g. 1800',
                      isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _FormField(
                      label: 'Total Estimate (PKR)', ctrl: totalCtrl,
                      hint: 'e.g. 120000',
                      isNumber: true)),
                ]),
                const SizedBox(height: 12),

                _FormField(label: 'Work Assigned', ctrl: workCtrl,
                    hint: 'Describe the scope of work...', maxLines: 2),
                const SizedBox(height: 12),

                _ChipSelector<String>(
                    label: 'Payment Terms',
                    options: payTerms,
                    current: payTerm,
                    onSelect: (v) => setSheet(() => payTerm = v)),
                const SizedBox(height: 12),

                _FormField(label: 'Advance Paid (PKR)', ctrl: advCtrl,
                    hint: '0', isNumber: true),

                // Balance preview
                if (totalCtrl.text.isNotEmpty && advCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Builder(builder: (_) {
                    final total = double.tryParse(totalCtrl.text) ?? 0;
                    final adv   = double.tryParse(advCtrl.text) ?? 0;
                    return Text(
                      'Balance Due: ${CurrencyFormatter.formatPKR(total - adv)}',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: (total - adv) > 0
                              ? _kError
                              : const Color(0xFF16A34A)),
                    );
                  }),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      setState(() {
                        _thekadars.insert(0, _ThekedarEntry(
                          name: nameCtrl.text.trim(),
                          workType: workType,
                          rateType: rateType,
                          rateAmount: double.tryParse(rateCtrl.text) ?? 0,
                          workAssigned: workCtrl.text.trim(),
                          paymentTerms: payTerm,
                          advancePaid: double.tryParse(advCtrl.text) ?? 0,
                          totalEstimate: double.tryParse(totalCtrl.text) ?? 0,
                        ));
                      });
                      Navigator.of(sheetCtx).pop();
                    },
                    child: const Text('Save Thekedar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegmentChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? cs.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [BoxShadow(color: cs.onSurface.withValues(alpha: 0.06),
                    blurRadius: 4, offset: const Offset(0, 1))]
                : null,
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? cs.primary : cs.onSurfaceVariant)),
        ),
      ),
    );
  }
}

class _ThekedarCard extends StatelessWidget {
  final _ThekedarEntry entry;
  const _ThekedarCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.engineering_rounded,
                    color: Color(0xFF7C3AED), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.name, style: AppTextStyles.h4(context)),
                    Text('${entry.workType}  ·  ${entry.paymentTerms}',
                        style: AppTextStyles.caption(context)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(entry.workAssigned,
              style: AppTextStyles.bodySmall(context),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(
            children: [
              _AmountChip(
                  label: 'Rate', value: '${CurrencyFormatter.formatPKR(entry.rateAmount)}/${entry.rateType.split(' ').last}'),
              const SizedBox(width: 8),
              _AmountChip(
                  label: 'Advance', value: CurrencyFormatter.formatPKR(entry.advancePaid)),
              const SizedBox(width: 8),
              _AmountChip(
                  label: 'Balance',
                  value: CurrencyFormatter.formatPKR(entry.balanceDue),
                  valueColor: entry.balanceDue > 0 ? _kError : _kSuccess),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _AmountChip(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.caption(context),
                textAlign: TextAlign.center),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: valueColor ?? cs.onSurface)),
            ),
          ],
        ),
      ),
    );
  }
}

// Helpers used by Thekedar form
class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final bool isNumber;
  final int maxLines;
  const _FormField({
    required this.label, required this.ctrl, required this.hint,
    this.isNumber = false, this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelLarge(context)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      );
}

class _ChipSelector<T> extends StatelessWidget {
  final String label;
  final List<T> options;
  final T current;
  final ValueChanged<T> onSelect;
  const _ChipSelector({
    required this.label, required this.options,
    required this.current, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 6,
          children: options.map((o) {
            final sel = o == current;
            return GestureDetector(
              onTap: () => onSelect(o),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? cs.primary : cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: sel ? cs.primary
                          : Theme.of(context).dividerColor),
                ),
                child: Text(o.toString(),
                    style: TextStyle(
                        fontSize: 11,
                        color: sel ? Colors.white : cs.onSurface,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _LaborActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _LaborActionTile({
    required this.icon, required this.title, required this.subtitle,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.base),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h4(context)),
                  Text(subtitle, style: AppTextStyles.caption(context)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// F2: Materials / Delivery Log tab
// ═══════════════════════════════════════════════════════════════════════════════

class _DeliveryEntry {
  final DateTime date;
  final String materialName;
  final double quantity;
  final String unit;
  final String supplier;
  final double unitPrice;
  final double totalAmount;
  final String paymentMethod;
  final String? receiptPath;

  const _DeliveryEntry({
    required this.date,
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.supplier,
    required this.unitPrice,
    required this.totalAmount,
    required this.paymentMethod,
    this.receiptPath,
  });
}

class _MaterialsTab extends StatefulWidget {
  final dynamic project;
  const _MaterialsTab({required this.project});
  @override
  State<_MaterialsTab> createState() => _MaterialsTabState();
}

class _MaterialsTabState extends State<_MaterialsTab> {
  final _picker = ImagePicker();

  // Dummy seed data
  final _deliveries = <_DeliveryEntry>[
    _DeliveryEntry(
      date: DateTime.now().subtract(const Duration(days: 3)),
      materialName: 'Cement',
      quantity: 200, unit: 'Bags',
      supplier: 'Shah Cement Store',
      unitPrice: 1280, totalAmount: 256000,
      paymentMethod: 'Bank Transfer',
    ),
    _DeliveryEntry(
      date: DateTime.now().subtract(const Duration(days: 5)),
      materialName: 'Steel Rods',
      quantity: 500, unit: 'Kg',
      supplier: 'Ali Steel Traders',
      unitPrice: 262, totalAmount: 131000,
      paymentMethod: 'Cash',
    ),
    _DeliveryEntry(
      date: DateTime.now().subtract(const Duration(days: 8)),
      materialName: 'Bricks',
      quantity: 5, unit: 'Trucks',
      supplier: 'Lahore Brick Factory',
      unitPrice: 18500, totalAmount: 92500,
      paymentMethod: 'Cash',
    ),
    _DeliveryEntry(
      date: DateTime.now().subtract(const Duration(days: 12)),
      materialName: 'Bajri',
      quantity: 8, unit: 'Trucks',
      supplier: 'Khan Aggregates',
      unitPrice: 14000, totalAmount: 112000,
      paymentMethod: 'Bank Transfer',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final total = _deliveries.fold(0.0, (s, d) => s + d.totalAmount);

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: cs.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      color: cs.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Material Cost',
                            style: AppTextStyles.caption(context)),
                        Text(CurrencyFormatter.formatPKR(total),
                            style: AppTextStyles.h3(context)
                                .copyWith(color: cs.primary)),
                        Text('${_deliveries.length} deliveries logged',
                            style: AppTextStyles.caption(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Delivery Log', style: AppTextStyles.h4(context)),
            const SizedBox(height: 10),
            ..._deliveries.map((d) => _DeliveryCard(entry: d)),
          ],
        ),
        // FAB
        Positioned(
          right: 20, bottom: 20,
          child: FloatingActionButton.extended(
            heroTag: 'materials_fab',
            onPressed: () => _openLogForm(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Log Delivery'),
          ),
        ),
      ],
    );
  }

  void _openLogForm(BuildContext context) {
    const materials = [
      'Cement', 'Retta', 'Bajri', 'Steel Rods', 'Bricks',
      'Sand', 'Tiles', 'Paint', 'Other'
    ];
    const units = ['Bags', 'Cubic Ft', 'Trucks', 'Kg', 'Units'];
    const payMethods = ['Cash', 'Bank Transfer', 'Cheque'];

    String material = 'Cement';
    String unit     = 'Bags';
    String payMethod = 'Cash';
    DateTime date   = DateTime.now();
    String? receiptPath;
    final otherCtrl  = TextEditingController();
    final qtyCtrl    = TextEditingController();
    final priceCtrl  = TextEditingController();
    final supplierCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheet) {
          final qty   = double.tryParse(qtyCtrl.text) ?? 0;
          final price = double.tryParse(priceCtrl.text) ?? 0;
          final total = qty * price;

          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20,
                MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Log Delivery',
                      style: AppTextStyles.h3(context)),
                  const SizedBox(height: 16),

                  // Date
                  _DatePickerField(
                    label: 'Date',
                    value: date,
                    onChanged: (d) => setSheet(() => date = d),
                  ),
                  const SizedBox(height: 12),

                  // Material
                  DropdownButtonFormField<String>(
                    value: material,
                    decoration: InputDecoration(
                      labelText: 'Material',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    items: materials
                        .map((m) => DropdownMenuItem(
                            value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) =>
                        setSheet(() => material = v ?? material),
                  ),
                  if (material == 'Other') ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: otherCtrl,
                      decoration: InputDecoration(
                        labelText: 'Specify material',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Quantity + unit
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          onChanged: (_) => setSheet(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: unit,
                          decoration: InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 12),
                          ),
                          items: units
                              .map((u) => DropdownMenuItem(
                                  value: u, child: Text(u)))
                              .toList(),
                          onChanged: (v) =>
                              setSheet(() => unit = v ?? unit),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Unit price
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Unit Price (PKR)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onChanged: (_) => setSheet(() {}),
                  ),
                  if (total > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Total: ${CurrencyFormatter.formatPKR(total)}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Supplier
                  TextField(
                    controller: supplierCtrl,
                    decoration: InputDecoration(
                      labelText: 'Supplier Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payment method chips
                  Text('Payment Method',
                      style: AppTextStyles.labelLarge(context)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: payMethods.map((p) {
                      final sel = payMethod == p;
                      return GestureDetector(
                        onTap: () => setSheet(() => payMethod = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: sel
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: sel
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).dividerColor),
                          ),
                          child: Text(p,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: sel ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Receipt photo
                  OutlinedButton.icon(
                    onPressed: () async {
                      final f = await _picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 70);
                      if (f != null) setSheet(() => receiptPath = f.path);
                    },
                    icon: const Icon(Icons.receipt_long_rounded, size: 16),
                    label: Text(receiptPath != null
                        ? 'Receipt attached ✓'
                        : 'Attach Receipt Photo'),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final qty2 = double.tryParse(qtyCtrl.text) ?? 0;
                        final price2 = double.tryParse(priceCtrl.text) ?? 0;
                        if (qty2 <= 0 || price2 <= 0) return;
                        final name = material == 'Other'
                            ? otherCtrl.text.trim()
                            : material;
                        setState(() {
                          _deliveries.insert(0, _DeliveryEntry(
                            date: date,
                            materialName: name.isEmpty ? 'Other' : name,
                            quantity: qty2,
                            unit: unit,
                            supplier: supplierCtrl.text.trim().isEmpty
                                ? 'Unknown'
                                : supplierCtrl.text.trim(),
                            unitPrice: price2,
                            totalAmount: qty2 * price2,
                            paymentMethod: payMethod,
                            receiptPath: receiptPath,
                          ));
                        });
                        qtyCtrl.dispose();
                        priceCtrl.dispose();
                        supplierCtrl.dispose();
                        otherCtrl.dispose();
                        Navigator.of(sheetCtx).pop();
                      },
                      child: const Text('Save Delivery'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final _DeliveryEntry entry;
  const _DeliveryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    const matColors = {
      'Cement':     Color(0xFF6B7280),
      'Steel Rods': Color(0xFF374151),
      'Bricks':     Color(0xFFB45309),
      'Bajri':      Color(0xFF92400E),
      'Sand':       Color(0xFFF59E0B),
      'Tiles':      Color(0xFF3B82F6),
      'Paint':      Color(0xFF8B5CF6),
      'Retta':      Color(0xFF059669),
    };
    final matColor = matColors[entry.materialName] ?? cs.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: divider),
      ),
      child: Row(
        children: [
          // Receipt thumbnail / material icon
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: matColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: entry.receiptPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(entry.receiptPath!),
                      fit: BoxFit.cover,
                      cacheWidth: 88,
                    ),
                  )
                : Icon(Icons.inventory_2_outlined,
                    color: matColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(entry.materialName,
                          style: AppTextStyles.h4(context)),
                    ),
                    Text(CurrencyFormatter.formatPKR(entry.totalAmount),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cs.primary)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${entry.quantity.toStringAsFixed(0)} ${entry.unit} @ '
                  'PKR ${entry.unitPrice.toStringAsFixed(0)}/${entry.unit}',
                  style: AppTextStyles.caption(context),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.store_outlined,
                        size: 11, color: cs.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(entry.supplier,
                          style: AppTextStyles.caption(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(entry.paymentMethod,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: cs.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(_fmtDate(entry.date),
                    style: AppTextStyles.caption(context)
                        .copyWith(color: cs.onSurfaceVariant
                            .withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Photos tab (unchanged from previous impl)
// ═══════════════════════════════════════════════════════════════════════════════

class _PhotoEntry {
  final String path;
  final String? stageName;
  final String? caption;
  final DateTime takenAt;
  const _PhotoEntry({
    required this.path, this.stageName, this.caption, required this.takenAt,
  });
}

class _PhotosTab extends StatefulWidget {
  final dynamic project;
  const _PhotosTab({required this.project});
  @override
  State<_PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends State<_PhotosTab> {
  final _photos    = <_PhotoEntry>[];
  final _picker    = ImagePicker();
  XFile? _pendingFile;

  List<StageModel> get _stages =>
      (widget.project.stages as List<StageModel>);

  Future<void> _pickPhoto(ImageSource source) async {
    Navigator.of(context).pop();
    final file = await _picker.pickImage(
        source: source, imageQuality: 85);
    if (file == null) return;
    _pendingFile = file;
    _showTaggingSheet();
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () => _pickPhoto(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () => _pickPhoto(ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showTaggingSheet() {
    String? selectedStage;
    final captionCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20,
              MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Tag Photo', style: AppTextStyles.h3(sheetCtx)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStage,
                decoration: InputDecoration(
                  labelText: 'Stage (optional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('— No stage —')),
                  ..._stages.map((s) => DropdownMenuItem(
                        value: s.name, child: Text(s.name),
                      )),
                ],
                onChanged: (v) => setSheet(() => selectedStage = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: captionCtrl,
                decoration: InputDecoration(
                  labelText: 'Caption (optional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_pendingFile == null) return;
                    setState(() {
                      _photos.insert(0, _PhotoEntry(
                        path:      _pendingFile!.path,
                        stageName: selectedStage,
                        caption:   captionCtrl.text.trim().isEmpty
                            ? null : captionCtrl.text.trim(),
                        takenAt:   DateTime.now(),
                      ));
                      _pendingFile = null;
                    });
                    captionCtrl.dispose();
                    Navigator.of(sheetCtx).pop();
                  },
                  child: const Text('Add Photo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context, _PhotoEntry photo) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(photo.caption ?? photo.stageName ?? 'Photo',
              style: const TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: 0.5, maxScale: 5.0,
            child: Image.file(File(photo.path), fit: BoxFit.contain),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_photos.isEmpty) {
      return Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt_rounded,
                        size: 40,
                        color: cs.primary.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 20),
                  Text('No Photos Yet',
                      style: AppTextStyles.h3(context),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Upload site photos to track visual progress',
                      style: AppTextStyles.bodySmall(context),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddOptions,
                    icon: const Icon(Icons.upload_rounded, size: 16),
                    label: const Text('Upload First Photo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20, bottom: 20,
            child: FloatingActionButton(
              heroTag: 'photos_fab',
              onPressed: _showAddOptions,
              child: const Icon(Icons.add_photo_alternate_rounded),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _photos.length,
          itemBuilder: (_, i) {
            final p = _photos[i];
            return GestureDetector(
              onTap: () => _openFullscreen(context, p),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(p.path),
                      fit: BoxFit.cover,
                      cacheWidth: 400,
                      frameBuilder: (context, child, frame,
                          wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded || frame != null) {
                          return child;
                        }
                        return _ImagePlaceholder();
                      },
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (p.stageName != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(p.stageName!,
                                    style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                              ),
                            if (p.caption != null)
                              Text(p.caption!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white)),
                            Text(_fmtDate(p.takenAt),
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          right: 16, bottom: 16,
          child: FloatingActionButton(
            heroTag: 'photos_grid_fab',
            onPressed: _showAddOptions,
            child: const Icon(Icons.add_photo_alternate_rounded),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PK3: Permits tracking tab (LDA / CDA / KDA / utility connections)
// ═══════════════════════════════════════════════════════════════════════════════

class _PermitEntry {
  final String type;
  String status; // 'not_submitted'|'submitted'|'under_review'|'approved'|'rejected'
  final DateTime? submissionDate;
  final DateTime? expectedDate;
  String referenceNo;
  String notes;

  _PermitEntry({
    required this.type,
    this.status = 'not_submitted',
    this.submissionDate,
    this.expectedDate,
    this.referenceNo = '',
    this.notes = '',
  });
}

class _PermitsTab extends StatefulWidget {
  final dynamic project;
  const _PermitsTab({required this.project});
  @override
  State<_PermitsTab> createState() => _PermitsTabState();
}

class _PermitsTabState extends State<_PermitsTab> {
  final _permits = <_PermitEntry>[
    _PermitEntry(
      type: 'LDA Drawing Approval',
      status: 'approved',
      submissionDate: DateTime(2026, 1, 20),
      expectedDate:   DateTime(2026, 3, 1),
      referenceNo: 'LDA/2026/DRW-4821',
      notes: 'Approved. Boundary wall and ground floor plans.',
    ),
    _PermitEntry(
      type: 'WASA Connection',
      status: 'under_review',
      submissionDate: DateTime(2026, 2, 10),
      expectedDate:   DateTime(2026, 4, 10),
      referenceNo: 'WASA/2026/WC-1124',
      notes: '',
    ),
    _PermitEntry(
      type: 'Electricity Connection',
      status: 'not_submitted',
      referenceNo: '',
      notes: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        _permits.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_outlined,
                        size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text('No Permits Added',
                        style: AppTextStyles.h4(context)),
                    const SizedBox(height: 8),
                    Text('Track LDA, WASA, and utility approvals here.',
                        style: AppTextStyles.bodySmall(context),
                        textAlign: TextAlign.center),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _permits.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _PermitCard(
                  entry: _permits[i],
                  onStatusChange: (s) =>
                      setState(() => _permits[i].status = s),
                ),
              ),
        Positioned(
          right: 16, bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'permits_fab',
            onPressed: () => _openAddPermitForm(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Permit'),
          ),
        ),
      ],
    );
  }

  void _openAddPermitForm(BuildContext context) {
    const types = [
      'LDA Drawing Approval', 'CDA NOC', 'KDA NOC', 'WASA Connection',
      'Electricity Connection', 'Gas Connection', 'PTCL / Utility',
      'Demolition NOC', 'Other',
    ];
    const statuses = [
      'not_submitted', 'submitted', 'under_review', 'approved', 'rejected'
    ];
    String type   = types[0];
    String status = 'not_submitted';
    DateTime? subDate;
    DateTime? expDate;
    final refCtrl  = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                )),
                const SizedBox(height: 14),
                Text('Add Permit', style: AppTextStyles.h3(context)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(
                    labelText: 'Permit Type',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  items: types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setSheet(() => type = v ?? type),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: InputDecoration(
                    labelText: 'Current Status',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  items: statuses.map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(_permitStatusLabel(s)),
                  )).toList(),
                  onChanged: (v) => setSheet(() => status = v ?? status),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _DatePickerField(
                      label: 'Submission Date',
                      value: subDate ?? DateTime.now(),
                      onChanged: (d) => setSheet(() => subDate = d))),
                  const SizedBox(width: 10),
                  Expanded(child: _DatePickerField(
                      label: 'Expected By',
                      value: expDate ?? DateTime.now().add(const Duration(days: 30)),
                      onChanged: (d) => setSheet(() => expDate = d))),
                ]),
                const SizedBox(height: 12),
                TextField(
                  controller: refCtrl,
                  decoration: InputDecoration(
                    labelText: 'Reference Number (optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _permits.insert(0, _PermitEntry(
                          type: type,
                          status: status,
                          submissionDate: subDate,
                          expectedDate: expDate,
                          referenceNo: refCtrl.text.trim(),
                          notes: noteCtrl.text.trim(),
                        ));
                      });
                      refCtrl.dispose(); noteCtrl.dispose();
                      Navigator.of(sheetCtx).pop();
                    },
                    child: const Text('Save Permit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _permitStatusLabel(String s) => switch (s) {
  'not_submitted' => 'Not Submitted',
  'submitted'     => 'Submitted',
  'under_review'  => 'Under Review',
  'approved'      => 'Approved',
  'rejected'      => 'Rejected',
  _               => s,
};

class _PermitCard extends StatelessWidget {
  final _PermitEntry entry;
  final ValueChanged<String> onStatusChange;
  const _PermitCard({required this.entry, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    Color statusColor;
    IconData statusIcon;
    switch (entry.status) {
      case 'approved':
        statusColor = _kSuccess; statusIcon = Icons.verified_rounded; break;
      case 'rejected':
        statusColor = _kError;   statusIcon = Icons.cancel_rounded;   break;
      case 'under_review':
        statusColor = cs.primary; statusIcon = Icons.pending_rounded;  break;
      case 'submitted':
        statusColor = _kWarning; statusIcon = Icons.schedule_rounded;  break;
      default:
        statusColor = Colors.grey; statusIcon = Icons.circle_outlined;
    }

    int? daysSince;
    if (entry.submissionDate != null &&
        (entry.status == 'submitted' || entry.status == 'under_review')) {
      daysSince = DateTime.now().difference(entry.submissionDate!).inDays;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: entry.status == 'approved'
                ? _kSuccess.withValues(alpha: 0.3)
                : entry.status == 'rejected'
                    ? _kError.withValues(alpha: 0.3)
                    : divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, size: 18, color: statusColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(entry.type,
                    style: AppTextStyles.h4(context)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_permitStatusLabel(entry.status),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor)),
              ),
            ],
          ),
          if (entry.referenceNo.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Ref: ${entry.referenceNo}',
                style: AppTextStyles.caption(context)),
          ],
          if (entry.submissionDate != null)
            Text('Submitted: ${_fmtDate(entry.submissionDate!)}',
                style: AppTextStyles.caption(context)),
          if (entry.expectedDate != null)
            Text('Expected by: ${_fmtDate(entry.expectedDate!)}',
                style: AppTextStyles.caption(context)),
          if (daysSince != null)
            Text('⏱ $daysSince days since submission',
                style: TextStyle(
                    fontSize: 11,
                    color: daysSince > 30 ? _kError : _kWarning)),
          if (entry.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(entry.notes,
                style: AppTextStyles.bodySmall(context),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          if (entry.status == 'rejected') ...[
            const SizedBox(height: 10),
            SizedBox(
              child: OutlinedButton.icon(
                onPressed: () => onStatusChange('submitted'),
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Resubmit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kError,
                  side: const BorderSide(color: _kError),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  textStyle: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// POLISH 3: Supervisor management sheet
// ═══════════════════════════════════════════════════════════════════════════════

class _SupervisorEntry {
  final String name, phone, role;
  final DateTime activeSince;
  final DateTime lastActive;
  final int photosThisWeek;
  final int stagesThisWeek;
  final bool dailyCheckIn;

  const _SupervisorEntry({
    required this.name,
    required this.phone,
    required this.role,
    required this.activeSince,
    required this.lastActive,
    required this.photosThisWeek,
    required this.stagesThisWeek,
    this.dailyCheckIn = true,
  });
}

class _SupervisorsSheet extends StatefulWidget {
  const _SupervisorsSheet();
  @override
  State<_SupervisorsSheet> createState() => _SupervisorsSheetState();
}

class _SupervisorsSheetState extends State<_SupervisorsSheet> {
  final _supervisors = <_SupervisorEntry>[
    _SupervisorEntry(
      name: 'Ustad Bashir Ahmed',
      phone: '+92 300 1234567',
      role: 'Site Supervisor',
      activeSince: DateTime(2026, 1, 15),
      lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      photosThisWeek: 14,
      stagesThisWeek: 2,
    ),
    _SupervisorEntry(
      name: 'Malik Sohail',
      phone: '+92 333 9876543',
      role: 'Foreman',
      activeSince: DateTime(2026, 2, 1),
      lastActive: DateTime.now().subtract(const Duration(hours: 18)),
      photosThisWeek: 8,
      stagesThisWeek: 1,
      dailyCheckIn: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final height = MediaQuery.of(context).size.height * 0.85;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Team & Supervisors',
                      style: AppTextStyles.h3(context)),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close_rounded,
                      size: 22, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Supervisors can mark attendance, upload photos, and log updates.',
              style: AppTextStyles.caption(context),
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Expanded(
            child: _supervisors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.engineering_rounded,
                            size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text('No supervisors assigned',
                            style: AppTextStyles.h4(context)),
                        const SizedBox(height: 6),
                        Text('Assign a supervisor to delegate site oversight.',
                            style: AppTextStyles.caption(context)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _supervisors.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) => _SupervisorCard(
                      entry: _supervisors[i],
                      onRemove: () => _confirmRemove(context, i),
                    ),
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, MediaQuery.of(context).padding.bottom + 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openAssignForm(context),
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: const Text('+ Assign Supervisor'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Supervisor?'),
        content: Text(
            'Remove ${_supervisors[index].name} from this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _supervisors.removeAt(index));
              Navigator.of(context).pop();
              Get.snackbar('Removed',
                  'Supervisor removed from project.',
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Remove',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openAssignForm(BuildContext context) {
    const roles = [
      'Site Supervisor', 'Foreman', 'QA Inspector', 'Safety Officer'
    ];
    String role        = roles[0];
    bool dailyCheckIn  = true;
    final nameCtrl     = TextEditingController();
    final phoneCtrl    = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20,
              MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 14),
                Text('Assign Supervisor',
                    style: AppTextStyles.h3(context)),
                const SizedBox(height: 16),
                _FormField(
                    label: 'Full Name', ctrl: nameCtrl,
                    hint: 'e.g. Ahmed Khan'),
                const SizedBox(height: 12),
                _FormField(
                    label: 'Phone Number', ctrl: phoneCtrl,
                    hint: '+92 3XX XXXXXXX'),
                const SizedBox(height: 12),
                _ChipSelector<String>(
                    label: 'Role',
                    options: roles,
                    current: role,
                    onSelect: (v) => setSheet(() => role = v)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text('Daily Check-in Required',
                          style: AppTextStyles.labelLarge(context)),
                    ),
                    Switch(
                      value: dailyCheckIn,
                      onChanged: (v) => setSheet(() => dailyCheckIn = v),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      setState(() {
                        _supervisors.insert(0, _SupervisorEntry(
                          name: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim().isEmpty
                              ? 'N/A' : phoneCtrl.text.trim(),
                          role: role,
                          activeSince: DateTime.now(),
                          lastActive: DateTime.now(),
                          photosThisWeek: 0,
                          stagesThisWeek: 0,
                          dailyCheckIn: dailyCheckIn,
                        ));
                      });
                      nameCtrl.dispose();
                      phoneCtrl.dispose();
                      Navigator.of(sheetCtx).pop();
                      Get.snackbar('Supervisor Assigned',
                          '${nameCtrl.text} has been added.',
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16));
                    },
                    child: const Text('Assign'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupervisorCard extends StatelessWidget {
  final _SupervisorEntry entry;
  final VoidCallback onRemove;
  const _SupervisorCard({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    final diffH = DateTime.now().difference(entry.lastActive).inHours;
    final lastActiveLabel = diffH < 1
        ? 'Just now'
        : diffH < 24
            ? '${diffH}h ago'
            : '${DateTime.now().difference(entry.lastActive).inDays}d ago';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    entry.name.split(' ').first[0].toUpperCase(),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.name, style: AppTextStyles.h4(context)),
                    Text('${entry.role}  ·  ${entry.phone}',
                        style: AppTextStyles.caption(context)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded,
                    size: 18, color: cs.onSurfaceVariant),
                onSelected: (v) {
                  if (v == 'remove') onRemove();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'remove',
                      child: Row(children: [
                        Icon(Icons.person_remove_rounded, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remove', style: TextStyle(color: Colors.red)),
                      ])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: divider),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatChip(
                  icon: Icons.access_time_rounded,
                  label: 'Last active: $lastActiveLabel'),
              const SizedBox(width: 8),
              _StatChip(
                  icon: Icons.photo_camera_outlined,
                  label: '${entry.photosThisWeek} photos'),
              const SizedBox(width: 8),
              _StatChip(
                  icon: Icons.checklist_rounded,
                  label: '${entry.stagesThisWeek} stages'),
            ],
          ),
          if (entry.dailyCheckIn) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.verified_rounded,
                    size: 12, color: Color(0xFF16A34A)),
                const SizedBox(width: 4),
                Text('Daily check-in required',
                    style: AppTextStyles.caption(context).copyWith(
                        color: const Color(0xFF16A34A))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: cs.primary),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: cs.primary)),
        ],
      ),
    );
  }
}

// ── Fix 4: Shimmer placeholder ────────────────────────────────────────────────
class _ImagePlaceholder extends StatefulWidget {
  const _ImagePlaceholder();
  @override
  State<_ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<_ImagePlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          color: Colors.grey.withValues(alpha: _anim.value),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// PK4: Project Teams tab — visible to contractor users
// Shows only the teams explicitly assigned to this project.
// ═══════════════════════════════════════════════════════════════════════════════

Color _ptAccent(TeamType t) => switch (t) {
      TeamType.structural  => const Color(0xFFF97316),
      TeamType.finishing   => const Color(0xFF22C55E),
      TeamType.electrical  => const Color(0xFFEAB308),
      TeamType.plumbing    => const Color(0xFF3B82F6),
      TeamType.general     => const Color(0xFF6B7280),
      TeamType.specialized => const Color(0xFF8B5CF6),
    };

IconData _ptIcon(TeamType t) => switch (t) {
      TeamType.structural  => Icons.foundation_rounded,
      TeamType.finishing   => Icons.format_paint_rounded,
      TeamType.electrical  => Icons.electric_bolt_rounded,
      TeamType.plumbing    => Icons.water_drop_rounded,
      TeamType.general     => Icons.construction_rounded,
      TeamType.specialized => Icons.precision_manufacturing_rounded,
    };

class _ProjectTeamsTab extends StatelessWidget {
  final dynamic project;
  const _ProjectTeamsTab({required this.project});

  @override
  Widget build(BuildContext context) {
    // Register TeamController lazily if not already registered.
    final tc = Get.isRegistered<TeamController>()
        ? Get.find<TeamController>()
        : Get.put(TeamController());

    return Obx(() {
      if (tc.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final projectId = project.id as String;
      final assigned  = tc.teams
          .where((t) => t.assignedProjectIds.contains(projectId))
          .toList();

      if (assigned.isEmpty) {
        return _PtEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        itemCount: assigned.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${assigned.length} Team${assigned.length == 1 ? '' : 's'} Assigned',
                          style: AppTextStyles.h4(context),
                        ),
                        Text(
                          'Teams responsible for this project',
                          style: AppTextStyles.caption(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return _PtTeamCard(team: assigned[i - 1]);
        },
      );
    });
  }
}

class _PtTeamCard extends StatelessWidget {
  final TeamModel team;
  const _PtTeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _ptAccent(team.type);

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.teamDetail, arguments: team),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerHighest : cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: accent.withValues(alpha: isDark ? 0.22 : 0.15), width: 1),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: accent.withValues(alpha: 0.25), width: 1),
                  ),
                  child: Icon(_ptIcon(team.type), size: 22, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(team.name, style: AppTextStyles.h4(context)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.person_rounded,
                              size: 11,
                              color: cs.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              team.leaderName,
                              style: AppTextStyles.caption(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Active status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: team.isActive
                        ? _kSuccess.withValues(alpha: 0.10)
                        : _kWarning.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5, height: 5,
                        decoration: BoxDecoration(
                          color: team.isActive ? _kSuccess : _kWarning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        team.status.label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: team.isActive ? _kSuccess : _kWarning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if ((team.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                team.description ?? '',
                style: AppTextStyles.bodySmall(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // KPI row
            Row(
              children: [
                _PtKpiChip(
                  icon: Icons.people_rounded,
                  label: '${team.workerCount} Workers',
                  accent: accent,
                ),
                const SizedBox(width: 8),
                _PtKpiChip(
                  icon: Icons.check_circle_rounded,
                  label: '${team.activeWorkerCount} Active',
                  accent: _kSuccess,
                ),
                const SizedBox(width: 8),
                _PtKpiChip(
                  icon: Icons.category_rounded,
                  label: team.type.label,
                  accent: accent,
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PtKpiChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  const _PtKpiChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: accent),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: accent),
            ),
          ],
        ),
      );
}

class _PtEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.groups_rounded,
                  size: 34, color: cs.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'No Teams Assigned',
              style: AppTextStyles.h3(context),
            ),
            const SizedBox(height: 8),
            Text(
              'No teams have been assigned to this project yet.\nAssign teams from the Teams module.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(context),
            ),
          ],
        ),
      ),
    );
  }
}
