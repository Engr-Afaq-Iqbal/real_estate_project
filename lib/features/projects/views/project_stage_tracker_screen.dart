import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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

class ProjectStageTrackerScreen extends GetView<ProjectsController> {
  const ProjectStageTrackerScreen({super.key});

  static const _tabs = ['Stages', 'Updates', 'Budget', 'Labor', 'Photos'];

  @override
  Widget build(BuildContext context) {
    final project = controller.selectedProject.value;
    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project')),
        body: const Center(child: Text('No project selected')),
      );
    }

    return DefaultTabController(
      length: _tabs.length,
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
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded),
                  onSelected: (val) {
                    if (val == 'handover') {
                      final progress = controller.overallProgress;
                      if (progress < 90) {
                        _showHandoverBlockedDialog(context, progress);
                      } else {
                        Get.toNamed(AppRoutes.projectHandover);
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'handover', child: Text('Project Handover')),
                  ],
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _StagesList(project: project),
              _UpdatesTab(project: project),
              _BudgetTab(project: project),
              _LaborTab(project: project),
              _PhotosTab(project: project),
            ],
          ),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.warning, size: 30),
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

// ── Stages list tab ───────────────────────────────────────────────────────────
class _StagesList extends StatelessWidget {
  final dynamic project;
  const _StagesList({required this.project});

  @override
  Widget build(BuildContext context) {
    final stages  = project.stages as List<StageModel>;
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
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
                    Text(project.name as String, style: AppTextStyles.h4(context)),
                    Text(
                      '${project.area} · Started ${DateFormatter.formatDateShort(project.startDate as DateTime)}',
                      style: AppTextStyles.caption(context),
                    ),
                    Text(
                      'Est. completion ${DateFormatter.formatDateShort(project.estimatedEndDate as DateTime)}',
                      style: AppTextStyles.caption(context),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final ctrl = Get.find<ProjectsController>();
                final overall = ctrl.overallProgress;
                return CircularPercentIndicator(
                  radius: 28,
                  lineWidth: 4,
                  percent: (overall / 100).clamp(0.0, 1.0),
                  center: Text(
                    '${overall.toStringAsFixed(0)}%',
                    style: AppTextStyles.labelSmall(context),
                  ),
                  progressColor: cs.primary,
                  backgroundColor: divider,
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.xl),
        ...stages.map((stage) => _StageRow(stage: stage)),
      ],
    );
  }
}

// ── Stage timeline row ────────────────────────────────────────────────────────
class _StageRow extends StatelessWidget {
  final StageModel stage;
  const _StageRow({required this.stage});

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
                      color: Get.find<ProjectsController>().isStageCompleted(stage.id)
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
              child: _StageContent(stage: stage),
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

// ── Stage card content ────────────────────────────────────────────────────────
class _StageContent extends StatefulWidget {
  final StageModel stage;
  const _StageContent({required this.stage});

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

    return Obx(() {
      final ctrl   = Get.find<ProjectsController>();
      final status = ctrl.stageStatus(widget.stage.id, widget.stage.status.name);
      final progressPct = ctrl.stageProgress(widget.stage.id, widget.stage.progress);
      final isCompleted  = status == 'completed';
      final isInProgress = status == 'inProgress' || (status == 'notStarted' && widget.stage.isInProgress);
      final isPending    = status == 'notStarted' && !widget.stage.isInProgress && !widget.stage.isCompleted;

      if (isPending) {
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.stage.name, style: AppTextStyles.labelLarge(context)),
              if (widget.stage.estimatedEndDate != null)
                Text(
                  'Starts ${DateFormatter.formatDateShort(widget.stage.estimatedEndDate!)}',
                  style: AppTextStyles.caption(context),
                ),
              const SizedBox(height: 6),
              SizedBox(
                height: 28,
                child: OutlinedButton(
                  onPressed: () {
                    ctrl.markStageInProgress(widget.stage.id);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            Row(
              children: [
                Expanded(child: Text(widget.stage.name, style: AppTextStyles.h4(context))),
                if (isInProgress)
                  const AppBadge(label: 'IN PROGRESS', variant: BadgeVariant.inProgress),
                if (isCompleted)
                  const AppBadge(label: 'DONE', variant: BadgeVariant.completed),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isCompleted
                  ? 'Completed'
                  : 'In progress · ${widget.stage.daysLeft} days left',
              style: AppTextStyles.caption(context),
            ),
            const SizedBox(height: AppDimensions.md),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              child: LinearProgressIndicator(
                value: (progressPct / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? AppColors.success : cs.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${progressPct.toStringAsFixed(0)}%',
                style: AppTextStyles.labelSmall(context),
              ),
            ),

            if (!isCompleted) ...[
              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                ),
                child: Slider(
                  value: progressPct.clamp(0.0, 100.0),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  activeColor: cs.primary,
                  inactiveColor: divider,
                  onChanged: (val) => ctrl.updateStageProgress(widget.stage.id, val),
                ),
              ),

              const SizedBox(height: AppDimensions.sm),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.photo_library_outlined, size: 14),
                    label: Text('View Photos (${widget.stage.photoCount})'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _justCompleted = true);
                      ctrl.markStageComplete(widget.stage.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        widget.stage.completionPct < 100 ? widget.stage.completionPct : 90);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                  child: const Text('Reopen'),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

// ── Updates tab ───────────────────────────────────────────────────────────────
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
    _UpdateEntry(
      author: 'Bashir Ahmed', initials: 'BA', role: 'Site Supervisor',
      text: 'Excavation completed. Soil tested. Foundation mark-out done.',
      stageName: 'Excavation', date: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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

  @override
  Widget build(BuildContext context) {
    // ── Empty state (State 4) ─────────────────────────────────────────────
    if (_updates.isEmpty) {
      final cs = Theme.of(context).colorScheme;
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
                    child: Icon(Icons.campaign_rounded,
                        size: 40, color: cs.primary.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 20),
                  Text('No Updates Yet',
                      style: AppTextStyles.h3(context),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'Post the first project update to keep everyone informed',
                    style: AppTextStyles.bodySmall(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _openAddSheet(context),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Post Update'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20, bottom: 20,
            child: FloatingActionButton.small(
              onPressed: () => _openAddSheet(context),
              child: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: _updates.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _UpdateCard(entry: _updates[i]),
        ),
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
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
            ),
          ),
        ),
      ],
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
                        fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.author, style: AppTextStyles.labelLarge(context)),
                    Text(entry.role,   style: AppTextStyles.caption(context)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_relTime(entry.date), style: AppTextStyles.caption(context)),
                  if (entry.stageName != null) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(entry.stageName!,
                          style: TextStyle(
                              fontSize: 9, fontWeight: FontWeight.w600, color: cs.primary)),
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
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.textSecondaryLight),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderLight)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
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

// ── Budget tab ────────────────────────────────────────────────────────────────
class _BudgetTab extends StatelessWidget {
  final dynamic project;
  const _BudgetTab({required this.project});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;
    double budget = 0;
    double spent  = 0;
    try {
      budget = (project.budgetAmount as double?) ?? (project.totalBudget as double? ?? 0);
      spent  = (project.actualCost as double?)  ?? (project.spentBudget as double? ?? 0);
    } catch (_) {}
    final pct = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
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
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
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

        // ── Expenses empty state (State 5) ────────────────────────────────
        const SizedBox(height: AppDimensions.xl),
        _ExpensesEmptyState(),
      ],
    );
  }
}

// ── Expenses empty state ──────────────────────────────────────────────────────
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
              size: 40, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
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

class _BudgetStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _BudgetStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption(context)),
        ],
      );
}

// ── Labor tab ─────────────────────────────────────────────────────────────────
class _LaborTab extends StatelessWidget {
  final dynamic project;
  const _LaborTab({required this.project});

  @override
  Widget build(BuildContext context) {
    final workerCount = (project.workerCount as int?) ?? 0;
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.base),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(Icons.people_outline,
                  color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$workerCount Active Workers',
                        style: AppTextStyles.h4(context).copyWith(
                            color: Theme.of(context).colorScheme.primary)),
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
          color: Theme.of(context).colorScheme.primary,
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
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── Photos tab (Fix 4) ────────────────────────────────────────────────────────

class _PhotoEntry {
  final String path;        // local file path
  final String? stageName;
  final String? caption;
  final DateTime takenAt;

  const _PhotoEntry({
    required this.path,
    this.stageName,
    this.caption,
    required this.takenAt,
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

  List<StageModel> get _stages => (widget.project.stages as List<StageModel>);

  Future<void> _pickPhoto(ImageSource source) async {
    Navigator.of(context).pop(); // close action sheet
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    _pendingFile = file;
    _showTaggingSheet();
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (_, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
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
                // Stage dropdown
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
                    const DropdownMenuItem(value: null, child: Text('— No stage —')),
                    ..._stages.map((s) => DropdownMenuItem(
                          value: s.name,
                          child: Text(s.name),
                        )),
                  ],
                  onChanged: (v) => setSheetState(() => selectedStage = v),
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
                                         ? null
                                         : captionCtrl.text.trim(),
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
        );
      },
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
            minScale: 0.5,
            maxScale: 5.0,
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
                  Text(
                    'Upload site photos to track visual progress',
                    style: AppTextStyles.bodySmall(context),
                    textAlign: TextAlign.center,
                  ),
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
            child: FloatingActionButton.extended(
              onPressed: _showAddOptions,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: const Text('Add Photo'),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    Image.file(File(p.path), fit: BoxFit.cover),
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
                            Text(
                              _formatDate(p.takenAt),
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.white70),
                            ),
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
            onPressed: _showAddOptions,
            child: const Icon(Icons.add_photo_alternate_rounded),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
