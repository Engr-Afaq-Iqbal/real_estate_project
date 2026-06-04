import 'package:get/get.dart';
import '../data/price_master_data.dart';

/// Provides material prices and construction rates.
/// Falls back to local seed data when offline.
/// In production: fetches from /prices/materials?city_id=X and caches for 6h.
class PriceMasterService extends GetxService {
  // City-specific price overrides loaded from API (empty until API connected)
  final Map<int, Map<int, MaterialPriceData>> _apiPrices = {};

  List<MaterialCategoryData> get categories => PriceMasterData.categories;

  /// Returns materials for a given category, with city-specific prices applied.
  List<MaterialPriceData> materialsForCategory({
    required int categoryId,
    int cityId = 101,
  }) {
    final cityPrices = _apiPrices[cityId] ?? PriceMasterData.pricesByCityAndMaterial[cityId] ?? {};
    return cityPrices.values
        .where((m) => m.categoryId == categoryId)
        .toList();
  }

  /// Returns all materials for a city (all categories).
  List<MaterialPriceData> allMaterialsForCity(int cityId) {
    final cityPrices = _apiPrices[cityId] ??
        PriceMasterData.pricesByCityAndMaterial[cityId] ??
        PriceMasterData.pricesByCityAndMaterial[101] ?? // fallback to Lahore
        {};
    return cityPrices.values.toList();
  }

  /// Returns the current price for a specific material in a city.
  MaterialPriceData? priceFor({required int materialId, int cityId = 101}) {
    final cityPrices = _apiPrices[cityId] ??
        PriceMasterData.pricesByCityAndMaterial[cityId] ??
        PriceMasterData.pricesByCityAndMaterial[101] ??
        {};
    return cityPrices[materialId];
  }

  /// Returns construction rates per sqft for a given quality tier and city.
  Map<String, double> ratesPerSqft(String qualityTier, {int cityId = 101}) {
    // In production: fetch city-specific overrides from API.
    // Currently uses global Pakistan rates.
    return PriceMasterData.ratesPerSqft.map(
      (component, tiers) => MapEntry(component, tiers[qualityTier] ?? 0.0),
    );
  }

  /// Total estimated rate per sqft (sum of all components).
  double totalRatePerSqft(String qualityTier, {int cityId = 101}) {
    return ratesPerSqft(qualityTier, cityId: cityId)
        .values
        .fold(0.0, (sum, rate) => sum + rate);
  }

  String get effectiveDate => PriceMasterData.effectiveDate;

  /// Called by API layer to update prices after a successful fetch.
  void updatePricesForCity(int cityId, List<MaterialPriceData> prices) {
    _apiPrices[cityId] = {for (final p in prices) p.materialId: p};
  }
}
