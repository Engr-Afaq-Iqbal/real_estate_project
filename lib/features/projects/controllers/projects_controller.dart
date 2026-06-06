import 'dart:async';
import 'package:get/get.dart';
import '../data/models/project_model.dart';
import '../data/models/stage_model.dart';

class ProjectsController extends GetxController {
  final isLoading    = false.obs;
  final hasLoadError = false.obs;
  final projects     = <ProjectModel>[].obs;
  final selectedProject = Rxn<ProjectModel>();
  final selectedFilter  = 'active'.obs;
  final searchQuery     = ''.obs;

  // Last synced timestamp + display label
  final _lastSyncedAt = Rxn<DateTime>();
  final syncLabel     = 'Syncing…'.obs;
  Timer? _syncTimer;

  // Stage progress overrides (stageId → 0–100)
  final stageProgressMap = <String, double>{}.obs;
  // Stage status overrides (stageId → 'notStarted'|'inProgress'|'completed')
  final stageStatusMap   = <String, String>{}.obs;

  // New project wizard
  final wizardStep         = 0.obs;
  final selectedProjectType = 'House'.obs;
  final projectName        = ''.obs;
  final projectCity        = 'Lahore'.obs;
  final projectArea        = ''.obs;
  final projectPlotSize    = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProjects();
    if (Get.arguments is ProjectModel) {
      selectedProject.value = Get.arguments as ProjectModel;
    }
    // Update sync label every minute
    _syncTimer = Timer.periodic(const Duration(minutes: 1), (_) => _refreshSyncLabel());
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadProjects() async {
    isLoading.value    = true;
    hasLoadError.value = false;
    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      projects.value = ProjectModel.mockList();
      _lastSyncedAt.value = DateTime.now();
      _refreshSyncLabel();
    } catch (_) {
      hasLoadError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _refreshSyncLabel() {
    final t = _lastSyncedAt.value;
    if (t == null) { syncLabel.value = 'Not synced yet'; return; }
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) {
      syncLabel.value = 'Last synced just now';
    } else if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      syncLabel.value = 'Last synced ${m}m ago';
    } else {
      syncLabel.value = 'Last synced ${diff.inHours}h ago';
    }
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

  // ── Stage progress management ──────────────────────────────────────────────

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
    } else if (pct > 0) {
      if (stageStatusMap[stageId] != 'inProgress') {
        stageStatusMap[stageId] = 'inProgress';
        stageStatusMap.refresh();
      }
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

  /// Overall completion of selected project (0–100) considering overrides.
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
