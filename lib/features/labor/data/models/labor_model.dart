import 'package:equatable/equatable.dart';

enum LaborStatus { active, inactive, released }

class LaborModel extends Equatable {
  final String id;
  final String projectId;
  final String? userId;       // if worker has app account

  final String fullName;
  final String? phone;
  final String? cnic;
  final String role;          // 'Mason', 'Helper', 'Electrician', etc.
  final String? trade;        // normalized: mason, helper, electrician, plumber, carpenter, painter
  final String? photoUrl;

  final double dailyWage;
  final String currencyCode;
  final String wageType;      // daily, weekly, fixed, per_unit
  final double? overtimeRate; // per hour; null = dailyWage/8 * 1.5

  final LaborStatus status;
  final DateTime? joinDate;
  final DateTime? releaseDate;

  final String? emergencyContact;
  final String? emergencyPhone;
  final String? notes;

  const LaborModel({
    required this.id,
    required this.projectId,
    this.userId,
    required this.fullName,
    this.phone,
    this.cnic,
    required this.role,
    this.trade,
    this.photoUrl,
    required this.dailyWage,
    this.currencyCode = 'PKR',
    this.wageType = 'daily',
    this.overtimeRate,
    this.status = LaborStatus.active,
    this.joinDate,
    this.releaseDate,
    this.emergencyContact,
    this.emergencyPhone,
    this.notes,
  });

  // ── Computed ──────────────────────────────────────────────────────────────

  bool get isActive   => status == LaborStatus.active;
  bool get isReleased => status == LaborStatus.released;

  /// Effective overtime hourly rate
  double get effectiveOvertimeRate =>
      overtimeRate ?? (dailyWage / 8) * 1.5;

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  static const List<String> roles = [
    'Mason',
    'Mason (Lead)',
    'Helper',
    'Electrician',
    'Plumber',
    'Carpenter',
    'Painter',
    'Iron Worker',
    'Tile Worker',
    'Welder',
    'Crane Operator',
    'Security Guard',
    'Site Engineer',
    'Supervisor',
    'Driver',
    'Other',
  ];

  // ── CopyWith ──────────────────────────────────────────────────────────────

  LaborModel copyWith({
    double? dailyWage,
    LaborStatus? status,
    DateTime? releaseDate,
    String? notes,
  }) {
    return LaborModel(
      id: id,
      projectId: projectId,
      userId: userId,
      fullName: fullName,
      phone: phone,
      cnic: cnic,
      role: role,
      trade: trade,
      photoUrl: photoUrl,
      dailyWage: dailyWage ?? this.dailyWage,
      currencyCode: currencyCode,
      wageType: wageType,
      overtimeRate: overtimeRate,
      status: status ?? this.status,
      joinDate: joinDate,
      releaseDate: releaseDate ?? this.releaseDate,
      emergencyContact: emergencyContact,
      emergencyPhone: emergencyPhone,
      notes: notes ?? this.notes,
    );
  }

  // ── JSON ──────────────────────────────────────────────────────────────────

  factory LaborModel.fromJson(Map<String, dynamic> json) => LaborModel(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        userId: json['user_id'] as String?,
        fullName: json['full_name'] as String,
        phone: json['phone'] as String?,
        cnic: json['cnic'] as String?,
        role: json['role'] as String,
        trade: json['trade'] as String?,
        photoUrl: json['photo_url'] as String?,
        dailyWage: (json['daily_wage'] as num).toDouble(),
        currencyCode: json['currency_code'] as String? ?? 'PKR',
        wageType: json['wage_type'] as String? ?? 'daily',
        overtimeRate: (json['overtime_rate'] as num?)?.toDouble(),
        status: LaborStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => LaborStatus.active,
        ),
        joinDate: json['join_date'] != null
            ? DateTime.parse(json['join_date'] as String)
            : null,
        releaseDate: json['release_date'] != null
            ? DateTime.parse(json['release_date'] as String)
            : null,
        emergencyContact: json['emergency_contact'] as String?,
        emergencyPhone: json['emergency_phone'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'user_id': userId,
        'full_name': fullName,
        'phone': phone,
        'cnic': cnic,
        'role': role,
        'trade': trade,
        'photo_url': photoUrl,
        'daily_wage': dailyWage,
        'currency_code': currencyCode,
        'wage_type': wageType,
        'overtime_rate': overtimeRate,
        'status': status.name,
        'join_date': joinDate?.toIso8601String(),
        'release_date': releaseDate?.toIso8601String(),
        'emergency_contact': emergencyContact,
        'emergency_phone': emergencyPhone,
        'notes': notes,
      };

  // ── Mock data ─────────────────────────────────────────────────────────────

  static List<LaborModel> mockList(String projectId) => [
        LaborModel(
          id: 'l1', projectId: projectId,
          fullName: 'Bashir Ahmed', phone: '0300-1234567',
          role: 'Mason (Lead)', trade: 'mason',
          dailyWage: 3000, currencyCode: 'PKR',
          status: LaborStatus.active,
          joinDate: DateTime(2026, 1, 15),
        ),
        LaborModel(
          id: 'l2', projectId: projectId,
          fullName: 'Ramzan Ali', phone: '0301-2345678',
          role: 'Mason', trade: 'mason',
          dailyWage: 2500, currencyCode: 'PKR',
          status: LaborStatus.active,
          joinDate: DateTime(2026, 1, 15),
        ),
        LaborModel(
          id: 'l3', projectId: projectId,
          fullName: 'Sajid Khan', phone: '0302-3456789',
          role: 'Helper', trade: 'helper',
          dailyWage: 1800, currencyCode: 'PKR',
          status: LaborStatus.active,
          joinDate: DateTime(2026, 1, 20),
        ),
        LaborModel(
          id: 'l4', projectId: projectId,
          fullName: 'Nadeem Iqbal', phone: '0303-4567890',
          role: 'Electrician', trade: 'electrician',
          dailyWage: 3500, currencyCode: 'PKR',
          status: LaborStatus.active,
          joinDate: DateTime(2026, 2, 1),
        ),
        LaborModel(
          id: 'l5', projectId: projectId,
          fullName: 'Tariq Mehmood', phone: '0304-5678901',
          role: 'Plumber', trade: 'plumber',
          dailyWage: 3200, currencyCode: 'PKR',
          status: LaborStatus.active,
          joinDate: DateTime(2026, 2, 1),
        ),
        LaborModel(
          id: 'l6', projectId: projectId,
          fullName: 'Yousaf Saleem', phone: '0305-6789012',
          role: 'Helper', trade: 'helper',
          dailyWage: 1800, currencyCode: 'PKR',
          status: LaborStatus.active,
          joinDate: DateTime(2026, 2, 10),
        ),
      ];

  @override
  List<Object?> get props => [id, status, dailyWage];
}
