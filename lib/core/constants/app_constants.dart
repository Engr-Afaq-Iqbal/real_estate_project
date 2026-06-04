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
  static const Duration shortAnimation  = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation   = Duration(milliseconds: 500);

  // ── Currency & locale ──────────────────────────────────────────────────────
  static const String defaultCurrency = 'PKR';
  static const String defaultLocale   = 'en_PK';

  // ── Project types ──────────────────────────────────────────────────────────
  static const List<String> projectTypes = [
    'house', 'villa', 'apartment', 'commercial', 'shop', 'office',
    'renovation', 'grey_structure', 'interior', 'boundary_wall',
    'kitchen', 'bathroom', 'extension', 'landscaping', 'custom',
  ];

  // ── Quality tiers ──────────────────────────────────────────────────────────
  static const List<String> qualityTiers = [
    'economy', 'standard', 'premium', 'luxury',
  ];

  // ── Area units ────────────────────────────────────────────────────────────
  static const List<String> areaUnits = [
    'marla', 'kanal', 'sqft', 'sqyd', 'sqm', 'acre', 'hectare',
  ];

  // Area units for display (backward compat)
  static const List<String> areaUnitLabels = [
    'Marla', 'Kanal', 'Sq.ft', 'Sq.yd', 'Sq.m', 'Acre', 'Hectare',
  ];

  // ── Pakistan cities (legacy — use GeographyService for full list) ──────────
  static const List<String> pakistanCities = [
    'Lahore', 'Karachi', 'Islamabad', 'Rawalpindi', 'Faisalabad',
    'Multan', 'Peshawar', 'Quetta', 'Sialkot', 'Gujranwala',
    'Hyderabad', 'Bahawalpur',
  ];

  // ── Construction stages (legacy — TimelineEngine generates dynamic stages) ──
  static const List<String> constructionStages = [
    'Design & Approvals',
    'Site Preparation',
    'Excavation',
    'Foundation',
    'Plinth Beam',
    'Ground Floor Structure',
    'First Floor Structure',
    'Roof Slab',
    'Brick / Block Work',
    'Plumbing Rough-In',
    'Electrical Rough-In',
    'Plaster & Waterproofing',
    'Flooring',
    'Ceiling Work',
    'Doors & Windows',
    'Paint',
    'Kitchen & Fixtures',
    'Final Inspection & Handover',
  ];

  // ── Work week definition (Pakistan: Sat–Thu) ──────────────────────────────
  static const int workWeekStartDay = 6; // Saturday (DateTime.saturday = 6)
  static const int workWeekEndDay   = 4; // Thursday (DateTime.thursday = 4)
  static const int workDaysPerWeek  = 6;
  static const int restDay          = 5; // Friday (DateTime.friday = 5)

  // ── Contractor types ──────────────────────────────────────────────────────
  static const List<String> contractorTypes = ['self', 'local', 'company'];

  // ── User roles ────────────────────────────────────────────────────────────
  static const String roleHomeowner  = 'homeowner';
  static const String roleDeveloper  = 'developer';
  static const String roleSupervisor = 'supervisor';
  static const String roleContractor = 'contractor';
  static const String roleInvestor   = 'investor';

  // ── Budget contingency default ────────────────────────────────────────────
  static const double defaultContingencyPct = 10.0;

  // ── Cache durations ────────────────────────────────────────────────────────
  static const Duration pricesCacheDuration    = Duration(hours: 6);
  static const Duration geographyCacheDuration = Duration(hours: 24);
}
