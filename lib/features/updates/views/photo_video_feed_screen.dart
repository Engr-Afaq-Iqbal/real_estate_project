import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/updates_controller.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_card.dart';

class PhotoVideoFeedScreen extends GetView<UpdatesController> {
  const PhotoVideoFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stageFilters = ['All Stages', 'Gray Structure', 'Foundation', 'Plastering'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('progress_updates'.tr),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stage filters
          SizedBox(
            height: 44,
            child: Obx(
              () {
                final selected = controller.selectedStageFilter.value;
                return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pagePaddingH,
                  vertical: 8,
                ),
                itemCount: stageFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final filter = stageFilters[i];
                  final isSelected = selected == filter;
                  return GestureDetector(
                    onTap: () => controller.selectedStageFilter.value = filter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.borderLight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
              },
            ),
          ),

          // Feed
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.md),
              itemBuilder: (_, i) => _UpdateCard(index: i),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.dividerLight)),
        ),
        child: OutlinedButton(
          onPressed: () {},
          child: const Text('Request Update'),
        ),
      ),
    );
  }
}

class _UpdateCard extends StatelessWidget {
  final int index;
  const _UpdateCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Malik Construction', style: AppTextStyles.h4(context)),
                      Text(index == 0 ? '2h ago' : (index == 1 ? 'Yesterday' : '3d ago'), style: AppTextStyles.caption(context)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.stageGrayStructure.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'GRAY STRUCTURE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.stageGrayStructure),
                  ),
                ),
              ],
            ),
          ),

          // Photo placeholder
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: isDark ? AppColors.surfaceDark : AppColors.dividerLight,
                child: const Icon(Icons.image_outlined, size: 40, color: AppColors.textTertiaryLight),
              ),
              Positioned(
                top: AppDimensions.sm,
                right: AppDimensions.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('1/4', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Slab work for second floor poured today. Curing for next 7 days as planned.',
                  style: AppTextStyles.bodySmall(context),
                ),
                const SizedBox(height: AppDimensions.xs),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textTertiaryLight),
                    const SizedBox(width: 2),
                    Text('DHA Phase 6, Lahore', style: AppTextStyles.caption(context)),
                    const Spacer(),
                    const Icon(Icons.verified_outlined, size: 12, color: AppColors.success),
                    const SizedBox(width: 4),
                    const Text('AI Verified', style: TextStyle(fontSize: 11, color: AppColors.success)),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
                      label: const Text('Comment'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.zoom_in_rounded, size: 14),
                      label: const Text('View All (4)'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
