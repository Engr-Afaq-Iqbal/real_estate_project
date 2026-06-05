import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/projects_controller.dart';
import '../data/models/project_model.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_badge.dart';
import '../../../presentation/widgets/common/app_card.dart';
import '../../../presentation/widgets/common/app_empty_state.dart';
import '../../../presentation/widgets/common/app_loading.dart';
import '../../../presentation/routes/app_routes.dart';

class MyProjectsScreen extends GetView<ProjectsController> {
  const MyProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('my_projects'.tr),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.newProjectWizard),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePaddingH,
              AppDimensions.md,
              AppDimensions.pagePaddingH,
              0,
            ),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: divider),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(Icons.search_rounded,
                        color: cs.onSurfaceVariant, size: 20),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search projects...',
                        border: InputBorder.none,
                        hintStyle: AppTextStyles.bodySmall(context),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter chips
          const SizedBox(height: AppDimensions.md),
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pagePaddingH),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'all'.tr,
                    selected: controller.selectedFilter.value == 'all',
                    onTap: () => controller.selectedFilter.value = 'all',
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  _FilterChip(
                    label: 'active_label'.tr,
                    selected: controller.selectedFilter.value == 'active',
                    onTap: () => controller.selectedFilter.value = 'active',
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  _FilterChip(
                    label: 'completed_label'.tr,
                    selected: controller.selectedFilter.value == 'completed',
                    onTap: () => controller.selectedFilter.value = 'completed',
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  _FilterChip(
                    label: 'on_hold'.tr,
                    selected: controller.selectedFilter.value == 'on_hold',
                    onTap: () => controller.selectedFilter.value = 'on_hold',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.md),

          // Project list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: AppLoadingIndicator(size: 32));
              }
              final list = controller.filteredProjects;
              if (list.isEmpty) {
                return AppEmptyState(
                  title: 'No projects yet',
                  subtitle: 'Tap + to create your first project',
                  icon: Icons.folder_open_outlined,
                  buttonLabel: 'New Project',
                  onAction: () => Get.toNamed(AppRoutes.newProjectWizard),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pagePaddingH,
                  vertical: AppDimensions.sm,
                ),
                itemCount: list.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppDimensions.md),
                itemBuilder: (_, i) => _ProjectCard(project: list[i]),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.newProjectWizard),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius:
              BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: selected ? cs.primary : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ── Project card ──────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return AppCard(
      onTap: () {
        Get.find<ProjectsController>().selectProject(project);
        Get.toNamed(AppRoutes.projectStageTracker, arguments: project);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Icon(Icons.home_outlined,
                    color: cs.primary, size: 20),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.name, style: AppTextStyles.h4(context)),
                    Text('${project.area}, ${project.city}',
                        style: AppTextStyles.caption(context)),
                    Text(
                      'Started ${project.startDate != null ? DateFormatter.formatDateShort(project.startDate!) : '—'}',
                      style: AppTextStyles.caption(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          StageBadge(stage: project.currentStage),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  child: LinearProgressIndicator(
                    value: project.progress,
                    minHeight: AppDimensions.progressBarHeight,
                    backgroundColor: divider,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(cs.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                '${(project.progress * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.h4(context),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              Text(
                'Last updated ${_relativeTime(project.lastUpdated)}',
                style: AppTextStyles.caption(context),
              ),
              const Spacer(),
              AppBadge(
                label: project.statusLabel,
                variant: _badgeVariant(project.statusLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BadgeVariant _badgeVariant(String label) {
    if (label == 'ON TRACK') return BadgeVariant.onTrack;
    if (label == 'AT RISK')  return BadgeVariant.atRisk;
    if (label.startsWith('LATE')) return BadgeVariant.late;
    return BadgeVariant.inProgress;
  }

  String _relativeTime(DateTime? dt) {
    if (dt == null) return 'recently';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
