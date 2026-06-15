import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../labor/data/models/attendance_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../data/models/team_model.dart';

class TeamAttendanceController extends GetxController {
  final TeamModel team;
  late final List<TeamWorkerModel> _workers;

  TeamAttendanceController({required this.team}) {
    _workers = team.workers.where((w) => w.isActive).toList();
  }

  List<TeamWorkerModel> get workers => _workers;

  final isLoading    = false.obs;
  final isSubmitting = false.obs;

  late final selectedWeekStart = _currentWeekSaturday().obs;
  final _attendance = <String, Map<String, AttendanceModel>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    _initWeekAttendance();
    isLoading.value = false;
  }

  // ── Week navigation ───────────────────────────────────────────────────────

  DateTime get weekEnd => selectedWeekStart.value.add(const Duration(days: 5));

  List<DateTime> get weekDays =>
      List.generate(6, (i) => selectedWeekStart.value.add(Duration(days: i)));

  static const List<String> dayHeaders = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'];

  void prevWeek() {
    selectedWeekStart.value =
        selectedWeekStart.value.subtract(const Duration(days: 7));
    _initWeekAttendance();
  }

  void nextWeek() {
    final next = selectedWeekStart.value.add(const Duration(days: 7));
    if (next.isAfter(DateTime.now())) return;
    selectedWeekStart.value = next;
    _initWeekAttendance();
  }

  bool get canGoNext =>
      selectedWeekStart.value.add(const Duration(days: 7)).isBefore(DateTime.now());

  // ── Attendance data ───────────────────────────────────────────────────────

  void _initWeekAttendance() {
    for (final w in _workers) {
      _attendance.putIfAbsent(w.id, () => {});
      for (final day in weekDays) {
        _attendance[w.id]!.putIfAbsent(
          _dateKey(day),
          () => AttendanceModel.absent(
            laborId: w.id,
            projectId: 'team_${team.id}',
            date: day,
          ),
        );
      }
    }
    _attendance.refresh();
  }

  AttendanceModel getRecord(String workerId, DateTime date) =>
      _attendance[workerId]?[_dateKey(date)] ??
      AttendanceModel.absent(
        laborId: workerId,
        projectId: 'team_${team.id}',
        date: date,
      );

  void cycleStatus(String workerId, DateTime date) {
    final cur  = getRecord(workerId, date);
    final next = cur.nextStatus;
    _updateRecord(
      workerId, date,
      cur.copyWith(
        status: next,
        overtimeHours: next == AttendanceStatus.overtime ? 2.0 : 0,
      ),
    );
  }

  double? setOvertimeHours(String workerId, DateTime date, double hours) {
    if (hours < 0) return null;
    final clamped = hours.clamp(0.0, kMaxOvertimeHoursPerDay);
    _updateRecord(
      workerId, date,
      getRecord(workerId, date).copyWith(
        status: AttendanceStatus.overtime,
        overtimeHours: clamped,
      ),
    );
    return clamped;
  }

  void _updateRecord(String workerId, DateTime date, AttendanceModel rec) {
    _attendance[workerId] ??= {};
    _attendance[workerId]![_dateKey(date)] = rec;
    _attendance.refresh();
  }

  // ── Bulk actions ──────────────────────────────────────────────────────────

  void markAllPresent() {
    final today = DateTime.now();
    for (final w in _workers) {
      _updateRecord(
        w.id, today,
        getRecord(w.id, today).copyWith(
          status: AttendanceStatus.present, overtimeHours: 0),
      );
    }
  }

  void markAllAbsent() {
    final today = DateTime.now();
    for (final w in _workers) {
      _updateRecord(
        w.id, today,
        getRecord(w.id, today).copyWith(
          status: AttendanceStatus.absent, overtimeHours: 0),
      );
    }
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  int get totalWorkers => _workers.length;

  int get presentToday {
    final today = _dateKey(DateTime.now());
    return _workers.where((w) {
      final r = _attendance[w.id]?[today];
      return r != null && (r.isPresent || r.isOvertime || r.isHalfDay);
    }).length;
  }

  double workerWeeklyEarnings(TeamWorkerModel worker) {
    double days = 0;
    double otH  = 0;
    for (final d in weekDays) {
      final r = getRecord(worker.id, d);
      days += r.effectiveDays;
      otH  += r.overtimeHours;
    }
    final overtimeRate = (worker.dailyWage / 8) * 1.5;
    return worker.dailyWage * days + overtimeRate * otH;
  }

  double get weeklyTotal =>
      _workers.fold(0.0, (s, w) => s + workerWeeklyEarnings(w));

  String get formattedWeeklyTotal => CurrencyFormatter.formatPKR(weeklyTotal);

  int workerPresentDays(TeamWorkerModel w) => weekDays.where((d) {
        final r = getRecord(w.id, d);
        return r.isPresent || r.isOvertime;
      }).length;

  int workerAbsentDays(TeamWorkerModel w) =>
      weekDays.where((d) => getRecord(w.id, d).isAbsent).length;

  int workerHalfDays(TeamWorkerModel w) =>
      weekDays.where((d) => getRecord(w.id, d).isHalfDay).length;

  int get totalPresentDays =>
      _workers.fold(0, (s, w) => s + workerPresentDays(w));
  int get totalAbsentDays =>
      _workers.fold(0, (s, w) => s + workerAbsentDays(w));
  int get totalHalfDays =>
      _workers.fold(0, (s, w) => s + workerHalfDays(w));

  static const double kMaxOvertimeHoursPerDay = 12.0;

  Future<void> submitAttendance() async {
    isSubmitting.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isSubmitting.value = false;
    Get.snackbar(
      'Attendance Saved',
      '${team.name} attendance submitted successfully',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _currentWeekSaturday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - (now.weekday + 1) % 7);
  }
}
