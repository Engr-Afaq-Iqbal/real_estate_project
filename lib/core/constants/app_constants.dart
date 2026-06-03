class AppConstants {
  AppConstants._();

  static const String appName = 'BuildOS';
  static const String appTagline = 'Your Complete Construction Manager';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts (milliseconds)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Pakistan-specific
  static const String defaultCurrency = 'PKR';
  static const String defaultLocale = 'en_PK';
  static const List<String> pakistanCities = [
    'Lahore',
    'Karachi',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Multan',
    'Peshawar',
    'Quetta',
    'Sialkot',
    'Gujranwala',
    'Hyderabad',
    'Bahawalpur',
  ];

  // Construction stages
  static const List<String> constructionStages = [
    'Land & Registry',
    'Approvals & NOC',
    'Architecture & Drawings',
    'Foundation & Plinth',
    'Gray Structure',
    'Electrical & Plumbing',
    'Plastering & Waterproofing',
    'Finishing & Tiling',
    'Doors / Windows / Kitchen',
    'Handover',
  ];

  // Plot size units
  static const List<String> areaUnits = ['Marla', 'Kanal', 'Sq.ft', 'Sq.yd'];

  // Project types
  static const List<String> projectTypes = [
    'House',
    'Commercial',
    'Renovation',
    'Single Room',
  ];

  // User roles
  static const String roleHomeowner = 'homeowner';
  static const String roleDeveloper = 'developer';
}
