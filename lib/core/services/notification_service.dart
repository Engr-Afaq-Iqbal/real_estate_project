import 'package:get/get.dart';
import '../utils/logger.dart';

// Firebase-ready notification service structure.
// Activate by uncommenting Firebase imports and restoring _initFirebase().
class NotificationService extends GetxService {
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('NotificationService initialized (Firebase not yet active)');
  }

  // Call this after Firebase is configured:
  // Future<void> _initFirebase() async {
  //   await FirebaseMessaging.instance.requestPermission();
  //   final token = await FirebaseMessaging.instance.getToken();
  //   AppLogger.info('FCM Token: $token');
  //   FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  //   FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  // }

  void incrementUnread() => unreadCount.value++;

  void clearUnread() => unreadCount.value = 0;

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    AppLogger.info('Local notification: $title — $body');
  }
}
