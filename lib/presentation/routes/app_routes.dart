abstract class AppRoutes {
  // ── Onboarding ────────────────────────────────────────────────────────────
  static const splash = '/';
  static const roleSelection = '/role-selection';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otpVerification = '/otp-verification';

  // ── Main shell ────────────────────────────────────────────────────────────
  static const main = '/main';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const homeownerDashboard = '/dashboard/homeowner';
  static const developerDashboard = '/dashboard/developer';

  // ── Projects ──────────────────────────────────────────────────────────────
  static const myProjects = '/projects';
  static const newProjectWizard = '/projects/new';
  static const projectStageTracker = '/projects/stage-tracker';
  static const stageDetail = '/projects/stage-detail';
  static const projectHandover = '/projects/handover';

  // ── Updates & Communication ───────────────────────────────────────────────
  static const photoVideoFeed = '/updates/feed';
  static const chat = '/chat';
  static const chatConversations = '/chat/conversations';

  // ── Budget & Labor ────────────────────────────────────────────────────────
  static const budgetTracker = '/budget';
  static const logExpense = '/budget/log-expense';
  static const laborAttendance = '/labor/attendance';

  // ── Calculator ────────────────────────────────────────────────────────────
  static const calculatorHub = '/calculator';
  static const calculatorForm = '/calculator/form';
  static const savedCalculations = '/calculator/saved';

  // ── Documents ─────────────────────────────────────────────────────────────
  static const documentsVault = '/documents';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const notifications = '/notifications';

  // ── Settings & Profile ────────────────────────────────────────────────────
  static const settings = '/settings';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
}
