import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../data/models/team_model.dart';

const _uuid = Uuid();

class TeamController extends GetxController {
  final isLoading    = false.obs;
  final teams        = <TeamModel>[].obs;
  final searchQuery  = ''.obs;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadTeams();
  }

  Future<void> loadTeams() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 350));
    teams.value = TeamModel.mockList();
    isLoading.value = false;
  }

  // ── KPI getters (reactive via Obx on teams list) ──────────────────────────

  int get totalTeams    => teams.length;
  int get activeTeams   => teams.where((t) => t.isActive).length;
  int get totalWorkers  => teams.fold(0, (s, t) => s + t.workerCount);

  int get activeWorkers =>
      teams.fold(0, (s, t) => s + t.activeWorkerCount);

  int get workersOnLeave =>
      teams.fold(0, (s, t) => s + t.workersOnLeave);

  int get assignedProjectCount =>
      teams.expand((t) => t.assignedProjectIds).toSet().length;

  double get totalMonthlyCost =>
      teams.fold(0, (s, t) => s + t.totalMonthlyCost);

  // ── Filtered list (for search) ────────────────────────────────────────────

  List<TeamModel> get filteredTeams {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return teams;
    return teams
        .where((t) =>
            t.name.toLowerCase().contains(q) ||
            t.leaderName.toLowerCase().contains(q) ||
            t.type.label.toLowerCase().contains(q))
        .toList();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> createTeam(TeamModel team) async {
    teams.add(team);
    teams.refresh();
  }

  Future<void> updateTeam(TeamModel updated) async {
    final idx = teams.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      teams[idx] = updated;
      teams.refresh();
    }
  }

  Future<void> deleteTeam(String id) async {
    teams.removeWhere((t) => t.id == id);
  }

  Future<void> addWorkerToTeam(
      String teamId, TeamWorkerModel worker) async {
    final idx = teams.indexWhere((t) => t.id == teamId);
    if (idx == -1) return;
    final team = teams[idx];
    final updated = team.copyWith(
      workers: [...team.workers, worker],
      lastActivityAt: DateTime.now(),
    );
    teams[idx] = updated;
    teams.refresh();
  }

  Future<void> removeWorkerFromTeam(
      String teamId, String workerId) async {
    final idx = teams.indexWhere((t) => t.id == teamId);
    if (idx == -1) return;
    final team = teams[idx];
    final updated = team.copyWith(
      workers: team.workers.where((w) => w.id != workerId).toList(),
      lastActivityAt: DateTime.now(),
    );
    teams[idx] = updated;
    teams.refresh();
  }

  Future<void> assignToProject(
      String teamId, String projectId) async {
    final idx = teams.indexWhere((t) => t.id == teamId);
    if (idx == -1) return;
    final team = teams[idx];
    if (team.assignedProjectIds.contains(projectId)) return;
    final updated = team.copyWith(
      assignedProjectIds: [...team.assignedProjectIds, projectId],
      lastActivityAt: DateTime.now(),
    );
    teams[idx] = updated;
    teams.refresh();
  }

  void setSearchQuery(String q) => searchQuery.value = q;

  // ── Factory helpers ───────────────────────────────────────────────────────

  static TeamModel newBlankTeam() => TeamModel(
        id: _uuid.v4(),
        name: '',
        leaderName: '',
        type: TeamType.general,
        status: TeamStatus.active,
        workers: [],
        assignedProjectIds: [],
        createdAt: DateTime.now(),
      );
}
