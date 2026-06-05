import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/shell_controller.dart';
import '../../../presentation/widgets/layout/bottom_nav_bar.dart';

// 3-tab navigation: Home | Projects | Settings
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
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: screens,
        ),
        bottomNavigationBar: const AppBottomNavBar(),
      );
    });
  }

  // Tab 0: Dashboard  |  Tab 1: Projects  |  Tab 2: Settings
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
