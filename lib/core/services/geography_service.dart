import 'package:get/get.dart';
import '../data/geography_data.dart';

// ── Value objects ─────────────────────────────────────────────────────────────

class CountryData {
  final int id;
  final String name;
  final String nameLocal;
  final String isoCode;
  final String currencyCode;
  final String phonePrefix;

  const CountryData({
    required this.id,
    required this.name,
    required this.nameLocal,
    required this.isoCode,
    required this.currencyCode,
    required this.phonePrefix,
  });
}

class CityData {
  final int id;
  final int countryId;
  final String name;
  final String nameLocal;
  final String region;

  const CityData({
    required this.id,
    required this.countryId,
    required this.name,
    required this.nameLocal,
    required this.region,
  });
}

class AreaData {
  final int id;
  final int cityId;
  final String name;

  const AreaData({
    required this.id,
    required this.cityId,
    required this.name,
  });
}

// ── Service ───────────────────────────────────────────────────────────────────

class GeographyService extends GetxService {
  // All data is seeded locally — no network needed for geography.
  // In production this would be fetched once from API and cached.

  List<CountryData> get countries => GeographyData.countries;

  List<CityData> citiesForCountry(int countryId) =>
      GeographyData.citiesByCountry[countryId] ?? [];

  List<AreaData> areasForCity(int cityId) =>
      GeographyData.areasByCity[cityId] ?? [];

  CountryData? countryById(int id) {
    try {
      return countries.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  CityData? cityById(int id) {
    for (final cities in GeographyData.citiesByCountry.values) {
      try {
        return cities.firstWhere((c) => c.id == id);
      } catch (_) {}
    }
    return null;
  }

  AreaData? areaById(int id) {
    for (final areas in GeographyData.areasByCity.values) {
      try {
        return areas.firstWhere((a) => a.id == id);
      } catch (_) {}
    }
    return null;
  }

  /// Returns the country that uses the given ISO code.
  CountryData? countryByIso(String isoCode) {
    try {
      return countries.firstWhere(
        (c) => c.isoCode.toUpperCase() == isoCode.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // Default Pakistan / Lahore IDs for first-run defaults
  static const int defaultCountryId = 1;  // Pakistan
  static const int defaultCityId    = 101; // Lahore
}
