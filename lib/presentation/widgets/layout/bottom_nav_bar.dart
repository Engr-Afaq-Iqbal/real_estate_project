import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/shell/controllers/shell_controller.dart';

const _kNavAccent = Color(0xFF2563EB);
const _kNavMuted = Color(0xFF9CA3AF);
const _kNavBg = Color(0xFFFFFFFF);
const _kNavBorder = Color(0xFFF0F2F5);

class AppBottomNavBar extends GetView<ShellController> {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kNavBg,
        border: Border(top: BorderSide(color: _kNavBorder, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Obx(
            () => Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'nav_home'.tr,
                  index: 0,
                  currentIndex: controller.currentIndex.value,
                  onTap: () => controller.changeTab(0),
                ),
                _NavItem(
                  icon: Icons.folder_open_outlined,
                  activeIcon: Icons.folder_rounded,
                  label: 'nav_projects'.tr,
                  index: 1,
                  currentIndex: controller.currentIndex.value,
                  onTap: () => controller.changeTab(1),
                ),
                _NavItem(
                  icon: Icons.calculate_outlined,
                  activeIcon: Icons.calculate_rounded,
                  label: 'nav_calculator'.tr,
                  index: 2,
                  currentIndex: controller.currentIndex.value,
                  onTap: () => controller.changeTab(2),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'nav_messages'.tr,
                  index: 3,
                  currentIndex: controller.currentIndex.value,
                  onTap: () => controller.changeTab(3),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'nav_settings'.tr,
                  index: 4,
                  currentIndex: controller.currentIndex.value,
                  onTap: () => controller.changeTab(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                size: 22,
                color: isActive ? _kNavAccent : _kNavMuted,
              ),
            ),
            const SizedBox(height: 3),
            // Label
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? _kNavAccent : _kNavMuted,
              ),
            ),
            const SizedBox(height: 4),
            // Active dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: isActive ? _kNavAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
