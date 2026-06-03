import 'package:get/get.dart';
import 'en_US.dart';
import 'ur_PK.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'en_PK': enUS,
    'ur_PK': urPK,
  };

  static const List<SupportedLocale> supportedLocales = [
    SupportedLocale(code: 'en', countryCode: 'US', name: 'English'),
    SupportedLocale(code: 'ur', countryCode: 'PK', name: 'اردو'),
  ];
}

class SupportedLocale {
  final String code;
  final String countryCode;
  final String name;

  const SupportedLocale({
    required this.code,
    required this.countryCode,
    required this.name,
  });

  String get tag => '${code}_$countryCode';
}
