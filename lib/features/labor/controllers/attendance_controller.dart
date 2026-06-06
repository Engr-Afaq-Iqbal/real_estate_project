import 'package:get/get.dart';
import '../data/models/attendance_model.dart';
import '../data/models/labor_model.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:uuid/uuid.dart';

const _uuidAtt = Uuid();

class AttendanceController extends GetxController {
  final isLoading    = false.obs;
  final isSubmitting = false.obs;
  final laborList    = <LaborModel>[].obs;
  String _projectId  = 'p1';

  // Current week: starts on Saturday
  late final selectedWeekStart = _currentWeekSaturday().obs;

  // attendance map: laborId → { dateKey → AttendanceModel }
  final _attendance = <String, Map<String, AttendanceModel>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _projectId = Get.arguments is String ? Get.arguments as String : 'p1';
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    laborList.value = LaborModel.mockList(_projectId).where((l) => l.isActive).toList();
    _initWeekAttendance();
    isLoading.value = false;
  }

  // ── Week navigation ───────────────────────────────────────────────────────

  DateTime get weekEnd => selectedWeekStart.value.add(const Duration(days: 5));

  List<DateTime> get weekDays => List.generate(
        6,
        (i) => selectedWeekStart.value.add(Duration(days: i)),
      );

  static const List<String> dayHeaders = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'];

  void prevWeek() {
    selectedWeekStart.value =
        selectedWeekStart.value.subtract(const Duration(days: 7));
    _initWeekAttendance();
  }

  void nextWeek() {
    final next = selectedWeekStart.value.add(const Duration(days: 7));
    if (next.isAfter(DateTime.now())) return; // cannot go to future weeks
    selectedWeekStart.value = next;
    _initWeekAttendance();
  }

  bool get canGoNext =>
      selectedWeekStart.value.add(const Duration(days: 7)).isBefore(DateTime.now());

  // ── Attendance grid ───────────────────────────────────────────────────────

  void _initWeekAttendance() {
    for (final labor in laborList) {
      _attendance.putIfAbsent(labor.id, () => {});
      for (final day in weekDays) {
        final key = _dateKey(day);
        _attendance[labor.id]!.putIfAbsent(
          key,
          () => AttendanceModel.absent(
            laborId: labor.id,
            projectId: _projectId,
            date: day,
          ),
        );
      }
    }
    _attendance.refresh();
  }

  AttendanceModel getRecord(String laborId, DateTime date) {
    return _attendance[laborId]?[_dateKey(date)] ??
        AttendanceModel.absent(
          laborId: laborId,
          projectId: _projectId,
          date: date,
        );
  }

  /// Tap-to-cycle through statuses
  void cycleStatus(String laborId, DateTime date) {
    final current = getRecord(laborId, date);
    final next    = current.nextStatus;
    _updateRecord(
      laborId,
      date,
      current.copyWith(status: next, overtimeHours: next == AttendanceStatus.overtime ? 2.0 : 0),
    );
  }

  /// Sets OT hours, capped at [kMaxOvertimeHoursPerDay].
  /// Returns the actual hours set (clamped) or null if invalid.
  double? setOvertimeHours(String laborId, DateTime date, double hours) {
    if (hours < 0) return null;
    final clamped = hours.clamp(0.0, kMaxOvertimeHoursPerDay);
    final current = getRecord(laborId, date);
    _updateRecord(
      laborId,
      date,
      current.copyWith(
        status: AttendanceStatus.overtime,
        overtimeHours: clamped,
      ),
    );
    return clamped;
  }

  void _updateRecord(String laborId, DateTime date, AttendanceModel record) {
    _attendance[laborId] ??= {};
    _attendance[laborId]![_dateKey(date)] = record;
    _attendance.refresh();
  }

  // ── Summary stats ─────────────────────────────────────────────────────────

  int get totalWorkers => laborList.length;

  /// Count of workers present today
  int get presentToday {
    final today = _dateKey(DateTime.now());
    return laborList.where((l) {
      final rec = _attendance[l.id]?[today];
      return rec != null && (rec.isPresent || rec.isOvertime || rec.isHalfDay);
    }).length;
  }

  /// Total weekly wage for this week
  double get weeklyTotal {
    double total = 0;
    for (final labor in laborList) {
      double effectiveDays = 0;
      double otHours = 0;
      for (final day in weekDays) {
        final rec = getRecord(labor.id, day);
        effectiveDays += rec.effectiveDays;
        otHours += rec.overtimeHours;
      }
      total += labor.dailyWage * effectiveDays +
               labor.effectiveOvertimeRate * otHours;
    }
    return total;
  }

  String get formattedWeeklyTotal =>
      CurrencyFormatter.formatPKR(weeklyTotal);

  static const double kMaxOvertimeHoursPerDay = 12.0;

  // ── Submit attendance ─────────────────────────────────────────────────────

  Future<void> submitAttendance() async {
    isSubmitting.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isSubmitting.value = false;
    Get.snackbar('Attendance Saved', 'Week attendance submitted successfully');
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static DateTime _currentWeekSaturday() {
    final now     = DateTime.now();
    // weekday: Mon=1, Tue=2, ..., Sat=6, Sun=7
    final daysToSaturday = (now.weekday + 1) % 7; // distance back to last Saturday
    return DateTime(
      now.year, now.month,
      now.day - daysToSaturday,
    );
  }
}
