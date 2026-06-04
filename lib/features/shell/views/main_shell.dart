import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/shell_controller.dart';
import '../../../presentation/widgets/layout/bottom_nav_bar.dart';

// Tabs (in order)
import '../../dashboard/views/homeowner_dashboard_screen.dart';
import '../../dashboard/views/developer_dashboard_screen.dart';
import '../../projects/views/my_projects_screen.dart';
import '../../updates/views/photo_video_feed_screen.dart';
import '../../notifications/views/notifications_screen.dart';
import '../../profile/views/profile_screen.dart';

/// New navigation: Dashboard | Projects | Updates | Notifications | Profile
///
/// Calculator → Dashboard widget (expandable card)
/// Chat       → Project detail tab
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

  // Tab 0: Dashboard  1: Projects  2: Updates  3: Notifications  4: Profile
  static const _homeownerScreens = [
    HomeownerDashboardScreen(),
    MyProjectsScreen(),
    PhotoVideoFeedScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  static const _developerScreens = [
    DeveloperDashboardScreen(),
    MyProjectsScreen(),
    PhotoVideoFeedScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];
}
