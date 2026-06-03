class StorageKeys {
  StorageKeys._();

  // Auth
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String isLoggedIn = 'is_logged_in';
  static const String isOnboarded = 'is_onboarded';

  // User preferences
  static const String themeMode = 'theme_mode';
  static const String appLanguage = 'app_language';
  static const String themeColor = 'theme_color';
  static const String defaultCurrency = 'default_currency';
  static const String measurementUnit = 'measurement_unit';
  static const String notificationsEnabled = 'notifications_enabled';

  // Cache
  static const String cachedProjects = 'cached_projects';
  static const String cachedUserProfile = 'cached_user_profile';
  static const String lastSyncTime = 'last_sync_time';
  static const String fcmToken = 'fcm_token';
}
