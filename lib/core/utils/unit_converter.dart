/// All measurements stored internally as sq_meters (double).
/// This class converts between display units and internal storage.
class UnitConverter {
  UnitConverter._();

  // Conversion factors: 1 unit = X sq_meters
  static const Map<String, double> _toSqMeters = {
    'sqm': 1.0,
    'sqft': 0.09290304,
    'sqyd': 0.83612736,
    'marla': 25.2929, // 272.25 sqft — Pakistan standard
    'kanal': 505.857, // 20 Marla
    'acre': 4046.8564,
    'hectare': 10000.0,
  };

  static const Map<String, String> labels = {
    'sqm': 'sq m',
    'sqft': 'sq ft',
    'sqyd': 'sq yd',
    'marla': 'Marla',
    'kanal': 'Kanal',
    'acre': 'Acre',
    'hectare': 'Hectare',
  };

  static const Map<String, String> shortLabels = {
    'sqm': 'm²',
    'sqft': 'ft²',
    'sqyd': 'yd²',
    'marla': 'Marla',
    'kanal': 'Kanal',
    'acre': 'Acre',
    'hectare': 'ha',
  };

  /// All supported unit keys
  static const List<String> allUnits = [
    'marla',
    'kanal',
    'sqft',
    'sqyd',
    'sqm',
    'acre',
    'hectare',
  ];

  /// Units relevant for Pakistan market (shown first)
  static const List<String> pakistanUnits = [
    'marla',
    'kanal',
    'sqft',
    'sqyd',
    'sqm',
  ];

  static double toSqMeters(double value, String unit) {
    final factor = _toSqMeters[unit.toLowerCase()];
    assert(factor != null, 'Unknown unit: $unit');
    return value * (factor ?? 1.0);
  }

  static double fromSqMeters(double sqm, String toUnit) {
    final factor = _toSqMeters[toUnit.toLowerCase()];
    assert(factor != null, 'Unknown unit: $toUnit');
    return sqm / (factor ?? 1.0);
  }

  static double convert(double value, String fromUnit, String toUnit) {
    return fromSqMeters(toSqMeters(value, fromUnit), toUnit);
  }

  /// Format a sq_meters value in the desired display unit
  static String format(double sqm, String displayUnit, {int decimals = 2}) {
    final val = fromSqMeters(sqm, displayUnit);
    final label = labels[displayUnit.toLowerCase()] ?? displayUnit;
    // Drop trailing zeros for whole numbers
    final formatted = val == val.truncateToDouble()
        ? val.toStringAsFixed(0)
        : val.toStringAsFixed(decimals);
    return '$formatted $label';
  }

  /// Returns a hint string: "= 1,361 sq ft  =  126.5 sq m"
  static String hint(double value, String unit, List<String> alsoShow) {
    final sqm = toSqMeters(value, unit);
    return alsoShow
        .where((u) => u.toLowerCase() != unit.toLowerCase())
        .map((u) => format(sqm, u))
        .join('  =  ');
  }

  /// Convert sq_feet to sq_meters (convenience)
  static double sqftToSqm(double sqft) => sqft * 0.09290304;

  /// Convert sq_meters to sq_feet (convenience)
  static double sqmToSqft(double sqm) => sqm / 0.09290304;

  static String label(String unit) =>
      labels[unit.toLowerCase()] ?? unit;

  static String shortLabel(String unit) =>
      shortLabels[unit.toLowerCase()] ?? unit;
}
