import 'package:get/get.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final String timeAgo;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timeAgo,
    this.isRead = false,
  });
}

class NotificationsController extends GetxController {
  final notifications = <String, List<AppNotification>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  void _loadNotifications() {
    notifications.value = {
      'TODAY': [
        AppNotification(id: 'n1', title: 'Stage Complete: Foundation', body: 'Malik Construction marked Foundation & Plinth as done.', type: 'stage', timeAgo: '2h ago'),
        AppNotification(id: 'n2', title: 'Budget Alert · Steel category', body: 'Steel spending crossed 80% of allocation.', type: 'budget', timeAgo: '4h ago', isRead: true),
        AppNotification(id: 'n3', title: 'New Message · Malik Construction', body: '"Slab work for second floor poured today..."', type: 'message', timeAgo: '5h ago', isRead: true),
      ],
      'YESTERDAY': [
        AppNotification(id: 'n4', title: 'AI Warning · Late delivery', body: 'Cement order from Ali Hardware delayed by 2 days.', type: 'ai', timeAgo: '1d ago'),
      ],
      'EARLIER': [
        AppNotification(id: 'n5', title: 'Calculation saved', body: 'DHA 10 Marla House · PKR 48.5L', type: 'system', timeAgo: '3d ago', isRead: true),
      ],
    };
  }

  void markAllRead() {
    for (final group in notifications.values) {
      for (final n in group) {
        n.isRead = true;
      }
    }
    notifications.refresh();
  }

  int get unreadCount {
    return notifications.values
        .expand((list) => list)
        .where((n) => !n.isRead)
        .length;
  }
}
