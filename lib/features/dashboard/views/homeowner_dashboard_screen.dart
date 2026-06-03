import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../projects/data/models/project_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/routes/app_routes.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF1B3A6B);
const _kAccent = Color(0xFF2563EB);
const _kBg = Color(0xFFF8F9FC);
const _kCardBg = Color(0xFFFFFFFF);
const _kTextPrimary = Color(0xFF1B3A6B);
const _kTextBody = Color(0xFF374151);
const _kTextMuted = Color(0xFF9CA3AF);
const _kTextSecondary = Color(0xFF6B7280);
const _kBorderLight = Color(0xFFE5E7EB);
const _kSeparator = Color(0xFFF0F2F5);
const _kSuccess = Color(0xFF16A34A);
const _kWarning = Color(0xFFF59E0B);
const _kError = Color(0xFFDC2626);

const _kCardShadow = BoxShadow(
  color: Color(0x12000000),
  blurRadius: 12,
  offset: Offset(0, 2),
);

class HomeownerDashboardScreen extends GetView<DashboardController> {
  const HomeownerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed white header
            _Header(auth: auth, controller: controller),
            // Scrollable body
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _kAccent,
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.loadDashboard,
                  color: _kAccent,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        if (controller.primaryProject != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _HeroCard(project: controller.primaryProject!),
                          ),
                        const SizedBox(height: 24),
                        _ProjectProgressSection(projects: controller.projects),
                        const SizedBox(height: 24),
                        const _AlertsSection(),
                        const SizedBox(height: 24),
                        const _QuickActionsSection(),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final AuthController auth;
  final DashboardController controller;

  const _Header({required this.auth, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Greeting
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${auth.greeting} ☀️',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _kTextMuted,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    auth.currentUser.value?.name.split(' ').first ?? 'Ahmed',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _kTextPrimary,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bell icon
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.notifications),
            child: Obx(
              () => Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _kSeparator,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color: _kTextBody,
                    ),
                  ),
                  if (controller.unreadNotifications.value > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _kError,
                          shape: BoxShape.circle,
                          border: Border.all(color: _kCardBg, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.profile),
            child: Obx(
              () => Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: _kPrimary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    auth.currentUser.value?.initials ?? 'AK',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero gradient card ────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final ProjectModel project;
  const _HeroCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.projectStageTracker, arguments: project),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kPrimary, _kAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 13, color: Colors.white70),
                const SizedBox(width: 3),
                Text(
                  '${project.area}, ${project.city}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Project name
            Text(
              project.name,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            // Stat pills
            Row(
              children: [
                _StatPill(
                  value: '${(project.progress * 100).toStringAsFixed(0)}%',
                  label: 'Done',
                ),
                const SizedBox(width: 10),
                _StatPill(
                  value: '${project.weeksLeft} wk',
                  label: 'Left',
                ),
                const SizedBox(width: 10),
                _StatPill(
                  value: CurrencyFormatter.formatLakh(project.spentBudget),
                  label: 'Spent',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: project.progress,
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Project progress section ───────────────────────────────────────────────────
class _ProjectProgressSection extends StatelessWidget {
  final List<ProjectModel> projects;
  const _ProjectProgressSection({required this.projects});

  @override
  Widget build(BuildContext context) {
    final project = projects.isNotEmpty ? projects.first : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Project Progress',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.myProjects),
                child: Text(
                  'View All →',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _kAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (project != null) _ProjectCard(project: project),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final statusLabel = project.statusLabel;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.projectStageTracker, arguments: project),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [_kCardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + name
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // House icon in colored box
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    size: 18,
                    color: _kAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${project.area}, ${project.city}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _kTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stage badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                project.currentStage.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD97706),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Progress bar + percentage
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: project.progress,
                      minHeight: 6,
                      backgroundColor: _kSeparator,
                      valueColor: const AlwaysStoppedAnimation<Color>(_kAccent),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(project.progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Last updated + status badge
            Row(
              children: [
                Text(
                  'Last updated ${_relativeTime(project.lastUpdated)}',
                  style: GoogleFonts.inter(fontSize: 11, color: _kTextMuted),
                ),
                const Spacer(),
                _StatusBadge(label: statusLabel),
              ],
            ),
            const SizedBox(height: 14),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _CardButton.outlined(
                    label: 'View Updates',
                    onTap: () => Get.toNamed(AppRoutes.photoVideoFeed),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CardButton.filled(
                    label: 'Full Report',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    if (label.startsWith('LATE')) {
      bg = const Color(0xFFFEF2F2);
      fg = _kError;
    } else if (label == 'AT RISK') {
      bg = const Color(0xFFFFFBEB);
      fg = _kWarning;
    } else {
      bg = const Color(0xFFF0FDF4);
      fg = _kSuccess;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool _filled;

  const _CardButton.outlined({required this.label, required this.onTap})
      : _filled = false;

  const _CardButton.filled({required this.label, required this.onTap})
      : _filled = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: _filled ? _kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: _filled ? null : Border.all(color: _kBorderLight),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _filled ? Colors.white : _kTextBody,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Alerts section ────────────────────────────────────────────────────────────
class _AlertsSection extends StatelessWidget {
  const _AlertsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Alerts",
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: _kCardBg,
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(color: _kWarning, width: 4),
              ),
              boxShadow: const [_kCardShadow],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: _kWarning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Alert: Steel cost 18% above average',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Lahore avg is PKR 285k/ton this week. Consider negotiating with vendor.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _kTextSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────
class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        label: 'Photos',
        icon: Icons.photo_camera_outlined,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: _kAccent,
        onTap: () => Get.toNamed(AppRoutes.photoVideoFeed),
      ),
      _ActionItem(
        label: 'Budget',
        icon: Icons.account_balance_wallet_outlined,
        iconBg: const Color(0xFFF0FDF4),
        iconColor: _kSuccess,
        onTap: () => Get.toNamed(AppRoutes.budgetTracker),
      ),
      _ActionItem(
        label: 'Reports',
        icon: Icons.bar_chart_rounded,
        iconBg: const Color(0xFFFFF7ED),
        iconColor: _kWarning,
        onTap: () {},
      ),
      _ActionItem(
        label: 'Schedule',
        icon: Icons.calendar_today_outlined,
        iconBg: const Color(0xFFFDF4FF),
        iconColor: const Color(0xFF7C3AED),
        onTap: () {},
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: actions.map((a) => _ActionCard(item: a)).toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionItem({
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;
  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [_kCardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 20, color: item.iconColor),
            ),
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kTextBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
