import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

// ── Calculator material item ──────────────────────────────────────────────────

class CalcMaterialItem {
  final String id;
  final String name;
  final String icon;
  final String category;
  final double unitPrice; // PKR, city-adjusted
  final String unit;
  final bool isCustom;
  double quantity;

  CalcMaterialItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.unitPrice,
    required this.unit,
    this.isCustom = false,
    this.quantity = 0,
  });

  double get totalCost => quantity * unitPrice;
}

// ── Controller ────────────────────────────────────────────────────────────────

class MaterialCostCalcController extends GetxController {
  final selectedCity     = 'Lahore'.obs;
  final selectedCategory = 'All'.obs;
  final searchQuery      = ''.obs;

  final _items = <CalcMaterialItem>[].obs;

  static const cities = [
    'Lahore', 'Karachi', 'Islamabad', 'Rawalpindi',
    'Faisalabad', 'Multan', 'Peshawar', 'Other',
  ];

  static const categories = [
    'All', 'Structure', 'Finishing', 'Plumbing', 'Electrical', 'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadDefaultItems();
  }

  List<CalcMaterialItem> get filteredItems {
    var list = _items.toList();
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
              m.category.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  double get grandTotal =>
      _items.fold(0.0, (sum, m) => sum + m.totalCost);

  int get activeItemCount =>
      _items.where((m) => m.quantity > 0).length;

  void selectCity(String city) {
    selectedCity.value = city;
    _loadDefaultItems();
  }

  void selectCategory(String cat) => selectedCategory.value = cat;
  void onSearch(String q)         => searchQuery.value = q;

  void setQuantity(String id, double qty) {
    final idx = _items.indexWhere((m) => m.id == id);
    if (idx >= 0) {
      _items[idx].quantity = qty;
      _items.refresh();
    }
  }

  void addCustomMaterial({
    required String name,
    required double unitPrice,
    required String unit,
  }) {
    _items.add(CalcMaterialItem(
      id: const Uuid().v4(),
      name: name,
      icon: '📦',
      category: 'Other',
      unitPrice: unitPrice,
      unit: unit.isNotEmpty ? unit : 'unit',
      isCustom: true,
    ));
  }

  void removeCustomItem(String id) {
    _items.removeWhere((m) => m.id == id);
  }

  void clearAll() {
    for (final item in _items) {
      item.quantity = 0;
    }
    _items.refresh();
  }

  void _loadDefaultItems() {
    final mult  = _cityMultiplier(selectedCity.value);
    final saved = <String, double>{};
    // Preserve quantities when reloading
    for (final m in _items.where((m) => !m.isCustom)) {
      saved[m.id] = m.quantity;
    }
    final customs = _items.where((m) => m.isCustom).toList();

    final defaults = _buildDefaults(mult);
    for (final d in defaults) {
      d.quantity = saved[d.id] ?? 0;
    }

    _items.value = [...defaults, ...customs];
  }

  static List<CalcMaterialItem> _buildDefaults(double mult) => [
        // ── Structure ──────────────────────────────────────────────────────
        CalcMaterialItem(
          id: 'cement',
          name: 'Cement',
          icon: '🏗️',
          category: 'Structure',
          unitPrice: (1420 * mult).roundToDouble(),
          unit: 'bags',
        ),
        CalcMaterialItem(
          id: 'steel_rod',
          name: 'Steel (Sariya)',
          icon: '⚙️',
          category: 'Structure',
          unitPrice: (288 * mult).roundToDouble(),
          unit: 'kg',
        ),
        CalcMaterialItem(
          id: 'sand',
          name: 'Sand',
          icon: '🏖️',
          category: 'Structure',
          unitPrice: (55 * mult).roundToDouble(),
          unit: 'cft',
        ),
        CalcMaterialItem(
          id: 'crush',
          name: 'Crush (Bajri)',
          icon: '🪨',
          category: 'Structure',
          unitPrice: (78 * mult).roundToDouble(),
          unit: 'cft',
        ),
        CalcMaterialItem(
          id: 'bricks',
          name: 'Bricks',
          icon: '🧱',
          category: 'Structure',
          unitPrice: (18500 * mult).roundToDouble(),
          unit: '1000 pcs',
        ),
        CalcMaterialItem(
          id: 'aggregate',
          name: 'Aggregate (Surki)',
          icon: '🔩',
          category: 'Structure',
          unitPrice: (3500 * mult).roundToDouble(),
          unit: 'trolley',
        ),

        // ── Finishing ──────────────────────────────────────────────────────
        CalcMaterialItem(
          id: 'tiles_floor',
          name: 'Floor Tiles',
          icon: '🔲',
          category: 'Finishing',
          unitPrice: (280 * mult).roundToDouble(),
          unit: 'sqft',
        ),
        CalcMaterialItem(
          id: 'tiles_wall',
          name: 'Wall Tiles (Kitchen/Bath)',
          icon: '🟦',
          category: 'Finishing',
          unitPrice: (320 * mult).roundToDouble(),
          unit: 'sqft',
        ),
        CalcMaterialItem(
          id: 'paint_emulsion',
          name: 'Emulsion Paint',
          icon: '🎨',
          category: 'Finishing',
          unitPrice: (8800 * mult).roundToDouble(),
          unit: '20L drum',
        ),
        CalcMaterialItem(
          id: 'marble',
          name: 'Marble (White)',
          icon: '💎',
          category: 'Finishing',
          unitPrice: (4750 * mult).roundToDouble(),
          unit: 'sqft',
        ),
        CalcMaterialItem(
          id: 'wood_door',
          name: 'Door Frame + Shutter',
          icon: '🚪',
          category: 'Finishing',
          unitPrice: (22000 * mult).roundToDouble(),
          unit: 'set',
        ),
        CalcMaterialItem(
          id: 'aluminum_window',
          name: 'Aluminum Window',
          icon: '🪟',
          category: 'Finishing',
          unitPrice: (18000 * mult).roundToDouble(),
          unit: 'window (4×4 ft)',
        ),
        CalcMaterialItem(
          id: 'waterproofing',
          name: 'Waterproofing Chemical',
          icon: '💧',
          category: 'Finishing',
          unitPrice: (4400 * mult).roundToDouble(),
          unit: '20L drum',
        ),

        // ── Plumbing ───────────────────────────────────────────────────────
        CalcMaterialItem(
          id: 'pvc_4inch',
          name: 'PVC Pipe 4"',
          icon: '🚿',
          category: 'Plumbing',
          unitPrice: (415 * mult).roundToDouble(),
          unit: 'piece (10ft)',
        ),
        CalcMaterialItem(
          id: 'gi_pipe',
          name: 'GI Pipe 1"',
          icon: '🔧',
          category: 'Plumbing',
          unitPrice: (1250 * mult).roundToDouble(),
          unit: 'piece (20ft)',
        ),
        CalcMaterialItem(
          id: 'sanitary_wc',
          name: 'Commode (WC)',
          icon: '🚽',
          category: 'Plumbing',
          unitPrice: (8500 * mult).roundToDouble(),
          unit: 'unit',
        ),
        CalcMaterialItem(
          id: 'water_tank',
          name: 'Water Storage Tank',
          icon: '🛢️',
          category: 'Plumbing',
          unitPrice: (12000 * mult).roundToDouble(),
          unit: '1000L tank',
        ),

        // ── Electrical ─────────────────────────────────────────────────────
        CalcMaterialItem(
          id: 'copper_wire_3mm',
          name: 'Copper Wire 3mm',
          icon: '⚡',
          category: 'Electrical',
          unitPrice: (19.2 * mult).roundToDouble(),
          unit: 'meter',
        ),
        CalcMaterialItem(
          id: 'conduit_pipe',
          name: 'Conduit Pipe',
          icon: '📡',
          category: 'Electrical',
          unitPrice: (82 * mult).roundToDouble(),
          unit: 'piece (10ft)',
        ),
        CalcMaterialItem(
          id: 'db_board',
          name: 'Distribution Board',
          icon: '🔌',
          category: 'Electrical',
          unitPrice: (8500 * mult).roundToDouble(),
          unit: '12-way board',
        ),
        CalcMaterialItem(
          id: 'switch_socket',
          name: 'Switch + Socket Set',
          icon: '🔲',
          category: 'Electrical',
          unitPrice: (450 * mult).roundToDouble(),
          unit: 'set',
        ),
      ];

  static double _cityMultiplier(String city) => switch (city) {
        'Karachi'    => 1.05,
        'Islamabad'  => 1.08,
        'Rawalpindi' => 1.06,
        'Faisalabad' => 0.97,
        'Multan'     => 0.95,
        'Peshawar'   => 0.98,
        _            => 1.00,
      };
}
