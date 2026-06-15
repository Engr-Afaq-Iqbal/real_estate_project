import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../presentation/widgets/common/error_state_widget.dart';
import '../widgets/dashboard_header_widget.dart';
import '../widgets/dashboard_quick_actions_widget.dart';
import '../widgets/dashboard_estimator_widget.dart';
import '../widgets/dashboard_todays_alert_widget.dart';
import '../widgets/dashboard_market_prices_widget.dart';
// Feature temporarily disabled. Quick Estimator widget preserved for future
// implementation (see dashboard_quick_stats_widget.dart).
// import '../widgets/dashboard_quick_stats_widget.dart';
// Active Project hero card removed from the Customer Dashboard.
// Widget preserved in dashboard_project_highlight_card.dart for future use.
// import '../widgets/dashboard_project_highlight_card.dart';
// Portfolio Overview moved to the Contractor Dashboard
// (developer_dashboard_screen.dart).
// import '../widgets/dashboard_portfolio_widget.dart';
import '../widgets/dashboard_recent_activity_widget.dart';

/// Homeowner dashboard — composes extracted sub-widgets.
/// Each sub-widget lives in lib/features/dashboard/widgets/ and owns
/// its own rendering logic, reducing this file from ~1 300 to ~80 lines.
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
            // ── Sticky header (greeting + bell + avatar) ──────────────────
            DashboardHeaderWidget(auth: auth, controller: controller),

            // ── Scrollable body ───────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: cs.primary),
                  );
                }
                if (controller.hasLoadError.value) {
                  return ErrorStateWidget(
                    onRetry: controller.loadDashboard,
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
                        // Today's Alert — directly below the header, before
                        // all other dashboard sections. Hidden when nothing
                        // is due today.
                        const DashboardTodaysAlertWidget(),
                        const SizedBox(height: 16),

                        // Quick action tiles
                        const DashboardQuickActionsWidget(),
                        const SizedBox(height: 20),

                        // Construction Cost Estimator (replaces the old
                        // "Estimate" quick action → CalculatorHubScreen flow)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: DashboardEstimatorWidget(),
                        ),
                        const SizedBox(height: 20),

                        // Market prices card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DashboardMarketPricesWidget(
                              controller: controller),
                        ),
                        const SizedBox(height: 20),

                        // Quick Estimator section removed.
                        // Feature temporarily disabled. Widget preserved for
                        // future implementation in
                        // dashboard_quick_stats_widget.dart.
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16),
                        //   child: DashboardQuickStatsWidget(
                        //       controller: controller),
                        // ),
                        // const SizedBox(height: 20),

                        // Active Project hero card removed from the Customer
                        // Dashboard. Preserved for future use.
                        // if (controller.primaryProject != null) ...[
                        //   Padding(
                        //     padding: const EdgeInsets.symmetric(horizontal: 16),
                        //     child: DashboardProjectHighlightCard(
                        //         project: controller.primaryProject!),
                        //   ),
                        //   const SizedBox(height: 20),
                        // ],

                        // Portfolio Overview moved to the Contractor
                        // Dashboard (developer_dashboard_screen.dart).
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16),
                        //   child: DashboardPortfolioWidget(
                        //       controller: controller),
                        // ),
                        // if (controller.activeProjects.length >= 2)
                        //   const SizedBox(height: 20),

                        // My Projects (kept as the final dashboard section)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DashboardRecentActivityWidget(
                              controller: controller),
                        ),
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
