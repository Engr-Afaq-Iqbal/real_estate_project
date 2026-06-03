import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../controllers/projects_controller.dart';
import '../data/models/stage_model.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_badge.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/routes/app_routes.dart';

class ProjectStageTrackerScreen extends GetView<ProjectsController> {
  const ProjectStageTrackerScreen({super.key});

  static const _tabs = ['Stages', 'Photos', 'Budget', 'Labor', 'Documents'];

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
              const Center(child: Text('Photos coming soon')),
              const Center(child: Text('Budget coming soon')),
              const Center(child: Text('Labor coming soon')),
              const Center(child: Text('Documents coming soon')),
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
    final stages = project.stages as List<StageModel>;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        // Project summary card
        Container(
          padding: const EdgeInsets.all(AppDimensions.base),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.home_outlined, color: AppColors.primary, size: 40),
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
                progressColor: AppColors.primary,
                backgroundColor: isDark ? AppColors.borderDark : AppColors.dividerLight,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                          : (isDark ? AppColors.borderDark : AppColors.dividerLight),
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
    if (stage.isCompleted) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      );
    }
    if (stage.isInProgress) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight, width: 2),
      ),
      child: Center(
        child: Text(
          '${stage.order}',
          style: const TextStyle(fontSize: 11, color: AppColors.textTertiaryLight),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: stage.isInProgress
              ? AppColors.primary.withValues(alpha: 0.3)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: stage.isInProgress ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(stage.name, style: AppTextStyles.h4(context))),
              if (stage.isInProgress)
                const AppBadge(label: 'IN PROGRESS', variant: BadgeVariant.inProgress),
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
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              child: LinearProgressIndicator(
                value: stage.progress / 100,
                minHeight: 6,
                backgroundColor: isDark ? AppColors.borderDark : AppColors.dividerLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
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
