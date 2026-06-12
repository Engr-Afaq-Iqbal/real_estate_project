abstract class AppRoutes {
  // ── Onboarding ────────────────────────────────────────────────────────────
  static const splash         = '/';
  static const onboarding     = '/onboarding';
  static const roleSelection  = '/role-selection';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const login            = '/login';
  static const register         = '/register';
  static const forgotPassword   = '/forgot-password';
  static const otpVerification  = '/otp-verification';

  // ── Main shell ────────────────────────────────────────────────────────────
  static const main = '/main';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const homeownerDashboard = '/dashboard/homeowner';
  static const developerDashboard = '/dashboard/developer';

  // ── Projects ──────────────────────────────────────────────────────────────
  static const myProjects         = '/projects';
  static const newProjectWizard   = '/projects/new';
  static const projectDashboard   = '/projects/dashboard';
  static const projectStageTracker = '/projects/stage-tracker';
  static const stageDetail        = '/projects/stage-detail';
  static const projectHandover    = '/projects/handover';
  static const projectReport      = '/projects/report';

  // ── Updates & Communication ───────────────────────────────────────────────
  static const photoVideoFeed    = '/updates/feed';
  static const chat              = '/chat';
  static const chatConversations = '/chat/conversations';

  // ── Budget ────────────────────────────────────────────────────────────────
  static const budgetTracker = '/budget';
  static const logExpense    = '/budget/log-expense';

  // ── Labor ─────────────────────────────────────────────────────────────────
  static const laborList        = '/labor';
  static const laborAttendance  = '/labor/attendance';
  static const payroll          = '/labor/payroll';

  // ── Market ────────────────────────────────────────────────────────────────
  static const marketPrices       = '/market/prices';

  // ── Calculator ────────────────────────────────────────────────────────────
  // Deprecated for current release — hub screen moved to the Home Dashboard
  // estimator section. Constant kept for future reactivation.
  static const calculatorHub         = '/calculator';
  static const materialCalculator    = '/calculator/material';
  // Feature temporarily disabled — Full Estimate screen preserved for future
  // implementation. Constant kept so commented references compile on restore.
  static const houseEstimator        = '/calculator/house';
  static const whatIfCalculator      = '/calculator/what-if';
  static const calculatorForm        = '/calculator/form';        // legacy, keep
  static const savedCalculations     = '/calculator/saved';
  static const areaEstimator         = '/calculator/area-estimator';
  static const materialCostCalc      = '/calculator/material-cost';
  static const floorPlanEstimator    = '/calculator/floor-plan-estimator';

  // ── Tasks ─────────────────────────────────────────────────────────────────
  static const tasks = '/tasks';

  // ── Documents ─────────────────────────────────────────────────────────────
  static const documentsVault = '/documents';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const notifications = '/notifications';

  // ── Settings & Profile ────────────────────────────────────────────────────
  static const settings        = '/settings';
  static const profile         = '/profile';
  static const editProfile     = '/profile/edit';
  static const profileDetails  = '/settings/profile-details';
}
