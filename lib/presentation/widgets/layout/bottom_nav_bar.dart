import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/shell/controllers/shell_controller.dart';

const _kNavAccent = Color(0xFF2563EB);
const _kNavMuted  = Color(0xFF9CA3AF);
const _kNavBg     = Color(0xFFFFFFFF);
const _kNavBorder = Color(0xFFF0F2F5);

// ── Tab definition ────────────────────────────────────────────────────────────

class _TabDef {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabDef(this.icon, this.activeIcon, this.label);
}

const _tabs = [
  _TabDef(Icons.home_outlined,              Icons.home_rounded,             'Home'),
  _TabDef(Icons.folder_open_outlined,       Icons.folder_rounded,           'Projects'),
  _TabDef(Icons.photo_library_outlined,     Icons.photo_library_rounded,    'Updates'),
  _TabDef(Icons.notifications_none_rounded, Icons.notifications_rounded,    'Alerts'),
  _TabDef(Icons.person_outline_rounded,     Icons.person_rounded,           'Profile'),
];

// ── Widget ────────────────────────────────────────────────────────────────────

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
              children: List.generate(
                _tabs.length,
                (i) => _NavItem(
                  def: _tabs[i],
                  index: i,
                  currentIndex: controller.currentIndex.value,
                  badgeCount: i == 3 ? controller.unreadNotifications.value : 0,
                  onTap: () => controller.changeTab(i),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Single nav item ───────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final _TabDef def;
  final int index;
  final int currentIndex;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.def,
    required this.index,
    required this.currentIndex,
    required this.badgeCount,
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
            // Icon + optional badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isActive ? def.activeIcon : def.icon,
                    key: ValueKey(isActive),
                    size: 22,
                    color: isActive ? _kNavAccent : _kNavMuted,
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 14,
                      height: 14,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              def.label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? _kNavAccent : _kNavMuted,
              ),
            ),
            const SizedBox(height: 4),
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
