import '../services/geography_service.dart';

/// Seed data for countries, cities, and areas.
/// Loaded once at startup into GeographyService.
/// Pakistan is fully populated. Other markets are seeded with major cities.
class GeographyData {
  GeographyData._();

  static const List<CountryData> countries = [
    CountryData(
      id: 1, name: 'Pakistan', nameLocal: 'پاکستان',
      isoCode: 'PK', currencyCode: 'PKR', phonePrefix: '+92',
    ),
    CountryData(
      id: 2, name: 'Saudi Arabia', nameLocal: 'المملكة العربية السعودية',
      isoCode: 'SA', currencyCode: 'SAR', phonePrefix: '+966',
    ),
    CountryData(
      id: 3, name: 'United Arab Emirates', nameLocal: 'الإمارات العربية المتحدة',
      isoCode: 'AE', currencyCode: 'AED', phonePrefix: '+971',
    ),
    CountryData(
      id: 4, name: 'Qatar', nameLocal: 'قطر',
      isoCode: 'QA', currencyCode: 'QAR', phonePrefix: '+974',
    ),
    CountryData(
      id: 5, name: 'United Kingdom', nameLocal: 'United Kingdom',
      isoCode: 'GB', currencyCode: 'GBP', phonePrefix: '+44',
    ),
    CountryData(
      id: 6, name: 'United States', nameLocal: 'United States',
      isoCode: 'US', currencyCode: 'USD', phonePrefix: '+1',
    ),
    CountryData(
      id: 7, name: 'India', nameLocal: 'भारत',
      isoCode: 'IN', currencyCode: 'INR', phonePrefix: '+91',
    ),
    CountryData(
      id: 8, name: 'Malaysia', nameLocal: 'Malaysia',
      isoCode: 'MY', currencyCode: 'MYR', phonePrefix: '+60',
    ),
  ];

  static const Map<int, List<CityData>> citiesByCountry = {
    // ── Pakistan ────────────────────────────────────────────────────────────
    1: [
      CityData(id: 101, countryId: 1, name: 'Lahore',      nameLocal: 'لاہور',     region: 'Punjab'),
      CityData(id: 102, countryId: 1, name: 'Karachi',     nameLocal: 'کراچی',     region: 'Sindh'),
      CityData(id: 103, countryId: 1, name: 'Islamabad',   nameLocal: 'اسلام آباد', region: 'ICT'),
      CityData(id: 104, countryId: 1, name: 'Rawalpindi',  nameLocal: 'راولپنڈی',  region: 'Punjab'),
      CityData(id: 105, countryId: 1, name: 'Faisalabad',  nameLocal: 'فیصل آباد', region: 'Punjab'),
      CityData(id: 106, countryId: 1, name: 'Multan',      nameLocal: 'ملتان',     region: 'Punjab'),
      CityData(id: 107, countryId: 1, name: 'Peshawar',    nameLocal: 'پشاور',     region: 'KPK'),
      CityData(id: 108, countryId: 1, name: 'Quetta',      nameLocal: 'کوئٹہ',     region: 'Balochistan'),
      CityData(id: 109, countryId: 1, name: 'Sialkot',     nameLocal: 'سیالکوٹ',  region: 'Punjab'),
      CityData(id: 110, countryId: 1, name: 'Gujranwala',  nameLocal: 'گوجرانوالہ', region: 'Punjab'),
      CityData(id: 111, countryId: 1, name: 'Hyderabad',   nameLocal: 'حیدرآباد',  region: 'Sindh'),
      CityData(id: 112, countryId: 1, name: 'Bahawalpur',  nameLocal: 'بہاولپور',  region: 'Punjab'),
      CityData(id: 113, countryId: 1, name: 'Gujrat',      nameLocal: 'گجرات',    region: 'Punjab'),
      CityData(id: 114, countryId: 1, name: 'Sargodha',    nameLocal: 'سرگودھا',   region: 'Punjab'),
      CityData(id: 115, countryId: 1, name: 'Abbottabad',  nameLocal: 'ایبٹ آباد', region: 'KPK'),
    ],
    // ── Saudi Arabia ─────────────────────────────────────────────────────────
    2: [
      CityData(id: 201, countryId: 2, name: 'Riyadh',  nameLocal: 'الرياض',   region: 'Riyadh'),
      CityData(id: 202, countryId: 2, name: 'Jeddah',  nameLocal: 'جدة',      region: 'Makkah'),
      CityData(id: 203, countryId: 2, name: 'Mecca',   nameLocal: 'مكة المكرمة', region: 'Makkah'),
      CityData(id: 204, countryId: 2, name: 'Medina',  nameLocal: 'المدينة المنورة', region: 'Madinah'),
      CityData(id: 205, countryId: 2, name: 'Dammam',  nameLocal: 'الدمام',   region: 'Eastern'),
      CityData(id: 206, countryId: 2, name: 'Khobar',  nameLocal: 'الخبر',    region: 'Eastern'),
    ],
    // ── UAE ───────────────────────────────────────────────────────────────────
    3: [
      CityData(id: 301, countryId: 3, name: 'Dubai',       nameLocal: 'دبي',         region: 'Dubai'),
      CityData(id: 302, countryId: 3, name: 'Abu Dhabi',   nameLocal: 'أبو ظبي',     region: 'Abu Dhabi'),
      CityData(id: 303, countryId: 3, name: 'Sharjah',     nameLocal: 'الشارقة',     region: 'Sharjah'),
      CityData(id: 304, countryId: 3, name: 'Ajman',       nameLocal: 'عجمان',       region: 'Ajman'),
    ],
    // ── Qatar ─────────────────────────────────────────────────────────────────
    4: [
      CityData(id: 401, countryId: 4, name: 'Doha',    nameLocal: 'الدوحة',  region: 'Doha'),
      CityData(id: 402, countryId: 4, name: 'Al Wakra', nameLocal: 'الوكرة', region: 'Al Wakra'),
    ],
    // ── UK ────────────────────────────────────────────────────────────────────
    5: [
      CityData(id: 501, countryId: 5, name: 'London',     nameLocal: 'London',     region: 'England'),
      CityData(id: 502, countryId: 5, name: 'Birmingham', nameLocal: 'Birmingham', region: 'England'),
      CityData(id: 503, countryId: 5, name: 'Manchester', nameLocal: 'Manchester', region: 'England'),
      CityData(id: 504, countryId: 5, name: 'Bradford',   nameLocal: 'Bradford',   region: 'England'),
    ],
    // ── USA ───────────────────────────────────────────────────────────────────
    6: [
      CityData(id: 601, countryId: 6, name: 'New York',     nameLocal: 'New York',     region: 'New York'),
      CityData(id: 602, countryId: 6, name: 'Houston',      nameLocal: 'Houston',      region: 'Texas'),
      CityData(id: 603, countryId: 6, name: 'Chicago',      nameLocal: 'Chicago',      region: 'Illinois'),
      CityData(id: 604, countryId: 6, name: 'Los Angeles',  nameLocal: 'Los Angeles',  region: 'California'),
    ],
    // ── India ─────────────────────────────────────────────────────────────────
    7: [
      CityData(id: 701, countryId: 7, name: 'Mumbai',    nameLocal: 'मुंबई',    region: 'Maharashtra'),
      CityData(id: 702, countryId: 7, name: 'Delhi',     nameLocal: 'दिल्ली',   region: 'Delhi'),
      CityData(id: 703, countryId: 7, name: 'Bangalore', nameLocal: 'बेंगलुरु', region: 'Karnataka'),
      CityData(id: 704, countryId: 7, name: 'Karachi',   nameLocal: 'كراتشي',   region: 'Sindh'),
    ],
    // ── Malaysia ──────────────────────────────────────────────────────────────
    8: [
      CityData(id: 801, countryId: 8, name: 'Kuala Lumpur', nameLocal: 'Kuala Lumpur', region: 'WP'),
      CityData(id: 802, countryId: 8, name: 'Johor Bahru',  nameLocal: 'Johor Bahru',  region: 'Johor'),
      CityData(id: 803, countryId: 8, name: 'Penang',       nameLocal: 'Pulau Pinang', region: 'Penang'),
    ],
  };

  // ── Lahore Areas (most detailed — primary market) ─────────────────────────
  static const Map<int, List<AreaData>> areasByCity = {
    101: [ // Lahore
      AreaData(id: 10101, cityId: 101, name: 'DHA Phase 1'),
      AreaData(id: 10102, cityId: 101, name: 'DHA Phase 2'),
      AreaData(id: 10103, cityId: 101, name: 'DHA Phase 3'),
      AreaData(id: 10104, cityId: 101, name: 'DHA Phase 4'),
      AreaData(id: 10105, cityId: 101, name: 'DHA Phase 5'),
      AreaData(id: 10106, cityId: 101, name: 'DHA Phase 6'),
      AreaData(id: 10107, cityId: 101, name: 'DHA Phase 7'),
      AreaData(id: 10108, cityId: 101, name: 'DHA Phase 8'),
      AreaData(id: 10109, cityId: 101, name: 'DHA Phase 9'),
      AreaData(id: 10110, cityId: 101, name: 'Bahria Town'),
      AreaData(id: 10111, cityId: 101, name: 'Bahria Orchard'),
      AreaData(id: 10112, cityId: 101, name: 'Gulberg I'),
      AreaData(id: 10113, cityId: 101, name: 'Gulberg II'),
      AreaData(id: 10114, cityId: 101, name: 'Gulberg III'),
      AreaData(id: 10115, cityId: 101, name: 'Model Town'),
      AreaData(id: 10116, cityId: 101, name: 'Johar Town'),
      AreaData(id: 10117, cityId: 101, name: 'Garden Town'),
      AreaData(id: 10118, cityId: 101, name: 'Wapda Town'),
      AreaData(id: 10119, cityId: 101, name: 'Township'),
      AreaData(id: 10120, cityId: 101, name: 'Iqbal Town'),
      AreaData(id: 10121, cityId: 101, name: 'Faisal Town'),
      AreaData(id: 10122, cityId: 101, name: 'Cantt'),
      AreaData(id: 10123, cityId: 101, name: 'Allama Iqbal Town'),
      AreaData(id: 10124, cityId: 101, name: 'LDA Avenue'),
      AreaData(id: 10125, cityId: 101, name: 'Sukh Chayn Gardens'),
    ],
    102: [ // Karachi
      AreaData(id: 10201, cityId: 102, name: 'DHA Karachi'),
      AreaData(id: 10202, cityId: 102, name: 'Bahria Town Karachi'),
      AreaData(id: 10203, cityId: 102, name: 'Clifton'),
      AreaData(id: 10204, cityId: 102, name: 'Defence'),
      AreaData(id: 10205, cityId: 102, name: 'Gulshan-e-Iqbal'),
      AreaData(id: 10206, cityId: 102, name: 'North Nazimabad'),
      AreaData(id: 10207, cityId: 102, name: 'Gulistan-e-Jauhar'),
      AreaData(id: 10208, cityId: 102, name: 'PECHS'),
      AreaData(id: 10209, cityId: 102, name: 'Korangi'),
      AreaData(id: 10210, cityId: 102, name: 'Saddar'),
    ],
    103: [ // Islamabad
      AreaData(id: 10301, cityId: 103, name: 'F-6'),
      AreaData(id: 10302, cityId: 103, name: 'F-7'),
      AreaData(id: 10303, cityId: 103, name: 'F-8'),
      AreaData(id: 10304, cityId: 103, name: 'F-10'),
      AreaData(id: 10305, cityId: 103, name: 'F-11'),
      AreaData(id: 10306, cityId: 103, name: 'G-9'),
      AreaData(id: 10307, cityId: 103, name: 'G-10'),
      AreaData(id: 10308, cityId: 103, name: 'G-11'),
      AreaData(id: 10309, cityId: 103, name: 'G-13'),
      AreaData(id: 10310, cityId: 103, name: 'DHA Islamabad'),
      AreaData(id: 10311, cityId: 103, name: 'Bahria Town Islamabad'),
      AreaData(id: 10312, cityId: 103, name: 'PWD Housing Society'),
      AreaData(id: 10313, cityId: 103, name: 'Bani Gala'),
    ],
    104: [ // Rawalpindi
      AreaData(id: 10401, cityId: 104, name: 'Bahria Town Phase 1'),
      AreaData(id: 10402, cityId: 104, name: 'Bahria Town Phase 2'),
      AreaData(id: 10403, cityId: 104, name: 'DHA Rawalpindi'),
      AreaData(id: 10404, cityId: 104, name: 'Satellite Town'),
      AreaData(id: 10405, cityId: 104, name: 'Cantt'),
      AreaData(id: 10406, cityId: 104, name: 'Chaklala Scheme'),
    ],
  };
}
