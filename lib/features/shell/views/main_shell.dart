import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/shell_controller.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../presentation/widgets/layout/bottom_nav_bar.dart';

import '../../dashboard/views/homeowner_dashboard_screen.dart';
import '../../dashboard/views/developer_dashboard_screen.dart';
import '../../projects/views/my_projects_screen.dart';
import '../../settings/views/settings_screen.dart';

class MainShell extends GetView<ShellController> {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final screens = controller.isHomeowner
          ? _homeownerScreens
          : _developerScreens;

      return Scaffold(
        body: Column(
          children: [
            const _OfflineBanner(),
            Expanded(
              child: IndexedStack(
                index: controller.currentIndex.value,
                children: screens,
              ),
            ),
          ],
        ),
        bottomNavigationBar: const AppBottomNavBar(),
      );
    });
  }

  static const _homeownerScreens = [
    HomeownerDashboardScreen(),
    MyProjectsScreen(),
    SettingsScreen(),
  ];

  static const _developerScreens = [
    DeveloperDashboardScreen(),
    MyProjectsScreen(),
    SettingsScreen(),
  ];
}

// ── Offline banner ────────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    // Guard: ConnectivityService may not be registered yet on first frame.
    if (!Get.isRegistered<ConnectivityService>()) {
      return const SizedBox.shrink();
    }
    final svc = Get.find<ConnectivityService>();
    return Obx(() {
      final online = svc.isConnected.value;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, anim) => SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          ),
          axisAlignment: -1,
          child: child,
        ),
        child: online
            ? const SizedBox.shrink(key: ValueKey('online'))
            : SafeArea(
                bottom: false,
                key: const ValueKey('offline'),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFEA580C), // orange-600
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'You are offline — changes will sync when reconnected',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    });
  }
}
