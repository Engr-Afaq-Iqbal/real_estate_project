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
                        done: 34,
                        bids: 5,
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      _RevenueCard(
                        revenue: 4200000,
                        target: 6200000,
                        growthPercent: 12,
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      _buildActiveProjectsSection(context),
                      const SizedBox(height: AppDimensions.xl),
                      _BidRequestsBanner(count: 5, newCount: 3),
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
  final int bids;

  const _StatsRow({
    required this.active,
    required this.done,
    required this.bids,
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
              value: '$bids',
              label: 'bids'.tr,
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

class _RevenueCard extends StatelessWidget {
  final double revenue;
  final double target;
  final int growthPercent;

  const _RevenueCard({
    required this.revenue,
    required this.target,
    required this.growthPercent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = revenue / target;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'this_month'.tr,
            style: AppTextStyles.overline(context),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            'REVENUE',
            style: AppTextStyles.labelSmall(context),
          ),
          const SizedBox(height: AppDimensions.xs),
          Row(
            children: [
              Text(
                CurrencyFormatter.formatCompact(revenue),
                style: AppTextStyles.amountLarge(context),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '▲ $growthPercent%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: AppDimensions.progressBarHeightLg,
              backgroundColor:
                  isDark ? AppColors.borderDark : AppColors.dividerLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% of ${CurrencyFormatter.formatCompact(target)} target',
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

class _BidRequestsBanner extends StatelessWidget {
  final int count;
  final int newCount;

  const _BidRequestsBanner({required this.count, required this.newCount});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count New Bid Requests',
                  style: AppTextStyles.h4(context).copyWith(color: AppColors.accent),
                ),
                Text(
                  '$newCount new since last visit',
                  style: AppTextStyles.caption(context),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight),
        ],
      ),
    );
  }
}
