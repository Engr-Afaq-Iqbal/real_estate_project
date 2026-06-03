class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.buildos.pk/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String loginOtp = '/auth/login/otp';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';

  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String verifyPhone = '/user/verify/phone';
  static const String verifyEmail = '/user/verify/email';
  static const String verifyCnic = '/user/verify/cnic';

  // Project endpoints
  static const String projects = '/projects';
  static const String projectById = '/projects/{id}';
  static const String createProject = '/projects/create';
  static const String updateProject = '/projects/{id}/update';
  static const String deleteProject = '/projects/{id}';
  static const String projectStages = '/projects/{id}/stages';
  static const String updateStage = '/projects/{id}/stages/{stageId}';
  static const String projectHandover = '/projects/{id}/handover';

  // Budget endpoints
  static const String budget = '/projects/{id}/budget';
  static const String expenses = '/projects/{id}/expenses';
  static const String createExpense = '/projects/{id}/expenses/create';
  static const String updateExpense = '/projects/{id}/expenses/{expenseId}';

  // Labor endpoints
  static const String workers = '/projects/{id}/workers';
  static const String attendance = '/projects/{id}/attendance';
  static const String submitAttendance = '/projects/{id}/attendance/submit';

  // Updates endpoints
  static const String updates = '/projects/{id}/updates';
  static const String createUpdate = '/projects/{id}/updates/create';
  static const String uploadMedia = '/media/upload';

  // Chat endpoints
  static const String conversations = '/chat/conversations';
  static const String messages = '/chat/{conversationId}/messages';
  static const String sendMessage = '/chat/{conversationId}/send';

  // Calculator endpoints
  static const String calculateCost = '/calculator/estimate';
  static const String savedCalculations = '/calculator/saved';
  static const String materialRates = '/calculator/rates';

  // Documents endpoints
  static const String documents = '/projects/{id}/documents';
  static const String uploadDocument = '/projects/{id}/documents/upload';

  // Notifications endpoints
  static const String notifications = '/notifications';
  static const String markRead = '/notifications/{id}/read';
  static const String markAllRead = '/notifications/read-all';

  // Developer specific
  static const String bids = '/developer/bids';
  static const String revenue = '/developer/revenue';
}
