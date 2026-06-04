import 'package:equatable/equatable.dart';
import 'attendance_model.dart';
import 'labor_model.dart';

enum PayrollStatus { draft, approved, paid }

// ── Payroll Line Item ─────────────────────────────────────────────────────────

class PayrollLineItem extends Equatable {
  final String laborId;
  final String laborName;
  final String role;
  final int daysPresent;
  final int daysAbsent;
  final int halfDays;
  final double overtimeHours;
  final double dailyWage;       // snapshot at generation time
  final double baseAmount;
  final double overtimeAmount;
  final double deductions;
  final double netAmount;
  final bool isPaid;

  const PayrollLineItem({
    required this.laborId,
    required this.laborName,
    required this.role,
    required this.daysPresent,
    required this.daysAbsent,
    required this.halfDays,
    required this.overtimeHours,
    required this.dailyWage,
    required this.baseAmount,
    required this.overtimeAmount,
    this.deductions = 0,
    required this.netAmount,
    this.isPaid = false,
  });

  /// Calculate from attendance records
  static PayrollLineItem fromAttendance({
    required LaborModel labor,
    required List<AttendanceModel> weekRecords,
  }) {
    final present  = weekRecords.where((r) => r.isPresent || r.isOvertime).length;
    final absent   = weekRecords.where((r) => r.isAbsent).length;
    final halfDays = weekRecords.where((r) => r.isHalfDay).length;
    final otHours  = weekRecords.fold(0.0, (sum, r) => sum + r.overtimeHours);

    final effectiveDays = present + (halfDays * 0.5);
    final baseAmount    = labor.dailyWage * effectiveDays;
    final otAmount      = otHours * labor.effectiveOvertimeRate;

    return PayrollLineItem(
      laborId: labor.id,
      laborName: labor.fullName,
      role: labor.role,
      daysPresent: present,
      daysAbsent: absent,
      halfDays: halfDays,
      overtimeHours: otHours,
      dailyWage: labor.dailyWage,
      baseAmount: baseAmount,
      overtimeAmount: otAmount,
      deductions: 0,
      netAmount: baseAmount + otAmount,
    );
  }

  factory PayrollLineItem.fromJson(Map<String, dynamic> json) =>
      PayrollLineItem(
        laborId: json['labor_id'] as String,
        laborName: json['labor_name'] as String,
        role: json['role'] as String,
        daysPresent: json['days_present'] as int,
        daysAbsent: json['days_absent'] as int,
        halfDays: json['half_days'] as int,
        overtimeHours: (json['overtime_hours'] as num).toDouble(),
        dailyWage: (json['daily_wage'] as num).toDouble(),
        baseAmount: (json['base_amount'] as num).toDouble(),
        overtimeAmount: (json['overtime_amount'] as num).toDouble(),
        deductions: (json['deductions'] as num?)?.toDouble() ?? 0,
        netAmount: (json['net_amount'] as num).toDouble(),
        isPaid: json['is_paid'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'labor_id': laborId,
        'labor_name': laborName,
        'role': role,
        'days_present': daysPresent,
        'days_absent': daysAbsent,
        'half_days': halfDays,
        'overtime_hours': overtimeHours,
        'daily_wage': dailyWage,
        'base_amount': baseAmount,
        'overtime_amount': overtimeAmount,
        'deductions': deductions,
        'net_amount': netAmount,
        'is_paid': isPaid,
      };

  @override
  List<Object?> get props => [laborId, daysPresent, netAmount];
}

// ── Payroll Week ──────────────────────────────────────────────────────────────

class PayrollWeekModel extends Equatable {
  final String id;
  final String projectId;
  final DateTime weekStart;     // Saturday
  final DateTime weekEnd;       // Thursday (6 working days)
  final int workingDays;
  final PayrollStatus status;
  final double totalAmount;
  final String currencyCode;
  final List<PayrollLineItem> lineItems;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? paidBy;
  final DateTime? paidAt;
  final String? paymentMethod;
  final String? notes;

  const PayrollWeekModel({
    required this.id,
    required this.projectId,
    required this.weekStart,
    required this.weekEnd,
    this.workingDays = 6,
    this.status = PayrollStatus.draft,
    required this.totalAmount,
    this.currencyCode = 'PKR',
    this.lineItems = const [],
    this.approvedBy,
    this.approvedAt,
    this.paidBy,
    this.paidAt,
    this.paymentMethod,
    this.notes,
  });

  bool get isDraft    => status == PayrollStatus.draft;
  bool get isApproved => status == PayrollStatus.approved;
  bool get isPaid     => status == PayrollStatus.paid;

  String get weekLabel {
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final s = weekStart;
    final e = weekEnd;
    if (s.month == e.month) {
      return '${s.day}–${e.day} ${months[s.month - 1]} ${s.year}';
    }
    return '${s.day} ${months[s.month - 1]} – ${e.day} ${months[e.month - 1]} ${s.year}';
  }

  /// Generate a payroll week from attendance records
  static PayrollWeekModel generate({
    required String id,
    required String projectId,
    required DateTime weekStart,
    required List<LaborModel> laborList,
    required Map<String, List<AttendanceModel>> attendanceByLabor,
    String currencyCode = 'PKR',
  }) {
    final weekEnd = weekStart.add(const Duration(days: 5)); // Sat + 5 = Thu

    final lineItems = laborList
        .where((l) => l.isActive)
        .map((labor) {
          final records = attendanceByLabor[labor.id] ??
              List.generate(
                6,
                (i) => AttendanceModel.absent(
                  laborId: labor.id,
                  projectId: projectId,
                  date: weekStart.add(Duration(days: i)),
                ),
              );
          return PayrollLineItem.fromAttendance(
            labor: labor,
            weekRecords: records,
          );
        })
        .toList();

    final total = lineItems.fold(0.0, (sum, li) => sum + li.netAmount);

    return PayrollWeekModel(
      id: id,
      projectId: projectId,
      weekStart: weekStart,
      weekEnd: weekEnd,
      workingDays: 6,
      status: PayrollStatus.draft,
      totalAmount: total,
      currencyCode: currencyCode,
      lineItems: lineItems,
    );
  }

  PayrollWeekModel copyWith({PayrollStatus? status, String? approvedBy, DateTime? approvedAt, String? paidBy, DateTime? paidAt, String? paymentMethod}) {
    return PayrollWeekModel(
      id: id,
      projectId: projectId,
      weekStart: weekStart,
      weekEnd: weekEnd,
      workingDays: workingDays,
      status: status ?? this.status,
      totalAmount: totalAmount,
      currencyCode: currencyCode,
      lineItems: lineItems,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      paidBy: paidBy ?? this.paidBy,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes,
    );
  }

  factory PayrollWeekModel.fromJson(Map<String, dynamic> json) =>
      PayrollWeekModel(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        weekStart: DateTime.parse(json['week_start'] as String),
        weekEnd: DateTime.parse(json['week_end'] as String),
        workingDays: json['working_days'] as int? ?? 6,
        status: PayrollStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => PayrollStatus.draft,
        ),
        totalAmount: (json['total_amount'] as num).toDouble(),
        currencyCode: json['currency_code'] as String? ?? 'PKR',
        lineItems: (json['line_items'] as List<dynamic>?)
                ?.map((l) =>
                    PayrollLineItem.fromJson(l as Map<String, dynamic>))
                .toList() ??
            [],
        approvedBy: json['approved_by'] as String?,
        approvedAt: json['approved_at'] != null
            ? DateTime.parse(json['approved_at'] as String)
            : null,
        paidBy: json['paid_by'] as String?,
        paidAt: json['paid_at'] != null
            ? DateTime.parse(json['paid_at'] as String)
            : null,
        paymentMethod: json['payment_method'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'week_start': weekStart.toIso8601String(),
        'week_end': weekEnd.toIso8601String(),
        'working_days': workingDays,
        'status': status.name,
        'total_amount': totalAmount,
        'currency_code': currencyCode,
        'line_items': lineItems.map((l) => l.toJson()).toList(),
        'approved_by': approvedBy,
        'approved_at': approvedAt?.toIso8601String(),
        'paid_by': paidBy,
        'paid_at': paidAt?.toIso8601String(),
        'payment_method': paymentMethod,
        'notes': notes,
      };

  @override
  List<Object?> get props => [id, status, totalAmount];
}
