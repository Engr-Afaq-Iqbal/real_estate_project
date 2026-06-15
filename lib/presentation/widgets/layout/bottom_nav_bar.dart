import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/shell/controllers/shell_controller.dart';

const _kActive   = Color(0xFF1C3A7A);
const _kInactive = Color(0xFF9CA3AF);
const _kBg       = Color(0xFFFFFFFF);
const _kBorder   = Color(0xFFF0F2F5);

class AppBottomNavBar extends GetView<ShellController> {
  const AppBottomNavBar({super.key});

  // Customer tabs — 3 entries, indices 0-2
  static const _customerTabs = [
    (Icons.home_outlined,        Icons.home_rounded,       'Home'),
    (Icons.folder_open_outlined, Icons.folder_rounded,     'Projects'),
    (Icons.settings_outlined,    Icons.settings_rounded,   'Settings'),
  ];

  // Contractor tabs — 4 entries, indices 0-3
  // Teams tab is at index 2; Settings moves to index 3.
  // Customers never see this list — role is read from ShellController.
  static const _contractorTabs = [
    (Icons.home_outlined,        Icons.home_rounded,       'Home'),
    (Icons.folder_open_outlined, Icons.folder_rounded,     'Projects'),
    (Icons.groups_outlined,      Icons.groups_rounded,     'Teams'),
    (Icons.settings_outlined,    Icons.settings_rounded,   'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kBg,
        border: Border(top: BorderSide(color: _kBorder, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Obx(() {
            final tabs = controller.isDeveloper
                ? _contractorTabs
                : _customerTabs;
            return Row(
              children: List.generate(tabs.length, (i) {
                final (icon, activeIcon, label) = tabs[i];
                return _NavItem(
                  icon: icon,
                  activeIcon: activeIcon,
                  label: label,
                  index: i,
                  currentIndex: controller.currentIndex.value,
                  onTap: () => controller.changeTab(i),
                );
              }),
            );
          }),
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
      // Fix 1: Semantics so screen readers announce tab name and selected state
      child: Semantics(
        label: label,
        button: true,
        selected: isActive,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact(); // POLISH 4
            onTap();
          },
          behavior: HitTestBehavior.opaque,
          // ExcludeSemantics: icon + text are announced via parent Semantics
          child: ExcludeSemantics(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: Tween<double>(begin: 0.75, end: 1.0).animate(
                          CurvedAnimation(
                              parent: anim, curve: Curves.easeOutBack)),
                      child: child,
                    ),
                    child: Icon(
                      isActive ? activeIcon : icon,
                      key: ValueKey(isActive),
                      size: 24,
                      color: isActive ? _kActive : _kInactive,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? _kActive : _kInactive,
                    ),
                    child: Text(label),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 16 : 0,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isActive ? _kActive : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
