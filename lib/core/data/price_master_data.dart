/// Local seed prices for Pakistan — Lahore market (PKR, June 2026).
/// These are loaded when no API price data is available (offline / first run).
/// Admin updates these regularly via the backend; this is the offline fallback.
class PriceMasterData {
  PriceMasterData._();

  // ── Material category IDs ─────────────────────────────────────────────────
  static const int catCement     = 1;
  static const int catSteel      = 2;
  static const int catBricks     = 3;
  static const int catSand       = 4;
  static const int catCrush      = 5;
  static const int catTiles      = 6;
  static const int catPaint      = 7;
  static const int catPlumbing   = 8;
  static const int catElectrical = 9;
  static const int catTimber     = 10;
  static const int catCeiling    = 11;
  static const int catGlass      = 12;

  static const List<MaterialCategoryData> categories = [
    MaterialCategoryData(id: catCement,     name: 'Cement',     nameUr: 'سیمنٹ',      icon: 'cement',     defaultUnit: 'bag',   defaultUnitLabel: '50kg bag'),
    MaterialCategoryData(id: catSteel,      name: 'Steel',      nameUr: 'سریا',        icon: 'steel',      defaultUnit: 'kg',    defaultUnitLabel: 'per kg'),
    MaterialCategoryData(id: catBricks,     name: 'Bricks',     nameUr: 'اینٹ',        icon: 'brick',      defaultUnit: 'piece', defaultUnitLabel: 'per 1000'),
    MaterialCategoryData(id: catSand,       name: 'Sand',       nameUr: 'ریت',         icon: 'sand',       defaultUnit: 'cft',   defaultUnitLabel: 'per cft'),
    MaterialCategoryData(id: catCrush,      name: 'Crush/Gravel', nameUr: 'بجری',     icon: 'crush',      defaultUnit: 'cft',   defaultUnitLabel: 'per cft'),
    MaterialCategoryData(id: catTiles,      name: 'Tiles',      nameUr: 'ٹائل',        icon: 'tile',       defaultUnit: 'sqft',  defaultUnitLabel: 'per sqft'),
    MaterialCategoryData(id: catPaint,      name: 'Paint',      nameUr: 'پینٹ',        icon: 'paint',      defaultUnit: 'liter', defaultUnitLabel: 'per liter'),
    MaterialCategoryData(id: catPlumbing,   name: 'Plumbing',   nameUr: 'پلمبنگ',     icon: 'plumbing',   defaultUnit: 'piece', defaultUnitLabel: 'per piece'),
    MaterialCategoryData(id: catElectrical, name: 'Electrical', nameUr: 'الیکٹریکل',  icon: 'electrical', defaultUnit: 'piece', defaultUnitLabel: 'per piece'),
    MaterialCategoryData(id: catTimber,     name: 'Timber',     nameUr: 'لکڑی',        icon: 'timber',     defaultUnit: 'cft',   defaultUnitLabel: 'per cft'),
    MaterialCategoryData(id: catCeiling,    name: 'Ceiling',    nameUr: 'چھت',         icon: 'ceiling',    defaultUnit: 'sqft',  defaultUnitLabel: 'per sqft'),
    MaterialCategoryData(id: catGlass,      name: 'Glass',      nameUr: 'شیشہ',        icon: 'glass',      defaultUnit: 'sqft',  defaultUnitLabel: 'per sqft'),
  ];

  /// Prices: city_id → material_id → price (PKR)
  /// City 101 = Lahore (primary market)
  static const Map<int, Map<int, MaterialPriceData>> pricesByCityAndMaterial = {
    101: { // Lahore
      // Cement
      1001: MaterialPriceData(materialId: 1001, name: 'DG Khan Cement',    categoryId: catCement,  unit: 'bag',   price: 1280, currency: 'PKR'),
      1002: MaterialPriceData(materialId: 1002, name: 'Lucky Cement',      categoryId: catCement,  unit: 'bag',   price: 1300, currency: 'PKR'),
      1003: MaterialPriceData(materialId: 1003, name: 'Bestway Cement',    categoryId: catCement,  unit: 'bag',   price: 1290, currency: 'PKR'),
      1004: MaterialPriceData(materialId: 1004, name: 'Fauji Cement',      categoryId: catCement,  unit: 'bag',   price: 1270, currency: 'PKR'),
      // Steel
      2001: MaterialPriceData(materialId: 2001, name: 'Amreli Steel (Grade 60)',  categoryId: catSteel, unit: 'kg', price: 262, currency: 'PKR'),
      2002: MaterialPriceData(materialId: 2002, name: 'Agha Steel (Grade 60)',    categoryId: catSteel, unit: 'kg', price: 258, currency: 'PKR'),
      2003: MaterialPriceData(materialId: 2003, name: 'Ittefaq Steel (Grade 40)', categoryId: catSteel, unit: 'kg', price: 245, currency: 'PKR'),
      // Bricks (per 1000 pieces)
      3001: MaterialPriceData(materialId: 3001, name: 'Standard Red Brick (Class A)',  categoryId: catBricks, unit: 'thousand', price: 18500, currency: 'PKR'),
      3002: MaterialPriceData(materialId: 3002, name: 'Standard Red Brick (Class B)',  categoryId: catBricks, unit: 'thousand', price: 16000, currency: 'PKR'),
      3003: MaterialPriceData(materialId: 3003, name: 'Concrete Block (6")',           categoryId: catBricks, unit: 'piece',    price: 65,    currency: 'PKR'),
      3004: MaterialPriceData(materialId: 3004, name: 'Concrete Block (4")',           categoryId: catBricks, unit: 'piece',    price: 50,    currency: 'PKR'),
      // Sand (per cft)
      4001: MaterialPriceData(materialId: 4001, name: 'Plaster Sand',  categoryId: catSand,  unit: 'cft', price: 55,  currency: 'PKR'),
      4002: MaterialPriceData(materialId: 4002, name: 'Filling Sand',  categoryId: catSand,  unit: 'cft', price: 38,  currency: 'PKR'),
      4003: MaterialPriceData(materialId: 4003, name: 'River Sand',    categoryId: catSand,  unit: 'cft', price: 70,  currency: 'PKR'),
      // Crush/Gravel (per cft)
      5001: MaterialPriceData(materialId: 5001, name: 'Crush (3/4")',  categoryId: catCrush, unit: 'cft', price: 65,  currency: 'PKR'),
      5002: MaterialPriceData(materialId: 5002, name: 'Crush (1/2")',  categoryId: catCrush, unit: 'cft', price: 70,  currency: 'PKR'),
      5003: MaterialPriceData(materialId: 5003, name: 'Stone Chips',   categoryId: catCrush, unit: 'cft', price: 80,  currency: 'PKR'),
      // Tiles (per sqft — supply + installation)
      6001: MaterialPriceData(materialId: 6001, name: 'Porcelain Floor Tile (Economy)', categoryId: catTiles, unit: 'sqft', price: 140,  currency: 'PKR'),
      6002: MaterialPriceData(materialId: 6002, name: 'Porcelain Floor Tile (Mid)',     categoryId: catTiles, unit: 'sqft', price: 220,  currency: 'PKR'),
      6003: MaterialPriceData(materialId: 6003, name: 'Imported Tile (Premium)',        categoryId: catTiles, unit: 'sqft', price: 480,  currency: 'PKR'),
      6004: MaterialPriceData(materialId: 6004, name: 'Wall Tile (Standard)',           categoryId: catTiles, unit: 'sqft', price: 160,  currency: 'PKR'),
      // Paint (per liter)
      7001: MaterialPriceData(materialId: 7001, name: 'Dulux WeatherShield',     categoryId: catPaint, unit: 'liter', price: 950,  currency: 'PKR'),
      7002: MaterialPriceData(materialId: 7002, name: 'Berger Walpaint',         categoryId: catPaint, unit: 'liter', price: 720,  currency: 'PKR'),
      7003: MaterialPriceData(materialId: 7003, name: 'Nippon Paint (Standard)', categoryId: catPaint, unit: 'liter', price: 680,  currency: 'PKR'),
      7004: MaterialPriceData(materialId: 7004, name: 'Primer',                  categoryId: catPaint, unit: 'liter', price: 420,  currency: 'PKR'),
    },
    102: { // Karachi — approx 5-8% higher than Lahore for materials
      1001: MaterialPriceData(materialId: 1001, name: 'DG Khan Cement',    categoryId: catCement, unit: 'bag', price: 1340, currency: 'PKR'),
      1002: MaterialPriceData(materialId: 1002, name: 'Lucky Cement',      categoryId: catCement, unit: 'bag', price: 1360, currency: 'PKR'),
      2001: MaterialPriceData(materialId: 2001, name: 'Amreli Steel',      categoryId: catSteel,  unit: 'kg',  price: 268,  currency: 'PKR'),
      3001: MaterialPriceData(materialId: 3001, name: 'Red Brick Class A', categoryId: catBricks, unit: 'thousand', price: 19500, currency: 'PKR'),
    },
    103: { // Islamabad
      1001: MaterialPriceData(materialId: 1001, name: 'DG Khan Cement', categoryId: catCement, unit: 'bag', price: 1310, currency: 'PKR'),
      2001: MaterialPriceData(materialId: 2001, name: 'Amreli Steel',   categoryId: catSteel,  unit: 'kg',  price: 265,  currency: 'PKR'),
      3001: MaterialPriceData(materialId: 3001, name: 'Red Brick',      categoryId: catBricks, unit: 'thousand', price: 17000, currency: 'PKR'),
    },
  };

  /// Construction rate per sqft by quality tier — Pakistan (PKR, Lahore 2026)
  /// Component → quality_tier → rate_per_sqft
  static const Map<String, Map<String, double>> ratesPerSqft = {
    'foundation': {
      'economy': 180, 'standard': 250, 'premium': 380, 'luxury': 620,
    },
    'structure': {
      'economy': 580, 'standard': 800, 'premium': 1200, 'luxury': 2000,
    },
    'blockwork': {
      'economy': 75, 'standard': 110, 'premium': 160, 'luxury': 260,
    },
    'plaster': {
      'economy': 55, 'standard': 85, 'premium': 130, 'luxury': 200,
    },
    'flooring': {
      'economy': 90, 'standard': 170, 'premium': 340, 'luxury': 780,
    },
    'plumbing': {
      'economy': 75, 'standard': 120, 'premium': 190, 'luxury': 380,
    },
    'electrical': {
      'economy': 55, 'standard': 90, 'premium': 150, 'luxury': 300,
    },
    'paint': {
      'economy': 45, 'standard': 75, 'premium': 140, 'luxury': 280,
    },
    'doors_windows': {
      'economy': 70, 'standard': 140, 'premium': 270, 'luxury': 580,
    },
    'ceiling': {
      'economy': 0, 'standard': 50, 'premium': 130, 'luxury': 280,
    },
    'kitchen': {
      'economy': 80, 'standard': 140, 'premium': 300, 'luxury': 700,
    },
  };

  static String effectiveDate = '2026-06-01';
}

class MaterialCategoryData {
  final int id;
  final String name;
  final String nameUr;
  final String icon;
  final String defaultUnit;
  final String defaultUnitLabel;

  const MaterialCategoryData({
    required this.id,
    required this.name,
    required this.nameUr,
    required this.icon,
    required this.defaultUnit,
    required this.defaultUnitLabel,
  });
}

class MaterialPriceData {
  final int materialId;
  final String name;
  final int categoryId;
  final String unit;
  final double price;
  final String currency;

  const MaterialPriceData({
    required this.materialId,
    required this.name,
    required this.categoryId,
    required this.unit,
    required this.price,
    required this.currency,
  });
}
