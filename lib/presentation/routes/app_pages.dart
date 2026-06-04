import 'package:get/get.dart';
import 'app_routes.dart';

// Onboarding
import '../../features/onboarding/bindings/onboarding_binding.dart';
import '../../features/onboarding/views/splash_screen.dart';
import '../../features/onboarding/views/role_selection_screen.dart';

// Auth
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/login_screen.dart';

// Main Shell
import '../../features/shell/bindings/shell_binding.dart';
import '../../features/shell/views/main_shell.dart';

// Dashboard
import '../../features/dashboard/bindings/dashboard_binding.dart';
import '../../features/dashboard/views/homeowner_dashboard_screen.dart';
import '../../features/dashboard/views/developer_dashboard_screen.dart';

// Projects
import '../../features/projects/bindings/projects_binding.dart';
import '../../features/projects/views/my_projects_screen.dart';
import '../../features/projects/views/new_project_wizard_screen.dart';
import '../../features/projects/views/project_stage_tracker_screen.dart';
import '../../features/projects/views/stage_detail_screen.dart';
import '../../features/projects/views/project_handover_screen.dart';

// Updates
import '../../features/updates/bindings/updates_binding.dart';
import '../../features/updates/views/photo_video_feed_screen.dart';

// Chat
import '../../features/chat/bindings/chat_binding.dart';
import '../../features/chat/views/chat_screen.dart';

// Budget
import '../../features/budget/bindings/budget_binding.dart';
import '../../features/budget/views/budget_tracker_screen.dart';
import '../../features/budget/views/log_expense_sheet.dart';

// Labor
import '../../features/labor/bindings/labor_binding.dart';
import '../../features/labor/views/labor_list_screen.dart';
import '../../features/labor/views/labor_attendance_screen.dart';
import '../../features/labor/views/payroll_screen.dart';

// Calculator
import '../../features/calculator/bindings/calculator_binding.dart';
import '../../features/calculator/views/calculator_hub_screen.dart';
import '../../features/calculator/views/calculator_form_screen.dart';
import '../../features/calculator/views/saved_calculations_screen.dart';
import '../../features/calculator/views/material_calculator_screen.dart';
import '../../features/calculator/views/house_estimator_screen.dart';
import '../../features/calculator/views/what_if_screen.dart';

// Documents
import '../../features/documents/bindings/documents_binding.dart';
import '../../features/documents/views/documents_vault_screen.dart';

// Notifications
import '../../features/notifications/bindings/notifications_binding.dart';
import '../../features/notifications/views/notifications_screen.dart';

// Settings
import '../../features/settings/bindings/settings_binding.dart';
import '../../features/settings/views/settings_screen.dart';

// Profile
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/views/profile_screen.dart';

class AppPages {
  static final pages = [
    // ── Onboarding ──────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionScreen(),
      binding: OnboardingBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Auth ────────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Main shell ──────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.main,
      page: () => const MainShell(),
      binding: ShellBinding(),
      transition: Transition.fadeIn,
    ),

    // ── Dashboard ───────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.homeownerDashboard,
      page: () => const HomeownerDashboardScreen(),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.developerDashboard,
      page: () => const DeveloperDashboardScreen(),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
    ),

    // ── Projects ────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.myProjects,
      page: () => const MyProjectsScreen(),
      binding: ProjectsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.newProjectWizard,
      page: () => const NewProjectWizardScreen(),
      binding: ProjectsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.projectStageTracker,
      page: () => const ProjectStageTrackerScreen(),
      binding: ProjectsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.stageDetail,
      page: () => const StageDetailScreen(),
      binding: ProjectsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.projectHandover,
      page: () => const ProjectHandoverScreen(),
      binding: ProjectsBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Updates ─────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.photoVideoFeed,
      page: () => const PhotoVideoFeedScreen(),
      binding: UpdatesBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Chat ────────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatScreen(),
      binding: ChatBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Budget ──────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.budgetTracker,
      page: () => const BudgetTrackerScreen(),
      binding: BudgetBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.logExpense,
      page: () => const LogExpenseSheet(),
      binding: BudgetBinding(),
      transition: Transition.downToUp,
    ),

    // ── Labor ───────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.laborList,
      page: () => const LaborListScreen(),
      binding: LaborBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.laborAttendance,
      page: () => const LaborAttendanceScreen(),
      binding: LaborBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.payroll,
      page: () => const PayrollScreen(),
      binding: LaborBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Calculator ──────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.calculatorHub,
      page: () => const CalculatorHubScreen(),
      binding: CalculatorBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.materialCalculator,
      page: () => const MaterialCalculatorScreen(),
      binding: CalculatorBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.houseEstimator,
      page: () => const HouseEstimatorScreen(),
      binding: CalculatorBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.whatIfCalculator,
      page: () => const WhatIfScreen(),
      binding: CalculatorBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.calculatorForm,
      page: () => const CalculatorFormScreen(),
      binding: CalculatorBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.savedCalculations,
      page: () => const SavedCalculationsScreen(),
      binding: CalculatorBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Documents ───────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.documentsVault,
      page: () => const DocumentsVaultScreen(),
      binding: DocumentsBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Notifications ───────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: NotificationsBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Settings ────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Profile ─────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
