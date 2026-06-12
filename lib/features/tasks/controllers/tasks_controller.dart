import 'package:get/get.dart';
import '../data/models/task_model.dart';
import '../../projects/data/models/project_model.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

/// Central task hub controller.
///
/// Registered permanently (AppBinding) so the dashboard header badge and the
/// "Today's Alert" card stay live without the Tasks page ever being opened.
/// Loading is structured for a paginated API: swap [_fetchPage] for a real
/// endpoint and everything else keeps working.
class TasksController extends GetxController {
  final tasks        = <TaskModel>[].obs;
  final isLoading    = false.obs;
  final hasLoadError = false.obs;

  /// Selected tab: all | tasks | meetings | alerts | completed.
  final selectedTab = 'all'.obs;

  // Pagination state (API-ready).
  final isLoadingMore = false.obs;
  final hasMore       = false.obs;
  int _page = 1;
  static const _pageSize = 20;

  static const tabs = [
    {'key': 'all',       'label': 'All'},
    {'key': 'tasks',     'label': 'Tasks'},
    {'key': 'meetings',  'label': 'Meetings'},
    {'key': 'alerts',    'label': 'Alerts'},
    {'key': 'completed', 'label': 'Done'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  // ── Loading (API-driven; mock-backed for now) ──────────────────────────────

  Future<void> loadTasks() async {
    isLoading.value    = true;
    hasLoadError.value = false;
    try {
      _page = 1;
      final page = await _fetchPage(_page);
      tasks.value = page;
      hasMore.value = page.length >= _pageSize;
    } catch (_) {
      hasLoadError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    try {
      _page++;
      final page = await _fetchPage(_page);
      tasks.addAll(page);
      hasMore.value = page.length >= _pageSize;
    } catch (_) {
      _page--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Single integration point for the future tasks API
  /// (e.g. GET /tasks?page=N&size=M). Push notifications can call
  /// [loadTasks] to refresh, and the Rx badge counts update automatically.
  Future<List<TaskModel>> _fetchPage(int page) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return page == 1 ? TaskModel.mockList() : <TaskModel>[];
  }

  // ── Filtering ──────────────────────────────────────────────────────────────

  List<TaskModel> get filteredTasks {
    final tab = selectedTab.value;
    final list = switch (tab) {
      'completed' => tasks.where((t) => t.isCompleted),
      'all'       => tasks.where((t) => t.isPending),
      _           => tasks.where((t) => t.isPending && t.category == tab),
    }
        .toList();
    // Most urgent first: overdue, then by due time, then priority.
    list.sort((a, b) {
      if (a.isOverdue != b.isOverdue) return a.isOverdue ? -1 : 1;
      final byDate = a.dueDate.compareTo(b.dueDate);
      if (byDate != 0) return byDate;
      return a.priorityWeight.compareTo(b.priorityWeight);
    });
    return list;
  }

  int countFor(String tab) => switch (tab) {
        'completed' => tasks.where((t) => t.isCompleted).length,
        'all'       => tasks.where((t) => t.isPending).length,
        _           => tasks.where((t) => t.isPending && t.category == tab).length,
      };

  // ── Badge & Today's Alert ──────────────────────────────────────────────────

  /// Header badge count — pending items (real-time via Rx).
  int get pendingCount => tasks.where((t) => t.isPending).length;

  /// Pending items due today (or already overdue), most urgent first.
  List<TaskModel> get todaysAlerts {
    final list =
        tasks.where((t) => t.isPending && (t.isDueToday || t.isOverdue)).toList();
    list.sort((a, b) {
      if (a.priorityWeight != b.priorityWeight) {
        return a.priorityWeight.compareTo(b.priorityWeight);
      }
      return a.dueDate.compareTo(b.dueDate);
    });
    return list;
  }

  TaskModel? get topTodayAlert =>
      todaysAlerts.isNotEmpty ? todaysAlerts.first : null;

  int get moreTodayCount =>
      todaysAlerts.isEmpty ? 0 : todaysAlerts.length - 1;

  // ── Status updates ─────────────────────────────────────────────────────────

  void markCompleted(TaskModel task) {
    final i = tasks.indexWhere((t) => t.id == task.id);
    if (i != -1) tasks[i] = tasks[i].copyWith(status: 'completed');
  }

  void markPending(TaskModel task) {
    final i = tasks.indexWhere((t) => t.id == task.id);
    if (i != -1) tasks[i] = tasks[i].copyWith(status: 'pending');
  }

  void deleteTask(TaskModel task) =>
      tasks.removeWhere((t) => t.id == task.id);

  /// Re-insert a task removed by swipe-delete (snackbar Undo).
  void restoreTask(TaskModel task) => tasks.add(task);

  // ── Project navigation ─────────────────────────────────────────────────────

  /// Resolve the ProjectModel a task belongs to, preferring live dashboard
  /// data and falling back to the mock list.
  ProjectModel? projectFor(TaskModel task) {
    if (task.projectId == null) return null;
    final pool = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>().projects.toList()
        : ProjectModel.mockList();
    for (final p in pool) {
      if (p.id == task.projectId) return p;
    }
    return null;
  }
}
