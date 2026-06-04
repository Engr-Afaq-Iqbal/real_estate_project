import 'package:get/get.dart';
import '../data/models/payroll_model.dart';
import '../data/models/labor_model.dart';
import '../data/models/attendance_model.dart';
import '../../../core/utils/currency_formatter.dart';
import 'attendance_controller.dart';
import 'labor_list_controller.dart';
import 'package:uuid/uuid.dart';

const _uuidPay = Uuid();

class PayrollController extends GetxController {
  final isLoading       = false.obs;
  final isGenerating    = false.obs;
  final payrollWeeks    = <PayrollWeekModel>[].obs;
  final selectedWeek    = Rxn<PayrollWeekModel>();
  String _projectId     = 'p1';

  @override
  void onInit() {
    super.onInit();
    _projectId = Get.arguments is String ? Get.arguments as String : 'p1';
    _loadPayroll();
  }

  Future<void> _loadPayroll() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    // No existing payroll weeks for mock — start empty
    payrollWeeks.value = [];
    isLoading.value = false;
  }

  // ── Generate payroll for current week ─────────────────────────────────────

  Future<PayrollWeekModel?> generateCurrentWeek() async {
    isGenerating.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    List<LaborModel> labor = [];
    Map<String, List<AttendanceModel>> attendance = {};

    try {
      final laborCtrl = Get.find<LaborListController>();
      labor = laborCtrl.activeLabor;
    } catch (_) {
      labor = LaborModel.mockList(_projectId);
    }

    try {
      final attCtrl = Get.find<AttendanceController>();
      for (final l in labor) {
        attendance[l.id] = attCtrl.weekDays
            .map((day) => attCtrl.getRecord(l.id, day))
            .toList();
      }
    } catch (_) {
      // No attendance controller — all absent
    }

    final weekStart = _currentWeekSaturday();
    final week = PayrollWeekModel.generate(
      id: _uuidPay.v4(),
      projectId: _projectId,
      weekStart: weekStart,
      laborList: labor,
      attendanceByLabor: attendance,
      currencyCode: 'PKR',
    );

    payrollWeeks.insert(0, week);
    selectedWeek.value = week;
    isGenerating.value = false;
    return week;
  }

  // ── Approve & pay ─────────────────────────────────────────────────────────

  Future<void> approveWeek(String weekId) async {
    final idx = payrollWeeks.indexWhere((w) => w.id == weekId);
    if (idx == -1) return;
    payrollWeeks[idx] = payrollWeeks[idx].copyWith(
      status: PayrollStatus.approved,
      approvedBy: 'current_user',
      approvedAt: DateTime.now(),
    );
    if (selectedWeek.value?.id == weekId) {
      selectedWeek.value = payrollWeeks[idx];
    }
    payrollWeeks.refresh();
    Get.snackbar('Approved', 'Payroll week approved');
  }

  Future<void> markAsPaid(String weekId, String paymentMethod) async {
    final idx = payrollWeeks.indexWhere((w) => w.id == weekId);
    if (idx == -1) return;
    payrollWeeks[idx] = payrollWeeks[idx].copyWith(
      status: PayrollStatus.paid,
      paidBy: 'current_user',
      paidAt: DateTime.now(),
      paymentMethod: paymentMethod,
    );
    if (selectedWeek.value?.id == weekId) {
      selectedWeek.value = payrollWeeks[idx];
    }
    payrollWeeks.refresh();
    Get.snackbar('Paid', 'Payroll marked as paid');
  }

  // ── Summary stats ─────────────────────────────────────────────────────────

  double get totalPaidThisProject {
    return payrollWeeks
        .where((w) => w.isPaid)
        .fold(0.0, (sum, w) => sum + w.totalAmount);
  }

  String get formattedTotalPaid =>
      CurrencyFormatter.formatCompact(totalPaidThisProject);

  int get unpaidWeeksCount =>
      payrollWeeks.where((w) => !w.isPaid).length;

  static DateTime _currentWeekSaturday() {
    final now = DateTime.now();
    final daysToSaturday = (now.weekday + 1) % 7;
    return DateTime(now.year, now.month, now.day - daysToSaturday);
  }
}
