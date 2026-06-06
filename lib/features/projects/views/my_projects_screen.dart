import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/projects_controller.dart';
import '../data/models/project_model.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_badge.dart';
import '../../../presentation/widgets/common/app_card.dart';
import '../../../presentation/widgets/common/error_state_widget.dart';
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
                      onChanged: (v) => controller.searchQuery.value = v,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter chips
          const SizedBox(height: AppDimensions.md),
          Obx(() => SingleChildScrollView(
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
                      selected:
                          controller.selectedFilter.value == 'completed',
                      onTap: () =>
                          controller.selectedFilter.value = 'completed',
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    _FilterChip(
                      label: 'on_hold'.tr,
                      selected: controller.selectedFilter.value == 'on_hold',
                      onTap: () =>
                          controller.selectedFilter.value = 'on_hold',
                    ),
                  ],
                ),
              )),

          const SizedBox(height: AppDimensions.md),

          // Project list / states
          Expanded(
            child: Obx(() {
              // ── Error state ───────────────────────────────────────────────
              if (controller.hasLoadError.value) {
                return ErrorStateWidget(
                  onRetry: controller.loadProjects,
                );
              }

              // ── Skeleton loading (State 1) ────────────────────────────────
              if (controller.isLoading.value) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.pagePaddingH,
                    vertical: AppDimensions.sm,
                  ),
                  itemCount: 3,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimensions.md),
                  itemBuilder: (_, __) => const _SkeletonProjectCard(),
                );
              }

              final list = controller.filteredProjects;

              // ── Empty state (State 2) ─────────────────────────────────────
              if (list.isEmpty) {
                return _ProjectsEmptyState(
                  isFiltered: controller.projects.isNotEmpty,
                );
              }

              // ── Populated list ────────────────────────────────────────────
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

// ── Skeleton card (State 1) ───────────────────────────────────────────────────

class _SkeletonProjectCard extends StatelessWidget {
  const _SkeletonProjectCard();

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final base     = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
    final highlight = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);
    final surface  = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: avatar + text lines
            Row(
              children: [
                _Block(width: 40, height: 40,
                    radius: AppDimensions.radiusSm),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Block(height: 13, radius: 4),
                      const SizedBox(height: 6),
                      _Block(width: 130, height: 10, radius: 4),
                      const SizedBox(height: 4),
                      _Block(width: 100, height: 10, radius: 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Stage badge placeholder
            _Block(width: 90, height: 22,
                radius: AppDimensions.radiusFull),
            const SizedBox(height: 10),
            // Progress bar
            _Block(height: AppDimensions.progressBarHeight,
                radius: AppDimensions.radiusFull),
            const SizedBox(height: 10),
            // Footer row
            Row(
              children: [
                _Block(width: 110, height: 10, radius: 4),
                const Spacer(),
                _Block(width: 64, height: 22, radius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// A solid white block used inside the shimmer
class _Block extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const _Block({this.width, required this.height, this.radius = 4});

  @override
  Widget build(BuildContext context) => Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

// ── Empty state (State 2) ─────────────────────────────────────────────────────

class _ProjectsEmptyState extends StatelessWidget {
  final bool isFiltered; // true → search/filter produced no results
  const _ProjectsEmptyState({required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isFiltered) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded,
                  size: 56,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              Text('No matching projects',
                  style: AppTextStyles.h3(context),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Try a different search or filter',
                  style: AppTextStyles.bodySmall(context),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Construction helmet / building illustration
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.construction_rounded,
                size: 48,
                color: cs.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Projects Yet',
              style: AppTextStyles.h2(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Start by adding your first construction project',
              style: AppTextStyles.bodyMedium(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.newProjectWizard),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add New Project'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 20),
                ),
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
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
                child:
                    Icon(Icons.home_outlined, color: cs.primary, size: 20),
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
