import 'package:get/get.dart';

// ── Material price entry (extended with history) ──────────────────────────────

class MaterialPriceEntry {
  final String id;
  final String name;
  final String nameUrdu;
  final String icon;
  final String category;
  final double previousPrice;
  final double currentPrice;
  final String unit;
  final List<double> priceHistory; // 7-day history, oldest first
  final String city;

  const MaterialPriceEntry({
    required this.id,
    required this.name,
    required this.nameUrdu,
    required this.icon,
    required this.category,
    required this.previousPrice,
    required this.currentPrice,
    required this.unit,
    required this.priceHistory,
    required this.city,
  });

  double get change => currentPrice - previousPrice;
  double get changePct =>
      previousPrice > 0 ? (change / previousPrice) * 100 : 0;
  bool get isUp => change > 0;
  bool get isDown => change < 0;
  bool get isStable => change == 0;

  String get changeLabel {
    if (change == 0) return 'Stable';
    final sign = change > 0 ? '+' : '';
    return '$sign${change.abs().toStringAsFixed(0)}';
  }

  String get changePctLabel {
    if (change == 0) return '0.00%';
    final sign = changePct > 0 ? '+' : '';
    return '$sign${changePct.toStringAsFixed(2)}%';
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class MarketPricesController extends GetxController {
  final selectedCity     = 'Lahore'.obs;
  final selectedCategory = 'All'.obs;
  final searchQuery      = ''.obs;
  final isLoading        = false.obs;
  final lastUpdated      = Rxn<DateTime>();

  final _allMaterials = <MaterialPriceEntry>[].obs;

  static const cities = [
    'Lahore', 'Karachi', 'Islamabad', 'Rawalpindi',
    'Faisalabad', 'Multan', 'Peshawar', 'Other',
  ];

  static const categories = [
    'All', 'Structure', 'Finishing', 'Plumbing', 'Electrical', 'Other',
  ];

  List<MaterialPriceEntry> get filteredMaterials {
    var list = _allMaterials.toList();
    if (selectedCategory.value != 'All') {
      list = list
          .where((m) => m.category == selectedCategory.value)
          .toList();
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((m) =>
              m.name.toLowerCase().contains(q) ||
              m.nameUrdu.contains(q) ||
              m.category.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    loadPrices();
  }

  Future<void> loadPrices() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    _allMaterials.value = _buildMaterials(selectedCity.value);
    lastUpdated.value = DateTime.now();
    isLoading.value = false;
  }

  void selectCity(String city) {
    selectedCity.value = city;
    loadPrices();
  }

  void selectCategory(String cat) => selectedCategory.value = cat;
  void onSearch(String q)         => searchQuery.value = q;

  // ── Pakistan price data ────────────────────────────────────────────────────

  static List<MaterialPriceEntry> _buildMaterials(String city) {
    // City multipliers (small variance by city)
    final m = _cityMultiplier(city);
    return [
      // ── Structure ──────────────────────────────────────────────────────────
      MaterialPriceEntry(
        id: 'cement', name: 'Cement', nameUrdu: 'سیمنٹ',
        icon: '🏗️', category: 'Structure',
        previousPrice: (1350 * m).roundToDouble(),
        currentPrice:  (1420 * m).roundToDouble(),
        unit: '/bag (50 kg)',
        priceHistory: _history([1300, 1320, 1310, 1340, 1350, 1380, 1420], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'steel_rod', name: 'Steel (Sariya)', nameUrdu: 'سریا',
        icon: '⚙️', category: 'Structure',
        previousPrice: (295 * m).roundToDouble(),
        currentPrice:  (288 * m).roundToDouble(),
        unit: '/kg',
        priceHistory: _history([310, 305, 300, 298, 295, 291, 288], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'sand', name: 'Sand', nameUrdu: 'ریت',
        icon: '🏖️', category: 'Structure',
        previousPrice: (52 * m).roundToDouble(),
        currentPrice:  (55 * m).roundToDouble(),
        unit: '/cft',
        priceHistory: _history([48, 50, 51, 52, 52, 54, 55], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'crush', name: 'Crush (Bajri)', nameUrdu: 'بجری',
        icon: '🪨', category: 'Structure',
        previousPrice: (75 * m).roundToDouble(),
        currentPrice:  (78 * m).roundToDouble(),
        unit: '/cft',
        priceHistory: _history([70, 72, 73, 74, 75, 76, 78], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'bricks', name: 'Bricks', nameUrdu: 'اینٹ',
        icon: '🧱', category: 'Structure',
        previousPrice: (18000 * m).roundToDouble(),
        currentPrice:  (18500 * m).roundToDouble(),
        unit: '/1000 pcs',
        priceHistory: _history([17000, 17200, 17500, 17800, 18000, 18200, 18500], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'aggregate', name: 'Aggregate (Surki)', nameUrdu: 'سرکی',
        icon: '🔩', category: 'Structure',
        previousPrice: (3500 * m).roundToDouble(),
        currentPrice:  (3500 * m).roundToDouble(),
        unit: '/trolley',
        priceHistory: _history([3400, 3450, 3450, 3500, 3500, 3500, 3500], m),
        city: city,
      ),

      // ── Finishing ──────────────────────────────────────────────────────────
      MaterialPriceEntry(
        id: 'tiles_floor', name: 'Floor Tiles', nameUrdu: 'ٹائلز',
        icon: '🔲', category: 'Finishing',
        previousPrice: (3200 * m).roundToDouble(),
        currentPrice:  (3400 * m).roundToDouble(),
        unit: '/box (12×12")',
        priceHistory: _history([3000, 3050, 3100, 3150, 3200, 3300, 3400], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'paint_emulsion', name: 'Emulsion Paint', nameUrdu: 'پینٹ',
        icon: '🎨', category: 'Finishing',
        previousPrice: (8500 * m).roundToDouble(),
        currentPrice:  (8800 * m).roundToDouble(),
        unit: '/20L drum',
        priceHistory: _history([8000, 8100, 8200, 8300, 8500, 8650, 8800], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'marble', name: 'Marble (White)', nameUrdu: 'سنگ مرمر',
        icon: '🪟', category: 'Finishing',
        previousPrice: (4500 * m).roundToDouble(),
        currentPrice:  (4750 * m).roundToDouble(),
        unit: '/sqft',
        priceHistory: _history([4200, 4250, 4300, 4400, 4500, 4620, 4750], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'wood_teak', name: 'Teak Wood', nameUrdu: 'ساگوان',
        icon: '🪵', category: 'Finishing',
        previousPrice: (850 * m).roundToDouble(),
        currentPrice:  (870 * m).roundToDouble(),
        unit: '/sqft',
        priceHistory: _history([800, 810, 820, 830, 850, 860, 870], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'glass', name: 'Window Glass', nameUrdu: 'شیشہ',
        icon: '🪟', category: 'Finishing',
        previousPrice: (280 * m).roundToDouble(),
        currentPrice:  (275 * m).roundToDouble(),
        unit: '/sqft (5mm)',
        priceHistory: _history([295, 292, 290, 287, 280, 278, 275], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'aluminum', name: 'Aluminum Section', nameUrdu: 'ایلومینیم',
        icon: '🔩', category: 'Finishing',
        previousPrice: (1800 * m).roundToDouble(),
        currentPrice:  (1800 * m).roundToDouble(),
        unit: '/running ft',
        priceHistory: _history([1750, 1760, 1780, 1790, 1800, 1800, 1800], m),
        city: city,
      ),

      // ── Plumbing ───────────────────────────────────────────────────────────
      MaterialPriceEntry(
        id: 'pvc_pipe', name: 'PVC Pipe 4"', nameUrdu: 'پی وی سی پائپ',
        icon: '🚿', category: 'Plumbing',
        previousPrice: (420 * m).roundToDouble(),
        currentPrice:  (415 * m).roundToDouble(),
        unit: '/piece (10 ft)',
        priceHistory: _history([440, 435, 430, 428, 420, 418, 415], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'gi_pipe', name: 'GI Pipe 1"', nameUrdu: 'جی آئی پائپ',
        icon: '🔧', category: 'Plumbing',
        previousPrice: (1200 * m).roundToDouble(),
        currentPrice:  (1250 * m).roundToDouble(),
        unit: '/piece (20 ft)',
        priceHistory: _history([1150, 1160, 1180, 1190, 1200, 1220, 1250], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'sanitary_wc', name: 'WC / Commode', nameUrdu: 'کموڈ',
        icon: '🚽', category: 'Plumbing',
        previousPrice: (8500 * m).roundToDouble(),
        currentPrice:  (8500 * m).roundToDouble(),
        unit: '/unit (standard)',
        priceHistory: _history([8000, 8100, 8200, 8300, 8500, 8500, 8500], m),
        city: city,
      ),

      // ── Electrical ─────────────────────────────────────────────────────────
      MaterialPriceEntry(
        id: 'copper_wire', name: 'Copper Wire', nameUrdu: 'تانبے کی تار',
        icon: '⚡', category: 'Electrical',
        previousPrice: (1850 * m).roundToDouble(),
        currentPrice:  (1920 * m).roundToDouble(),
        unit: '/100m roll (3mm)',
        priceHistory: _history([1700, 1730, 1760, 1800, 1850, 1880, 1920], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'circuit_breaker', name: 'Circuit Breaker', nameUrdu: 'سرکٹ بریکر',
        icon: '🔌', category: 'Electrical',
        previousPrice: (650 * m).roundToDouble(),
        currentPrice:  (650 * m).roundToDouble(),
        unit: '/piece (30A)',
        priceHistory: _history([620, 630, 640, 645, 650, 650, 650], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'conduit_pipe', name: 'Conduit Pipe', nameUrdu: 'کنڈویٹ پائپ',
        icon: '📡', category: 'Electrical',
        previousPrice: (85 * m).roundToDouble(),
        currentPrice:  (82 * m).roundToDouble(),
        unit: '/piece (10 ft)',
        priceHistory: _history([90, 89, 88, 87, 85, 84, 82], m),
        city: city,
      ),

      // ── Other ──────────────────────────────────────────────────────────────
      MaterialPriceEntry(
        id: 'waterproofing', name: 'Waterproofing', nameUrdu: 'واٹرپروفنگ',
        icon: '💧', category: 'Other',
        previousPrice: (4200 * m).roundToDouble(),
        currentPrice:  (4400 * m).roundToDouble(),
        unit: '/drum (20L)',
        priceHistory: _history([3900, 4000, 4050, 4100, 4200, 4300, 4400], m),
        city: city,
      ),
      MaterialPriceEntry(
        id: 'rcc_shuttering', name: 'Shuttering Ply', nameUrdu: 'شٹرنگ پلائی',
        icon: '🪟', category: 'Other',
        previousPrice: (3800 * m).roundToDouble(),
        currentPrice:  (3750 * m).roundToDouble(),
        unit: '/sheet (8×4 ft)',
        priceHistory: _history([4000, 3980, 3950, 3900, 3800, 3780, 3750], m),
        city: city,
      ),
    ];
  }

  static double _cityMultiplier(String city) => switch (city) {
        'Karachi'    => 1.05,
        'Islamabad'  => 1.08,
        'Rawalpindi' => 1.06,
        'Faisalabad' => 0.97,
        'Multan'     => 0.95,
        'Peshawar'   => 0.98,
        _            => 1.00, // Lahore is base
      };

  static List<double> _history(List<double> base, double mult) =>
      base.map((v) => (v * mult).roundToDouble()).toList();
}
