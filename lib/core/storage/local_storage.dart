import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    AppLogger.info('LocalStorage initialized');
  }

  static SharedPreferences get _instance {
    assert(_prefs != null, 'LocalStorage.init() must be called first');
    return _prefs!;
  }

  static Future<bool> setString(String key, String value) async {
    try {
      return await _instance.setString(key, value);
    } catch (e) {
      AppLogger.error('LocalStorage.setString error', e);
      return false;
    }
  }

  static String? getString(String key) {
    try {
      return _instance.getString(key);
    } catch (e) {
      AppLogger.error('LocalStorage.getString error', e);
      return null;
    }
  }

  static Future<bool> setBool(String key, bool value) async {
    try {
      return await _instance.setBool(key, value);
    } catch (e) {
      AppLogger.error('LocalStorage.setBool error', e);
      return false;
    }
  }

  static bool? getBool(String key) {
    try {
      return _instance.getBool(key);
    } catch (e) {
      AppLogger.error('LocalStorage.getBool error', e);
      return null;
    }
  }

  static Future<bool> setInt(String key, int value) async {
    try {
      return await _instance.setInt(key, value);
    } catch (e) {
      AppLogger.error('LocalStorage.setInt error', e);
      return false;
    }
  }

  static int? getInt(String key) {
    try {
      return _instance.getInt(key);
    } catch (e) {
      AppLogger.error('LocalStorage.getInt error', e);
      return null;
    }
  }

  static Future<bool> remove(String key) async {
    try {
      return await _instance.remove(key);
    } catch (e) {
      AppLogger.error('LocalStorage.remove error', e);
      return false;
    }
  }

  static Future<bool> clear() async {
    try {
      return await _instance.clear();
    } catch (e) {
      AppLogger.error('LocalStorage.clear error', e);
      return false;
    }
  }

  static bool containsKey(String key) => _instance.containsKey(key);
}
