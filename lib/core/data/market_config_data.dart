/// All market/country configuration data for the BuildOS market selector.
/// Values are mock/indicative — for MVP demo only.
library market_config_data;

// ── Material price entry ──────────────────────────────────────────────────────

class MarketMaterial {
  final String name;
  final double price;
  final String unit;
  final double changeToday;
  const MarketMaterial({
    required this.name,
    required this.price,
    required this.unit,
    this.changeToday = 0,
  });
}

// ── Construction cost rate entry (cost per sq m in local currency) ─────────────

class MarketRates {
  final double economy;
  final double standard;
  final double premium;
  final double luxury;
  const MarketRates({
    required this.economy,
    required this.standard,
    required this.premium,
    required this.luxury,
  });
}

// ── Area unit group ───────────────────────────────────────────────────────────

/// Which area units to show as primary options.
enum AreaUnitGroup {
  marlaAndSqft,   // Pakistan, India, Bangladesh, Sri Lanka
  sqm,            // Gulf, Europe
  sqmAndSqft,     // SE Asia
}

// ── Work week ─────────────────────────────────────────────────────────────────

enum WorkWeek {
  satThu,   // Pakistan, Bangladesh
  sunThu,   // Gulf (Saudi, UAE, Qatar, Kuwait, Bahrain, Oman)
  monFri,   // Europe, SE Asia, India, Sri Lanka
}

// ── Market info ───────────────────────────────────────────────────────────────

class MarketInfo {
  final String code;           // ISO 3166-1 alpha-2
  final String name;
  final String flag;           // emoji
  final String currency;       // ISO 4217
  final String currencySymbol; // short symbol for display
  final String region;
  final AreaUnitGroup areaUnitGroup;
  final WorkWeek workWeek;
  final bool isArabicMarket;
  final List<MarketMaterial> materials;
  final MarketRates rates;     // cost per sq metre in local currency
  final String inputUnitLabel; // label shown in Quick Estimator

  const MarketInfo({
    required this.code,
    required this.name,
    required this.flag,
    required this.currency,
    required this.currencySymbol,
    required this.region,
    required this.areaUnitGroup,
    required this.workWeek,
    this.isArabicMarket = false,
    required this.materials,
    required this.rates,
    required this.inputUnitLabel,
  });
}

// ── Region constants ──────────────────────────────────────────────────────────

const String kRegionSouthAsia   = 'South Asia';
const String kRegionGulf        = 'Gulf & Middle East';
const String kRegionEurope      = 'Europe';
const String kRegionSEAsia      = 'Southeast Asia';
const String kRegionOther       = 'Other';

// ── Full market list ──────────────────────────────────────────────────────────

const List<MarketInfo> kAllMarkets = [

  // ── South Asia ──────────────────────────────────────────────────────────────

  MarketInfo(
    code: 'PK', name: 'Pakistan', flag: '🇵🇰',
    currency: 'PKR', currencySymbol: 'Rs',
    region: kRegionSouthAsia,
    areaUnitGroup: AreaUnitGroup.marlaAndSqft,
    workWeek: WorkWeek.satThu,
    inputUnitLabel: 'Marla',
    materials: [
      MarketMaterial(name: 'Steel',   price: 262,   unit: '/kg',    changeToday: 4),
      MarketMaterial(name: 'Cement',  price: 1280,  unit: '/bag',   changeToday: -20),
      MarketMaterial(name: 'Sand',    price: 55,    unit: '/cft',   changeToday: 0),
      MarketMaterial(name: 'Bricks',  price: 18500, unit: '/1000',  changeToday: 500),
    ],
    // Per sq metre in PKR (Pakistan std = 272.25 sqft/marla)
    rates: MarketRates(economy: 15000, standard: 24000, premium: 37000, luxury: 62000),
  ),

  MarketInfo(
    code: 'IN', name: 'India', flag: '🇮🇳',
    currency: 'INR', currencySymbol: '₹',
    region: kRegionSouthAsia,
    areaUnitGroup: AreaUnitGroup.marlaAndSqft,
    workWeek: WorkWeek.monFri,
    inputUnitLabel: 'Sq Ft',
    materials: [
      MarketMaterial(name: 'Steel',   price: 55,   unit: '/kg',    changeToday: 1),
      MarketMaterial(name: 'Cement',  price: 380,  unit: '/bag',   changeToday: -5),
      MarketMaterial(name: 'Sand',    price: 40,   unit: '/cft',   changeToday: 0),
      MarketMaterial(name: 'Bricks',  price: 7000, unit: '/1000',  changeToday: 200),
    ],
    rates: MarketRates(economy: 14000, standard: 22000, premium: 38000, luxury: 65000),
  ),

  MarketInfo(
    code: 'BD', name: 'Bangladesh', flag: '🇧🇩',
    currency: 'BDT', currencySymbol: '৳',
    region: kRegionSouthAsia,
    areaUnitGroup: AreaUnitGroup.marlaAndSqft,
    workWeek: WorkWeek.satThu,
    inputUnitLabel: 'Sq Ft',
    materials: [
      MarketMaterial(name: 'Steel',   price: 70,   unit: '/kg',    changeToday: 2),
      MarketMaterial(name: 'Cement',  price: 450,  unit: '/bag',   changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 800,  unit: '/m³',    changeToday: 0),
      MarketMaterial(name: 'Bricks',  price: 9500, unit: '/1000',  changeToday: 100),
    ],
    rates: MarketRates(economy: 16000, standard: 25000, premium: 42000, luxury: 70000),
  ),

  MarketInfo(
    code: 'LK', name: 'Sri Lanka', flag: '🇱🇰',
    currency: 'LKR', currencySymbol: 'Rs',
    region: kRegionSouthAsia,
    areaUnitGroup: AreaUnitGroup.sqmAndSqft,
    workWeek: WorkWeek.monFri,
    inputUnitLabel: 'Sq Ft',
    materials: [
      MarketMaterial(name: 'Steel',   price: 210,   unit: '/kg',   changeToday: 5),
      MarketMaterial(name: 'Cement',  price: 1100,  unit: '/bag',  changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 4500,  unit: '/m³',   changeToday: 0),
      MarketMaterial(name: 'Bricks',  price: 28000, unit: '/1000', changeToday: 0),
    ],
    rates: MarketRates(economy: 40000, standard: 65000, premium: 105000, luxury: 175000),
  ),

  // ── Gulf & Middle East ──────────────────────────────────────────────────────

  MarketInfo(
    code: 'SA', name: 'Saudi Arabia', flag: '🇸🇦',
    currency: 'SAR', currencySymbol: 'SAR',
    region: kRegionGulf,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.sunThu,
    isArabicMarket: true,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 2800, unit: '/tonne',  changeToday: 50),
      MarketMaterial(name: 'Cement',  price: 18,   unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 45,   unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 1.5,  unit: '/block',  changeToday: 0),
    ],
    rates: MarketRates(economy: 1500, standard: 2500, premium: 4000, luxury: 7000),
  ),

  MarketInfo(
    code: 'AE', name: 'UAE', flag: '🇦🇪',
    currency: 'AED', currencySymbol: 'AED',
    region: kRegionGulf,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.monFri,
    isArabicMarket: true,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 2600, unit: '/tonne',  changeToday: -30),
      MarketMaterial(name: 'Cement',  price: 22,   unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 50,   unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 2.0,  unit: '/block',  changeToday: 0.1),
    ],
    rates: MarketRates(economy: 1200, standard: 2000, premium: 3200, luxury: 5500),
  ),

  MarketInfo(
    code: 'QA', name: 'Qatar', flag: '🇶🇦',
    currency: 'QAR', currencySymbol: 'QAR',
    region: kRegionGulf,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.sunThu,
    isArabicMarket: true,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 2900, unit: '/tonne',  changeToday: 0),
      MarketMaterial(name: 'Cement',  price: 25,   unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 55,   unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 2.5,  unit: '/block',  changeToday: 0),
    ],
    rates: MarketRates(economy: 1600, standard: 2700, premium: 4300, luxury: 7500),
  ),

  MarketInfo(
    code: 'KW', name: 'Kuwait', flag: '🇰🇼',
    currency: 'KWD', currencySymbol: 'KD',
    region: kRegionGulf,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.sunThu,
    isArabicMarket: true,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 320,  unit: '/tonne',  changeToday: 0),
      MarketMaterial(name: 'Cement',  price: 2.5,  unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 6,    unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 0.30, unit: '/block',  changeToday: 0),
    ],
    rates: MarketRates(economy: 180, standard: 300, premium: 480, luxury: 800),
  ),

  MarketInfo(
    code: 'BH', name: 'Bahrain', flag: '🇧🇭',
    currency: 'BHD', currencySymbol: 'BD',
    region: kRegionGulf,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.sunThu,
    isArabicMarket: true,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 300,  unit: '/tonne',  changeToday: 0),
      MarketMaterial(name: 'Cement',  price: 2.2,  unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 5,    unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 0.28, unit: '/block',  changeToday: 0),
    ],
    rates: MarketRates(economy: 170, standard: 280, premium: 450, luxury: 750),
  ),

  MarketInfo(
    code: 'OM', name: 'Oman', flag: '🇴🇲',
    currency: 'OMR', currencySymbol: 'OMR',
    region: kRegionGulf,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.sunThu,
    isArabicMarket: true,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 290,  unit: '/tonne',  changeToday: 5),
      MarketMaterial(name: 'Cement',  price: 2.0,  unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 4,    unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 0.25, unit: '/block',  changeToday: 0),
    ],
    rates: MarketRates(economy: 160, standard: 260, premium: 420, luxury: 700),
  ),

  // ── Europe ──────────────────────────────────────────────────────────────────

  MarketInfo(
    code: 'GB', name: 'United Kingdom', flag: '🇬🇧',
    currency: 'GBP', currencySymbol: '£',
    region: kRegionEurope,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.monFri,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 1200, unit: '/tonne',  changeToday: -10),
      MarketMaterial(name: 'Cement',  price: 7.5,  unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 120,  unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 1.2,  unit: '/block',  changeToday: 0),
    ],
    rates: MarketRates(economy: 1400, standard: 2200, premium: 3500, luxury: 6000),
  ),

  MarketInfo(
    code: 'DE', name: 'Germany', flag: '🇩🇪',
    currency: 'EUR', currencySymbol: '€',
    region: kRegionEurope,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.monFri,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 1100, unit: '/tonne',  changeToday: 0),
      MarketMaterial(name: 'Cement',  price: 8.0,  unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 110,  unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 1.0,  unit: '/block',  changeToday: 0),
    ],
    rates: MarketRates(economy: 1200, standard: 1900, premium: 3000, luxury: 5200),
  ),

  MarketInfo(
    code: 'FR', name: 'France', flag: '🇫🇷',
    currency: 'EUR', currencySymbol: '€',
    region: kRegionEurope,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.monFri,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 1150, unit: '/tonne',  changeToday: 0),
      MarketMaterial(name: 'Cement',  price: 8.5,  unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 115,  unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 1.1,  unit: '/block',  changeToday: 0),
    ],
    rates: MarketRates(economy: 1300, standard: 2100, premium: 3300, luxury: 5500),
  ),

  MarketInfo(
    code: 'ES', name: 'Spain', flag: '🇪🇸',
    currency: 'EUR', currencySymbol: '€',
    region: kRegionEurope,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.monFri,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 1050, unit: '/tonne',  changeToday: 0),
      MarketMaterial(name: 'Cement',  price: 7.0,  unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 95,   unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 0.9,  unit: '/block',  changeToday: 0),
    ],
    rates: MarketRates(economy: 1000, standard: 1700, premium: 2700, luxury: 4600),
  ),

  MarketInfo(
    code: 'IT', name: 'Italy', flag: '🇮🇹',
    currency: 'EUR', currencySymbol: '€',
    region: kRegionEurope,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.monFri,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 1080, unit: '/tonne',  changeToday: 0),
      MarketMaterial(name: 'Cement',  price: 7.2,  unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 100,  unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 0.95, unit: '/block',  changeToday: 0),
    ],
    rates: MarketRates(economy: 1100, standard: 1800, premium: 2900, luxury: 4900),
  ),

  MarketInfo(
    code: 'NL', name: 'Netherlands', flag: '🇳🇱',
    currency: 'EUR', currencySymbol: '€',
    region: kRegionEurope,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.monFri,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 1180, unit: '/tonne',  changeToday: 0),
      MarketMaterial(name: 'Cement',  price: 9.0,  unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 130,  unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 1.3,  unit: '/block',  changeToday: 0),
    ],
    rates: MarketRates(economy: 1500, standard: 2400, premium: 3800, luxury: 6500),
  ),

  // ── Southeast Asia ───────────────────────────────────────────────────────────

  MarketInfo(
    code: 'ID', name: 'Indonesia', flag: '🇮🇩',
    currency: 'IDR', currencySymbol: 'Rp',
    region: kRegionSEAsia,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.monFri,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 14000000, unit: '/tonne', changeToday: 50000),
      MarketMaterial(name: 'Cement',  price: 58000,    unit: '/bag',   changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 350000,   unit: '/m³',    changeToday: 0),
      MarketMaterial(name: 'Bricks',  price: 900000,   unit: '/1000',  changeToday: 0),
    ],
    rates: MarketRates(economy: 4500000, standard: 7000000, premium: 11000000, luxury: 18000000),
  ),

  MarketInfo(
    code: 'PH', name: 'Philippines', flag: '🇵🇭',
    currency: 'PHP', currencySymbol: '₱',
    region: kRegionSEAsia,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.monFri,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 52000, unit: '/tonne',  changeToday: 200),
      MarketMaterial(name: 'Cement',  price: 285,   unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 1800,  unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 18,    unit: '/block',  changeToday: 0),
    ],
    rates: MarketRates(economy: 22000, standard: 35000, premium: 55000, luxury: 95000),
  ),

  MarketInfo(
    code: 'VN', name: 'Vietnam', flag: '🇻🇳',
    currency: 'VND', currencySymbol: '₫',
    region: kRegionSEAsia,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.monFri,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 17000000, unit: '/tonne', changeToday: 0),
      MarketMaterial(name: 'Cement',  price: 95000,    unit: '/bag',   changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 280000,   unit: '/m³',    changeToday: 0),
      MarketMaterial(name: 'Bricks',  price: 2800000,  unit: '/1000',  changeToday: 0),
    ],
    rates: MarketRates(economy: 6000000, standard: 10000000, premium: 16000000, luxury: 28000000),
  ),

  MarketInfo(
    code: 'MY', name: 'Malaysia', flag: '🇲🇾',
    currency: 'MYR', currencySymbol: 'RM',
    region: kRegionSEAsia,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.monFri,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 2900, unit: '/tonne',  changeToday: 0),
      MarketMaterial(name: 'Cement',  price: 18,   unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 45,   unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 1.2,  unit: '/block',  changeToday: 0),
    ],
    rates: MarketRates(economy: 1200, standard: 2000, premium: 3200, luxury: 5500),
  ),

  // ── Other ────────────────────────────────────────────────────────────────────

  MarketInfo(
    code: 'XX', name: 'Custom / Other', flag: '🌐',
    currency: 'USD', currencySymbol: '\$',
    region: kRegionOther,
    areaUnitGroup: AreaUnitGroup.sqm,
    workWeek: WorkWeek.monFri,
    inputUnitLabel: 'Sq m',
    materials: [
      MarketMaterial(name: 'Steel',   price: 1000, unit: '/tonne',  changeToday: 0),
      MarketMaterial(name: 'Cement',  price: 12,   unit: '/bag',    changeToday: 0),
      MarketMaterial(name: 'Sand',    price: 80,   unit: '/m³',     changeToday: 0),
      MarketMaterial(name: 'Blocks',  price: 0.8,  unit: '/block',  changeToday: 0),
    ],
    rates: MarketRates(economy: 800, standard: 1300, premium: 2200, luxury: 3800),
  ),
];

// ── Lookup helpers ────────────────────────────────────────────────────────────

MarketInfo marketByCode(String code) {
  try {
    return kAllMarkets.firstWhere((m) => m.code == code);
  } catch (_) {
    return kAllMarkets.first; // default to Pakistan
  }
}

/// Region order for display
const List<String> kRegionOrder = [
  kRegionSouthAsia,
  kRegionGulf,
  kRegionEurope,
  kRegionSEAsia,
  kRegionOther,
];

Map<String, List<MarketInfo>> get marketsByRegion {
  final Map<String, List<MarketInfo>> out = {};
  for (final r in kRegionOrder) {
    out[r] = kAllMarkets.where((m) => m.region == r).toList();
  }
  return out;
}
