import 'dart:async';
import 'package:get/get.dart';
import '../data/models/project_model.dart';
import '../data/models/stage_model.dart';

class ProjectsController extends GetxController {
  // ── Load state ────────────────────────────────────────────────────────────
  final isLoading      = false.obs;
  final hasLoadError   = false.obs;
  final isLoadingMore  = false.obs;    // Fix 1: next-page spinner
  final hasMore        = true.obs;     // Fix 1: whether more pages exist

  // Full data from "server"
  final _allProjects = <ProjectModel>[];

  // What the screen renders (grows as pages load)
  final projects     = <ProjectModel>[].obs;

  static const int _pageSize = 10;
  int _loadedCount = 0;

  // ── Selection / filter ────────────────────────────────────────────────────
  final selectedProject = Rxn<ProjectModel>();
  final selectedFilter  = 'active'.obs;

  // Fix 2: debounce — the raw input is stored here immediately
  final _rawSearchQuery = ''.obs;
  // The debounced value drives filteredProjects
  final searchQuery     = ''.obs;
  Timer? _searchDebounce;

  // Last synced timestamp + display label
  final _lastSyncedAt = Rxn<DateTime>();
  final syncLabel     = 'Syncing…'.obs;
  Timer? _syncTimer;

  // Stage progress overrides (stageId → 0–100)
  final stageProgressMap = <String, double>{}.obs;
  // Stage status overrides (stageId → 'notStarted'|'inProgress'|'completed')
  final stageStatusMap   = <String, String>{}.obs;

  // F1: Payment milestone status per stage (stageId → 'pending'|'released')
  final paymentStatusMap = <String, String>{}.obs;

  String paymentStatus(String stageId) =>
      paymentStatusMap[stageId] ?? 'pending';
  bool isPaymentReleased(String stageId) =>
      paymentStatusMap[stageId] == 'released';
  void releaseStagePayment(String stageId) {
    paymentStatusMap[stageId] = 'released';
    paymentStatusMap.refresh();
  }

  double totalReleasedPayment(List<dynamic> stages, double totalBudget) {
    if (stages.isEmpty) return 0;
    double released = 0;
    for (int i = 0; i < stages.length; i++) {
      final s = stages[i];
      if (isPaymentReleased(s.id as String)) {
        released += totalBudget / stages.length;
      }
    }
    return released;
  }

  // Wizard helpers
  final wizardStep          = 0.obs;
  final selectedProjectType = 'House'.obs;
  final projectName         = ''.obs;
  final projectCity         = 'Lahore'.obs;
  final projectArea         = ''.obs;
  final projectPlotSize     = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProjects();
    if (Get.arguments is ProjectModel) {
      selectedProject.value = Get.arguments as ProjectModel;
    }
    _syncTimer = Timer.periodic(
        const Duration(minutes: 1), (_) => _refreshSyncLabel());
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    _searchDebounce?.cancel();
    super.onClose();
  }

  // ── Fix 2: Debounced search ───────────────────────────────────────────────

  /// Call this from onChanged. Updates the display immediately so the user
  /// sees their text, but only triggers the filter after 300 ms of silence.
  void setSearchQuery(String value) {
    _rawSearchQuery.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = value;
    });
  }

  // ── Fix 1: Load + paginate ────────────────────────────────────────────────

  Future<void> loadProjects() async {
    isLoading.value    = true;
    hasLoadError.value = false;
    _loadedCount = 0;
    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      _allProjects
        ..clear()
        ..addAll(ProjectModel.mockList());
      _lastSyncedAt.value = DateTime.now();
      _refreshSyncLabel();
      _appendPage();
    } catch (_) {
      hasLoadError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads the next page of 10 projects. Called by the scroll listener.
  Future<void> loadNextPage() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    await Future.delayed(const Duration(milliseconds: 500)); // simulate network
    _appendPage();
    isLoadingMore.value = false;
  }

  void _appendPage() {
    final end = (_loadedCount + _pageSize).clamp(0, _allProjects.length);
    if (_loadedCount >= _allProjects.length) {
      hasMore.value = false;
      return;
    }
    projects.addAll(_allProjects.sublist(_loadedCount, end));
    _loadedCount = end;
    hasMore.value = _loadedCount < _allProjects.length;
  }

  // ── Filtered list ──────────────────────────────────────────────────────────

  List<ProjectModel> get filteredProjects {
    final q = searchQuery.value.toLowerCase().trim();
    var list = switch (selectedFilter.value) {
      'active'    => projects.where((p) => p.status == 'active').toList(),
      'completed' => projects.where((p) => p.status == 'completed').toList(),
      'on_hold'   => projects.where((p) => p.status == 'on_hold').toList(),
      _           => projects.toList(),
    };
    if (q.isNotEmpty) {
      list = list.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.city.toLowerCase().contains(q) ||
        p.area.toLowerCase().contains(q) ||
        p.statusLabel.toLowerCase().contains(q),
      ).toList();
    }
    return list;
  }

  void selectProject(ProjectModel project) {
    selectedProject.value = project;
    selectedProject.refresh();
  }

  // ── Sync label ────────────────────────────────────────────────────────────

  void _refreshSyncLabel() {
    final t = _lastSyncedAt.value;
    if (t == null) { syncLabel.value = 'Not synced yet'; return; }
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) {
      syncLabel.value = 'Last synced just now';
    } else if (diff.inMinutes < 60) {
      syncLabel.value = 'Last synced ${diff.inMinutes}m ago';
    } else {
      syncLabel.value = 'Last synced ${diff.inHours}h ago';
    }
  }

  // ── Stage progress management ─────────────────────────────────────────────

  double stageProgress(String stageId, double defaultProgress) =>
      stageProgressMap[stageId] ?? defaultProgress;

  String stageStatus(String stageId, String defaultStatus) =>
      stageStatusMap[stageId] ?? defaultStatus;

  bool isStageCompleted(String stageId) =>
      stageStatusMap[stageId] == 'completed';

  void updateStageProgress(String stageId, double pct) {
    stageProgressMap[stageId] = pct;
    stageProgressMap.refresh();
    if (pct >= 100) {
      stageStatusMap[stageId] = 'completed';
      stageStatusMap.refresh();
    } else if (pct > 0 && stageStatusMap[stageId] != 'inProgress') {
      stageStatusMap[stageId] = 'inProgress';
      stageStatusMap.refresh();
    }
  }

  void markStageComplete(String stageId) {
    stageProgressMap[stageId] = 100.0;
    stageStatusMap[stageId]   = 'completed';
    stageProgressMap.refresh();
    stageStatusMap.refresh();
  }

  void markStageInProgress(String stageId) {
    if (stageStatusMap[stageId] != 'completed') {
      stageStatusMap[stageId] = 'inProgress';
      if ((stageProgressMap[stageId] ?? 0) == 0) {
        stageProgressMap[stageId] = 5.0;
      }
      stageProgressMap.refresh();
      stageStatusMap.refresh();
    }
  }

  double get overallProgress {
    final project = selectedProject.value;
    if (project == null) return 0;
    final stages = project.stages;
    if (stages.isEmpty) return project.completionPct;
    double total = 0;
    for (final s in stages) {
      total += stageProgressMap[s.id] ?? s.completionPct;
    }
    return total / stages.length;
  }

  void nextWizardStep() {
    if (wizardStep.value < 3) wizardStep.value++;
  }

  void prevWizardStep() {
    if (wizardStep.value > 0) wizardStep.value--;
  }

  StageModel? get currentStage {
    final stages = selectedProject.value?.stages ?? [];
    try {
      return stages.firstWhere((s) => s.isInProgress);
    } catch (_) {
      return stages.isNotEmpty ? stages.first : null;
    }
  }
}
