abstract class AppRoutes {
  // ── Onboarding ────────────────────────────────────────────────────────────
  static const splash         = '/';
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

  // ── Calculator ────────────────────────────────────────────────────────────
  static const calculatorHub      = '/calculator';
  static const materialCalculator = '/calculator/material';
  static const houseEstimator     = '/calculator/house';
  static const whatIfCalculator   = '/calculator/what-if';
  static const calculatorForm     = '/calculator/form';        // legacy, keep
  static const savedCalculations  = '/calculator/saved';

  // ── Documents ─────────────────────────────────────────────────────────────
  static const documentsVault = '/documents';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const notifications = '/notifications';

  // ── Settings & Profile ────────────────────────────────────────────────────
  static const settings    = '/settings';
  static const profile     = '/profile';
  static const editProfile = '/profile/edit';
}
