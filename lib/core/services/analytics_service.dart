import 'package:get/get.dart';
import '../utils/logger.dart';

// Analytics-ready service structure.
// Activate by connecting Firebase Analytics or another provider.
class AnalyticsService extends GetxService {
  @override
  void onInit() {
    super.onInit();
    AppLogger.info('AnalyticsService initialized');
  }

  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    AppLogger.debug('Analytics event: $name | params: $parameters');
    // await _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> setUserId(String userId) async {
    AppLogger.debug('Analytics userId: $userId');
    // await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty(String name, String value) async {
    AppLogger.debug('Analytics property: $name = $value');
    // await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> logScreenView(String screenName) async {
    AppLogger.debug('Screen view: $screenName');
    // await _analytics.logScreenView(screenName: screenName);
  }

  // Common events
  Future<void> logLogin(String method) => logEvent('login', {'method': method});
  Future<void> logSignUp(String method) => logEvent('sign_up', {'method': method});
  Future<void> logProjectCreated(String type) => logEvent('project_created', {'type': type});
  Future<void> logExpenseLogged(double amount) => logEvent('expense_logged', {'amount': amount});
  Future<void> logCalculatorUsed() => logEvent('calculator_used');
}
