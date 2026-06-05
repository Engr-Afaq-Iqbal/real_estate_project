import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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

  static const _tabs = ['Stages', 'Updates', 'Budget', 'Labor', 'Documents'];

  @override
  Widget build(BuildContext context) {
    final project = controller.selectedProject.value;
    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project')),
        body: const Center(child: Text('No project selected')),
      );
    }

    // DefaultTabController must be an ancestor of BOTH TabBar and TabBarView.
    // Placing it here makes it visible to everything inside the Scaffold tree.
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              pinned: true,
              title: Text(project.name.split(' — ').first),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz_rounded),
                ),
              ],
              // TabBar sits here and inherits DefaultTabController from above.
              bottom: TabBar(
                isScrollable: true,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
          ],
          // TabBarView also inherits the same DefaultTabController.
          body: TabBarView(
            children: [
              _StagesList(project: project),
              _UpdatesTab(project: project),
              _BudgetTab(project: project),
              _LaborTab(project: project),
              _DocumentsTab(project: project),
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
              CircularPercentIndicator(
                radius: 28,
                lineWidth: 4,
                percent: (project.progress as double).clamp(0.0, 1.0),
                center: Text(
                  '${((project.progress as double) * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.labelSmall(context),
                ),
                progressColor: cs.primary,
                backgroundColor: divider,
              ),
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
                      color: stage.isCompleted
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

    if (stage.isCompleted) {
      return Container(
        width: 28, height: 28,
        decoration: const BoxDecoration(
            color: AppColors.success, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      );
    }
    if (stage.isInProgress) {
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
  }
}

class _StageContent extends StatelessWidget {
  final StageModel stage;
  const _StageContent({required this.stage});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    if (stage.isPending) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stage.name, style: AppTextStyles.labelLarge(context)),
            if (stage.estimatedEndDate != null)
              Text(
                'Starts ${DateFormatter.formatDateShort(stage.estimatedEndDate!)}',
                style: AppTextStyles.caption(context),
              ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: stage.isInProgress
              ? cs.primary.withValues(alpha: 0.3)
              : divider,
          width: stage.isInProgress ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(stage.name, style: AppTextStyles.h4(context))),
              if (stage.isInProgress)
                const AppBadge(
                    label: 'IN PROGRESS', variant: BadgeVariant.inProgress),
              if (stage.isCompleted)
                const AppBadge(label: 'DONE', variant: BadgeVariant.completed),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            stage.isCompleted
                ? 'Completed · ${DateFormatter.formatDateShort(stage.endDate ?? DateTime.now())}'
                : 'In progress · ${stage.daysLeft} days left',
            style: AppTextStyles.caption(context),
          ),
          if (stage.isInProgress) ...[
            const SizedBox(height: AppDimensions.md),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusFull),
              child: LinearProgressIndicator(
                value: stage.progress / 100,
                minHeight: 6,
                backgroundColor: divider,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${stage.progress.toStringAsFixed(0)}%',
                style: AppTextStyles.labelSmall(context),
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_library_outlined, size: 14),
                  label: Text('View Photos (${stage.photoCount})'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => Get.toNamed(AppRoutes.stageDetail),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: const Text('+ Add Update'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Updates tab (project-scoped) ─────────────────────────────────────────────

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
      // Let the modal own its appearance — avoids transparent PhysicalShape
      // layout failure when crossAxisAlignment is loose.
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
    return Stack(
      children: [
        // Feed list
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: _updates.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _UpdateCard(entry: _updates[i]),
        ),
        // FAB
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
              // Avatar
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

  const _AddUpdateSheet({
    required this.ctrl,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // viewInsets.bottom accounts for the soft keyboard height
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      // The modal provides white bg + rounded corners via shape parameter.
      // We only add internal padding here — no BoxDecoration needed.
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment.start — avoids loose-width circular dependency
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.borderLight)),
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
              // Photo attach button (fixed size — no flex issues)
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
                        value: CurrencyFormatter.formatCompact(budget),
                        color: cs.primary),
                  ),
                  Expanded(
                    child: _BudgetStat(
                        label: 'Spent',
                        value: CurrencyFormatter.formatCompact(spent),
                        color: pct > 0.8 ? AppColors.error : AppColors.success),
                  ),
                  Expanded(
                    child: _BudgetStat(
                        label: 'Left',
                        value: CurrencyFormatter.formatCompact(budget - spent),
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
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
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
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.15)),
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
                            color:
                                Theme.of(context).colorScheme.primary)),
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
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
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

// ── Documents tab ─────────────────────────────────────────────────────────────
class _DocumentsTab extends StatelessWidget {
  final dynamic project;
  const _DocumentsTab({required this.project});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder_open_outlined,
              size: 48, color: AppColors.textTertiaryLight),
          const SizedBox(height: 12),
          Text('Documents', style: AppTextStyles.h3(context)),
          const SizedBox(height: 6),
          Text('Store drawings, NOC, and contracts',
              style: AppTextStyles.bodySmall(context)),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.documentsVault),
            icon: const Icon(Icons.folder_open_outlined, size: 16),
            label: const Text('Open Document Vault'),
          ),
        ],
      ),
    );
  }
}
