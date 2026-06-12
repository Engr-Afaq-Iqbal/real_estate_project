import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../market/controllers/market_controller.dart';
import '../../tasks/controllers/tasks_controller.dart';
import '../../../presentation/routes/app_routes.dart';
import 'market_selector_pill.dart';

const _kError = Color(0xFFDC2626);

/// Greeting bar: "Good morning ☀️ / Ahmed" + market pill + bell + avatar.
/// Below the greeting row an optional Arabic-market banner is shown.
class DashboardHeaderWidget extends StatelessWidget {
  final AuthController auth;
  final DashboardController controller;

  const DashboardHeaderWidget({
    super.key,
    required this.auth,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final divider = Theme.of(context).dividerColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Main header row ───────────────────────────────────────────────
        Container(
          color: surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              // Greeting + user name
              Expanded(
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${auth.greeting} ☀️',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.currentUser.value?.name.split(' ').first ??
                              'Ahmed',
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                              height: 1.1),
                        ),
                      ],
                    )),
              ),
              // Tasks hub icon (badge = pending tasks/meetings/alerts)
              if (Get.isRegistered<TasksController>())
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Semantics(
                    label: 'Tasks',
                    button: true,
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.tasks),
                      child: Obx(() {
                        final pending =
                            Get.find<TasksController>().pendingCount;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                  color: isDark
                                      ? cs.surfaceContainerHighest
                                      : divider.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.checklist_rounded,
                                  size: 20, color: cs.onSurface),
                            ),
                            if (pending > 0)
                              Positioned(
                                top: -4, right: -4,
                                child: AnimatedSwitcher(
                                  duration:
                                      const Duration(milliseconds: 250),
                                  transitionBuilder: (child, anim) =>
                                      ScaleTransition(
                                          scale: anim, child: child),
                                  child: Container(
                                    key: ValueKey(pending),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    constraints:
                                        const BoxConstraints(minWidth: 17),
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                          color: surface, width: 1.5),
                                    ),
                                    child: Text(
                                      pending > 9 ? '9+' : '$pending',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              // Notification bell
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.notifications),
                child: Obx(() => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                              color: isDark
                                  ? cs.surfaceContainerHighest
                                  : divider.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.notifications_outlined,
                              size: 20, color: cs.onSurface),
                        ),
                        if (controller.unreadNotifications.value > 0)
                          Positioned(
                            top: 6, right: 6,
                            child: Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: _kError,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: surface, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    )),
              ),
              const SizedBox(width: 10),
              // Avatar
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.profile),
                child: Obx(() => Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                          color: cs.primary, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          auth.currentUser.value?.initials ?? 'AK',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ),

        // ── Market pill row ───────────────────────────────────────────────
        Container(
          color: surface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: const Row(
            children: [
              MarketSelectorPill(),
            ],
          ),
        ),

        // ── Arabic market banner (optional) ───────────────────────────────
        _ArabicBanner(),
      ],
    );
  }
}

/// Slim amber banner shown when the selected market is Arabic-speaking.
class _ArabicBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MarketController>()) {
      return const SizedBox.shrink();
    }
    final ctrl = Get.find<MarketController>();
    return Obx(() {
      if (!ctrl.isArabic) return const SizedBox.shrink();
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: const ValueKey('arabic_banner'),
          width: double.infinity,
          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text('🌙', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Switch to Arabic for full RTL experience',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF59E0B)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.snackbar(
                    'Arabic Coming Soon 🔜',
                    'Full Arabic RTL interface is being prepared.',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Switch',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF59E0B))),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
