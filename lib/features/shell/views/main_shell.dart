import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/shell_controller.dart';
import '../../../presentation/widgets/layout/bottom_nav_bar.dart';
import '../../dashboard/views/homeowner_dashboard_screen.dart';
import '../../dashboard/views/developer_dashboard_screen.dart';
import '../../projects/views/my_projects_screen.dart';
import '../../calculator/views/calculator_hub_screen.dart';
import '../../chat/views/chat_screen.dart';
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

  static const _homeownerScreens = [
    HomeownerDashboardScreen(),
    MyProjectsScreen(),
    CalculatorHubScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  static const _developerScreens = [
    DeveloperDashboardScreen(),
    MyProjectsScreen(),
    CalculatorHubScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];
}
