import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../projects/data/models/project_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/routes/app_routes.dart';

// Semantic colours that never change with theme
const _kSuccess = Color(0xFF16A34A);
const _kWarning = Color(0xFFF59E0B);
const _kError   = Color(0xFFDC2626);

// Primary text: dark navy in light mode (readable on white), white in dark mode
Color _primaryText(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Theme.of(context).colorScheme.primary;

class HomeownerDashboardScreen extends GetView<DashboardController> {
  const HomeownerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final cs   = Theme.of(context).colorScheme;
    final bg   = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(auth: auth, controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: cs.primary),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.loadDashboard,
                  color: cs.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const _QuickActionsRow(),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _MarketPriceWidget(
                              controller: controller),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _CalculatorWidget(
                              controller: controller),
                        ),
                        const SizedBox(height: 20),
                        if (controller.primaryProject != null) ...[
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: _HeroCard(
                                project: controller.primaryProject!),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (controller.upcomingTasks.isNotEmpty) ...[
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: _UpcomingTasksSection(
                                controller: controller),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (controller.budgetAlerts.isNotEmpty) ...[
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: _BudgetAlertsSection(
                                controller: controller),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (controller.activeProjects.isNotEmpty) ...[
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: _ActiveProjectsSection(
                                controller: controller),
                          ),
                        ],
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
    final cs      = Theme.of(context).colorScheme;
    final surface = Theme.of(context).colorScheme.surface;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final divider = Theme.of(context).dividerColor;

    return Container(
      color: surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
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
                      auth.currentUser.value?.name.split(' ').first ?? 'Ahmed',
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          height: 1.1),
                    ),
                  ],
                )),
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
                            border: Border.all(color: surface, width: 1.5),
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
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _QuickAction(
            icon: Icons.add_circle_outline_rounded,
            label: 'New Project',
            color: Theme.of(context).colorScheme.primary,
            bg: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            onTap: () => Get.toNamed(AppRoutes.newProjectWizard),
          ),
          const SizedBox(width: 10),
          _QuickAction(
            icon: Icons.camera_alt_outlined,
            label: 'Add Update',
            color: _kSuccess,
            bg: _kSuccess.withValues(alpha: 0.1),
            onTap: () => Get.toNamed(AppRoutes.photoVideoFeed),
          ),
          const SizedBox(width: 10),
          _QuickAction(
            icon: Icons.calculate_outlined,
            label: 'Estimate',
            color: const Color(0xFF7C3AED),
            bg: const Color(0xFF7C3AED).withValues(alpha: 0.1),
            onTap: () => Get.toNamed(AppRoutes.houseEstimator),
          ),
          const SizedBox(width: 10),
          _QuickAction(
            icon: Icons.folder_open_outlined,
            label: 'Projects',
            color: _kWarning,
            bg: _kWarning.withValues(alpha: 0.1),
            onTap: () => Get.toNamed(AppRoutes.myProjects),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon, required this.label, required this.color,
    required this.bg, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () { HapticFeedback.lightImpact(); onTap(); },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 6),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w600, color: color),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Market Price Widget ───────────────────────────────────────────────────────

class _MarketPriceWidget extends StatelessWidget {
  final DashboardController controller;
  const _MarketPriceWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: cs.onSurface.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                    color: _kWarning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child:
                    const Icon(Icons.bar_chart_rounded, size: 16, color: _kWarning),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Market Prices Today',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface)),
              ),
              Text('Lahore · June 2026',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() {
            final prices = controller.marketPrices;
            if (prices.isEmpty) return const SizedBox.shrink();
            return Row(
              children: prices
                  .map((p) => Expanded(child: _PriceTile(price: p)))
                  .toList(),
            );
          }),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.materialCalculator),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Open Material Calculator →',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primaryText(context))),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceTile extends StatelessWidget {
  final MarketPrice price;
  const _PriceTile({required this.price});

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final color = price.isUp ? _kError : price.isDown ? _kSuccess : cs.onSurfaceVariant;
    final arrow = price.isUp ? '↑' : price.isDown ? '↓' : '→';

    return Column(
      children: [
        Text(price.material,
            style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text('${price.price.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface)),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(arrow,
                style: TextStyle(
                    fontSize: 10, color: color, fontWeight: FontWeight.w700)),
            const SizedBox(width: 1),
            Text(
              price.changeToday == 0
                  ? 'Stable'
                  : price.changeToday.abs().toStringAsFixed(0),
              style: GoogleFonts.inter(
                  fontSize: 9, color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Text(price.unit,
            style: GoogleFonts.inter(fontSize: 9, color: cs.onSurfaceVariant)),
      ],
    );
  }
}

// ── Calculator Widget ─────────────────────────────────────────────────────────

class _CalculatorWidget extends StatelessWidget {
  final DashboardController controller;
  const _CalculatorWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final expanded = controller.calcExpanded.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary,
              Color.lerp(cs.primary, Colors.blue, 0.3) ?? cs.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calculate_outlined,
                      size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Quick Estimator',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.toggleCalcWidget();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(expanded ? 'Close' : 'Calculate',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
            if (!expanded) ...[
              const SizedBox(height: 10),
              Text('Estimate any construction cost instantly.',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(height: 10),
              Row(
                children: [
                  _MiniPricePill('Steel', '262/kg'),
                  const SizedBox(width: 8),
                  _MiniPricePill('Cement', '1,280/bag'),
                  const SizedBox(width: 8),
                  _MiniPricePill('Sand', '55/cft'),
                ],
              ),
            ],
            if (expanded) ...[
              const SizedBox(height: 16),
              _CalcInputRow(
                label: 'Plot Size',
                hint: 'e.g. 5',
                suffix: 'Marla',
                onChanged: (v) {
                  controller.calcAreaCtrl.value = v;
                  controller.runQuickEstimate(v);
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Floors',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(width: 12),
                  ...List.generate(3, (i) {
                    final f = i + 1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          controller.calcFloors.value = f;
                          controller.runQuickEstimate(
                              controller.calcAreaCtrl.value);
                        },
                        child: Obx(() => Container(
                              width: 32, height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: controller.calcFloors.value == f
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('$f',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: controller.calcFloors.value == f
                                        ? cs.primary
                                        : Colors.white,
                                  )),
                            )),
                      ),
                    );
                  }),
                  const Spacer(),
                  Obx(() => GestureDetector(
                        onTap: () {
                          final tiers = ['economy', 'standard', 'premium'];
                          final idx = tiers.indexOf(
                              controller.calcQuality.value);
                          controller.calcQuality.value =
                              tiers[(idx + 1) % tiers.length];
                          controller.runQuickEstimate(
                              controller.calcAreaCtrl.value);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _qualityLabel(
                                    controller.calcQuality.value),
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.swap_horiz_rounded,
                                  size: 14, color: Colors.white70),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 14),
              Obx(() {
                final est = controller.quickEstimate.value;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: est != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estimated Cost',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.white
                                        .withValues(alpha: 0.7))),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.formatCompact(est),
                              style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white),
                            ),
                          ],
                        )
                      : Text('Enter plot size above to see estimate',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6))),
                );
              }),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.houseEstimator),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Full Estimate',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.newProjectWizard),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Create Project',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cs.primary)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  String _qualityLabel(String tier) => switch (tier) {
        'economy' => 'Economy',
        'premium' => 'Premium',
        _         => 'Standard',
      };
}

class _MiniPricePill extends StatelessWidget {
  final String label;
  final String value;
  const _MiniPricePill(this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('$label: $value',
            style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8))),
      );
}

class _CalcInputRow extends StatelessWidget {
  final String label;
  final String hint;
  final String suffix;
  final void Function(String) onChanged;
  const _CalcInputRow({
    required this.label, required this.hint,
    required this.suffix, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8))),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: onChanged,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.4)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Text(suffix,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero Card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final ProjectModel project;
  const _HeroCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Active Project',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface)),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.myProjects),
              child: Text('View All →',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _primaryText(context))),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.projectStageTracker,
              arguments: project),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary,
                  Color.lerp(cs.primary, Colors.blue, 0.3) ?? cs.primary,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: Colors.white70),
                    const SizedBox(width: 3),
                    Text('${project.area}, ${project.city}',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.7))),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(project.statusLabel,
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(project.name,
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2)),
                const SizedBox(height: 4),
                Text(project.currentStage.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _StatPill(
                        value: '${project.completionPct.toStringAsFixed(0)}%',
                        label: 'Done'),
                    const SizedBox(width: 8),
                    _StatPill(
                        value: '${project.weeksLeft} wk',
                        label: 'Left'),
                    const SizedBox(width: 8),
                    _StatPill(
                        value: CurrencyFormatter.formatLakh(
                            project.spentBudget),
                        label: 'Spent'),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: project.progress,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1)),
              const SizedBox(height: 1),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7))),
            ],
          ),
        ),
      );
}

// ── Upcoming Tasks ────────────────────────────────────────────────────────────

class _UpcomingTasksSection extends StatelessWidget {
  final DashboardController controller;
  const _UpcomingTasksSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text('Upcoming Tasks',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface)),
                  if (controller.overdueTaskCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _kError.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${controller.overdueTaskCount} overdue',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _kError),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...controller.upcomingTasks.map((t) => _TaskRow(task: t)),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  final UpcomingTask task;
  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final now     = DateTime.now();
    final daysLeft = task.dueDate.difference(now).inDays;
    final timeLabel = task.isOverdue
        ? '${(-daysLeft)} days overdue'
        : daysLeft == 0
            ? 'Due today'
            : 'Due in $daysLeft day${daysLeft == 1 ? '' : 's'}';

    final dotColor = task.isOverdue
        ? _kError
        : task.priority == 'high'
            ? _kWarning
            : cs.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: cs.onSurface.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
        border: task.isOverdue
            ? Border.all(color: _kError.withValues(alpha: 0.2))
            : null,
      ),
      child: Row(
        children: [
          Container(
              width: 8, height: 8,
              margin: const EdgeInsets.only(right: 10, top: 2),
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface)),
                const SizedBox(height: 2),
                Text('${task.projectName} · ${task.stageName}',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Text(timeLabel,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: task.isOverdue ? _kError : cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── Budget Alerts ─────────────────────────────────────────────────────────────

class _BudgetAlertsSection extends StatelessWidget {
  final DashboardController controller;
  const _BudgetAlertsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget Insights',
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: cs.onSurface)),
        const SizedBox(height: 10),
        ...controller.budgetAlerts.map((a) => _BudgetAlertRow(alert: a)),
      ],
    );
  }
}

class _BudgetAlertRow extends StatelessWidget {
  final BudgetAlert alert;
  const _BudgetAlertRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    final cs         = Theme.of(context).colorScheme;
    final isWarning  = alert.severity == 'warning';
    final barColor   = isWarning ? _kWarning : cs.primary;
    final bgColor    = barColor.withValues(alpha: 0.07);
    final borderCol  = barColor.withValues(alpha: 0.2);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isWarning
                    ? Icons.warning_amber_rounded
                    : Icons.trending_up_rounded,
                size: 14,
                color: barColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(alert.projectName,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface)),
              ),
              Text('${(alert.budgetPct * 100).toStringAsFixed(0)}% used',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: barColor)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: alert.budgetPct,
              minHeight: 4,
              backgroundColor: barColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(alert.message,
              style: GoogleFonts.inter(
                  fontSize: 11, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── Active Projects ───────────────────────────────────────────────────────────

class _ActiveProjectsSection extends StatelessWidget {
  final DashboardController controller;
  const _ActiveProjectsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('All Projects',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface)),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.myProjects),
              child: Text('View All →',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _primaryText(context))),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...controller.activeProjects
            .map((p) => _ProjectListTile(project: p)),
      ],
    );
  }
}

class _ProjectListTile extends StatelessWidget {
  final ProjectModel project;
  const _ProjectListTile({required this.project});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.projectStageTracker, arguments: project),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: cs.onSurface.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.home_outlined, size: 20, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.name,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface)),
                  const SizedBox(height: 2),
                  Text(
                    '${project.area}, ${project.city}  ·  ${project.currentStage}',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: project.progress,
                            minHeight: 4,
                            backgroundColor: divider,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(cs.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${project.completionPct.toStringAsFixed(0)}%',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

String _relativeTime(DateTime? dt) {
  if (dt == null) return 'recently';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24)   return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
