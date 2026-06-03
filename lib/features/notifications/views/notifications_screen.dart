import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notifications'.tr),
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            child: Text('mark_all_read'.tr, style: const TextStyle(color: AppColors.accent, fontSize: 13)),
          ),
        ],
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          children: controller.notifications.entries.expand((entry) => [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
              child: Text(entry.key, style: AppTextStyles.overline(context)),
            ),
            ...entry.value.map((n) => _NotificationRow(notification: n)),
          ]).toList(),
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final AppNotification notification;
  const _NotificationRow({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: notification.isRead
            ? (isDark ? AppColors.surfaceDark : AppColors.cardLight)
            : (isDark ? AppColors.surfaceDark : AppColors.backgroundLight),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _iconBgColor(),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconData(), size: 18, color: _iconColor()),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: AppTextStyles.h4(context)),
                const SizedBox(height: 2),
                Text(notification.body, style: AppTextStyles.bodySmall(context)),
                const SizedBox(height: 4),
                Text(notification.timeAgo, style: AppTextStyles.caption(context)),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconData() {
    switch (notification.type) {
      case 'stage': return Icons.check_circle_outline_rounded;
      case 'budget': return Icons.warning_amber_rounded;
      case 'message': return Icons.chat_bubble_outline_rounded;
      case 'ai': return Icons.warning_amber_rounded;
      default: return Icons.notifications_outlined;
    }
  }

  Color _iconColor() {
    switch (notification.type) {
      case 'stage': return AppColors.success;
      case 'budget': return AppColors.warning;
      case 'message': return AppColors.primary;
      case 'ai': return AppColors.error;
      default: return AppColors.textSecondaryLight;
    }
  }

  Color _iconBgColor() {
    switch (notification.type) {
      case 'stage': return AppColors.successLight;
      case 'budget': return AppColors.warningLight;
      case 'message': return AppColors.infoLight;
      case 'ai': return AppColors.errorLight;
      default: return AppColors.backgroundLight;
    }
  }
}
