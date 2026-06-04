import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, absent, halfDay, overtime, leave }

class AttendanceModel extends Equatable {
  final String id;
  final String laborId;
  final String projectId;
  final DateTime attendanceDate;
  final AttendanceStatus status;
  final double overtimeHours;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String? markedBy;
  final String? notes;

  const AttendanceModel({
    required this.id,
    required this.laborId,
    required this.projectId,
    required this.attendanceDate,
    this.status = AttendanceStatus.absent,
    this.overtimeHours = 0,
    this.checkIn,
    this.checkOut,
    this.markedBy,
    this.notes,
  });

  // ── Computed ──────────────────────────────────────────────────────────────

  bool get isPresent  => status == AttendanceStatus.present;
  bool get isAbsent   => status == AttendanceStatus.absent;
  bool get isHalfDay  => status == AttendanceStatus.halfDay;
  bool get isOvertime => status == AttendanceStatus.overtime;
  bool get isLeave    => status == AttendanceStatus.leave;

  /// Effective days worked: present=1, half_day=0.5, overtime=1, absent=0
  double get effectiveDays => switch (status) {
        AttendanceStatus.present  => 1.0,
        AttendanceStatus.overtime => 1.0,
        AttendanceStatus.halfDay  => 0.5,
        AttendanceStatus.absent   => 0.0,
        AttendanceStatus.leave    => 0.0,
      };

  String get statusLabel => switch (status) {
        AttendanceStatus.present  => 'P',
        AttendanceStatus.absent   => 'A',
        AttendanceStatus.halfDay  => '½',
        AttendanceStatus.overtime => 'OT',
        AttendanceStatus.leave    => 'L',
      };

  String get statusFullLabel => switch (status) {
        AttendanceStatus.present  => 'Present',
        AttendanceStatus.absent   => 'Absent',
        AttendanceStatus.halfDay  => 'Half Day',
        AttendanceStatus.overtime => 'Overtime',
        AttendanceStatus.leave    => 'Leave',
      };

  /// Cycle to next status (for tap-to-cycle UI)
  AttendanceStatus get nextStatus => switch (status) {
        AttendanceStatus.absent   => AttendanceStatus.present,
        AttendanceStatus.present  => AttendanceStatus.halfDay,
        AttendanceStatus.halfDay  => AttendanceStatus.overtime,
        AttendanceStatus.overtime => AttendanceStatus.absent,
        AttendanceStatus.leave    => AttendanceStatus.absent,
      };

  // ── CopyWith ──────────────────────────────────────────────────────────────

  AttendanceModel copyWith({
    AttendanceStatus? status,
    double? overtimeHours,
    String? notes,
  }) {
    return AttendanceModel(
      id: id,
      laborId: laborId,
      projectId: projectId,
      attendanceDate: attendanceDate,
      status: status ?? this.status,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      checkIn: checkIn,
      checkOut: checkOut,
      markedBy: markedBy,
      notes: notes ?? this.notes,
    );
  }

  /// Creates an absent record as the default for unrecorded days
  static AttendanceModel absent({
    required String laborId,
    required String projectId,
    required DateTime date,
  }) {
    return AttendanceModel(
      id: '${laborId}_${date.toIso8601String().substring(0, 10)}',
      laborId: laborId,
      projectId: projectId,
      attendanceDate: date,
      status: AttendanceStatus.absent,
    );
  }

  // ── JSON ──────────────────────────────────────────────────────────────────

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        id: json['id'] as String,
        laborId: json['labor_id'] as String,
        projectId: json['project_id'] as String,
        attendanceDate: DateTime.parse(json['attendance_date'] as String),
        status: AttendanceStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => AttendanceStatus.absent,
        ),
        overtimeHours: (json['overtime_hours'] as num?)?.toDouble() ?? 0,
        markedBy: json['marked_by'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'labor_id': laborId,
        'project_id': projectId,
        'attendance_date': attendanceDate.toIso8601String().substring(0, 10),
        'status': status.name,
        'overtime_hours': overtimeHours,
        'marked_by': markedBy,
        'notes': notes,
      };

  @override
  List<Object?> get props => [id, status, overtimeHours];
}
