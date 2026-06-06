import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../projects/data/models/project_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_card.dart';
import '../../../presentation/widgets/common/app_loading.dart';
import '../../../presentation/routes/app_routes.dart';
import '../../../presentation/widgets/common/error_state_widget.dart';

class DeveloperDashboardScreen extends GetView<DashboardController> {
  const DeveloperDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: AppLoadingIndicator(size: 32));
          }
          if (controller.hasLoadError.value) {
            return ErrorStateWidget(onRetry: controller.loadDashboard);
          }
          return RefreshIndicator(
            onRefresh: controller.loadDashboard,
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                _buildHeader(context),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.pagePaddingH,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _StatsRow(
                        active: controller.activeProjects.length,
                        done: controller.projects
                            .where((p) => p.status == 'completed')
                            .length,
                        workers: controller.projects
                            .fold(0, (s, p) => s + p.workerCount),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      _PortfolioBudgetCard(projects: controller.projects),
                      const SizedBox(height: AppDimensions.xl),
                      _buildActiveProjectsSection(context),
                      const SizedBox(height: AppDimensions.xxxl),
                    ]),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  SliverAppBar _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Get.find<AuthController>();
    return SliverAppBar(
      floating: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Malik Builders',
            style: AppTextStyles.h2(context),
          ),
          Text(
            'PEC #B-2841 · Verified',
            style: AppTextStyles.caption(context),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.notifications),
          icon: const Icon(Icons.notifications_outlined, size: 26),
        ),
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined, size: 24),
        ),
      ],
    );
  }

  Widget _buildActiveProjectsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('active_projects'.tr, style: AppTextStyles.h3(context)),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.myProjects),
              child: Text(
                'see_all'.tr,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        ...controller.projects.map((p) => _ActiveProjectRow(project: p)),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int active;
  final int done;
  final int workers;

  const _StatsRow({
    required this.active,
    required this.done,
    required this.workers,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.base),
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              value: '$active',
              label: 'active'.tr,
              color: AppColors.primary,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.dividerLight),
          Expanded(
            child: _StatCell(
              value: '$done',
              label: 'done_label'.tr,
              color: AppColors.success,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.dividerLight),
          Expanded(
            child: _StatCell(
              value: '$workers',
              label: 'workers'.tr.isEmpty ? 'Workers' : 'Workers',
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCell({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(label, style: AppTextStyles.caption(context)),
      ],
    );
  }
}

class _PortfolioBudgetCard extends StatelessWidget {
  final List<ProjectModel> projects;
  const _PortfolioBudgetCard({required this.projects});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalBudget = projects.fold(0.0, (s, p) => s + p.totalBudget);
    final totalSpent  = projects.fold(0.0, (s, p) => s + p.spentBudget);
    final progress    = totalBudget > 0 ? totalSpent / totalBudget : 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PORTFOLIO BUDGET', style: AppTextStyles.overline(context)),
          const SizedBox(height: AppDimensions.xs),
          Row(
            children: [
              Text(
                CurrencyFormatter.formatCompact(totalSpent),
                style: AppTextStyles.amountLarge(context),
              ),
              const Spacer(),
              Text(
                'of ${CurrencyFormatter.formatCompact(totalBudget)}',
                style: AppTextStyles.caption(context),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: AppDimensions.progressBarHeightLg,
              backgroundColor:
                  isDark ? AppColors.borderDark : AppColors.dividerLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% spent across ${projects.length} project${projects.length == 1 ? '' : 's'}',
            style: AppTextStyles.caption(context),
          ),
        ],
      ),
    );
  }
}

class _ActiveProjectRow extends StatelessWidget {
  final ProjectModel project;
  const _ActiveProjectRow({required this.project});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      onTap: () => Get.toNamed(AppRoutes.projectStageTracker, arguments: project),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.xs),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _statusColor(),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
              ),
              child: const Icon(Icons.business_outlined,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.name, style: AppTextStyles.h4(context)),
                  Text(
                    '${project.area} · ${CurrencyFormatter.formatCompact(project.totalBudget)}',
                    style: AppTextStyles.caption(context),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(project.progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(),
                  ),
                ),
                Text(
                  project.isLate
                      ? 'Late ${project.weeksLeft.abs()}d'
                      : '${project.weeksLeft}d left',
                  style: TextStyle(
                    fontSize: 11,
                    color: _statusColor(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor() {
    if (project.isLate) return AppColors.error;
    if (project.isAtRisk) return AppColors.warning;
    return AppColors.success;
  }
}

// _BidRequestsBanner removed — Phase 3 marketplace feature
