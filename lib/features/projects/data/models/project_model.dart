import 'package:equatable/equatable.dart';
import 'project_scope_model.dart';
import 'stage_model.dart';

class ProjectModel extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String status;       // draft, active, on_hold, completed, cancelled
  final String priority;     // high, medium, low

  // Location
  final int? countryId;
  final int? cityId;
  final int? areaId;
  final String? cityName;    // denormalized for display
  final String? areaName;    // denormalized for display
  final String? address;

  // Budget
  final double budgetAmount;
  final double estimatedCost;
  final double actualCost;
  final double contingencyPct;
  final String currencyCode;

  // Timeline
  final DateTime? startDate;
  final DateTime? targetEndDate;
  final DateTime? actualEndDate;

  // Contractor
  final String? contractorType;  // self, local, company
  final String? contractorId;
  final String? contractorName;  // denormalized

  // Scopes (this is the main content)
  final List<ProjectScopeModel> scopes;

  // Metrics (computed, refreshed on load)
  final int healthScore;
  final double completionPct;

  // Display
  final String? coverPhotoUrl;
  final int photoCount;
  final int workerCount;
  final DateTime? lastUpdated;

  const ProjectModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.status = 'active',
    this.priority = 'medium',
    this.countryId,
    this.cityId,
    this.areaId,
    this.cityName,
    this.areaName,
    this.address,
    this.budgetAmount = 0,
    this.estimatedCost = 0,
    this.actualCost = 0,
    this.contingencyPct = 10,
    this.currencyCode = 'PKR',
    this.startDate,
    this.targetEndDate,
    this.actualEndDate,
    this.contractorType,
    this.contractorId,
    this.contractorName,
    this.scopes = const [],
    this.healthScore = 100,
    this.completionPct = 0,
    this.coverPhotoUrl,
    this.photoCount = 0,
    this.workerCount = 0,
    this.lastUpdated,
  });

  // ── Computed ──────────────────────────────────────────────────────────────

  double get budgetProgress =>
      budgetAmount > 0 ? actualCost / budgetAmount : 0;
  double get remainingBudget => budgetAmount - actualCost;
  double get budgetVariance  => budgetAmount - estimatedCost;

  int get weeksLeft {
    if (targetEndDate == null) return 0;
    return targetEndDate!.difference(DateTime.now()).inDays ~/ 7;
  }

  bool get isActive    => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isOnHold    => status == 'on_hold';

  bool get isLate    => targetEndDate != null &&
      DateTime.now().isAfter(targetEndDate!) && !isCompleted;
  bool get isAtRisk  => !isLate && weeksLeft >= 0 && weeksLeft <= 4;
  bool get isOnTrack => !isLate && !isAtRisk && isActive;

  String get statusLabel {
    if (isLate) return 'LATE';
    if (isAtRisk) return 'AT RISK';
    if (status == 'active') return 'ON TRACK';
    return status.toUpperCase().replaceAll('_', ' ');
  }

  // ── Backward-compat helpers (used by existing screens) ────────────────────

  /// Primary scope for display when multi-scope not needed
  ProjectScopeModel? get primaryScope =>
      scopes.isNotEmpty ? scopes.first : null;

  String get type => primaryScope?.projectType ?? 'house';

  String get city => cityName ?? '';
  String get area => areaName ?? '';

  /// Legacy: "10 Marla" or "5 Marla" — used by existing UI
  String get plotSize {
    final sqm = primaryScope?.plotSizeSqm;
    if (sqm == null) return '';
    final marla = sqm / 25.2929;
    if (marla >= 20) {
      return '${(marla / 20).toStringAsFixed(1)} Kanal';
    }
    return '${marla.toStringAsFixed(0)} Marla';
  }

  double get totalBudget  => budgetAmount;
  double get spentBudget  => actualCost;
  double get progress     => completionPct / 100;

  DateTime get estimatedEndDate => targetEndDate ?? DateTime.now();

  String get currentStage {
    for (final scope in scopes) {
      final active = scope.activeStage;
      if (active != null) return active.name;
    }
    return '';
  }

  List<StageModel> get stages =>
      scopes.expand((s) => s.stages).toList()
        ..sort((a, b) => a.stageOrder.compareTo(b.stageOrder));

  // ── CopyWith ──────────────────────────────────────────────────────────────

  ProjectModel copyWith({
    String? status,
    double? actualCost,
    double? completionPct,
    int? healthScore,
    List<ProjectScopeModel>? scopes,
    String? coverPhotoUrl,
    DateTime? lastUpdated,
  }) {
    return ProjectModel(
      id: id,
      ownerId: ownerId,
      name: name,
      status: status ?? this.status,
      priority: priority,
      countryId: countryId,
      cityId: cityId,
      areaId: areaId,
      cityName: cityName,
      areaName: areaName,
      address: address,
      budgetAmount: budgetAmount,
      estimatedCost: estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      contingencyPct: contingencyPct,
      currencyCode: currencyCode,
      startDate: startDate,
      targetEndDate: targetEndDate,
      actualEndDate: actualEndDate,
      contractorType: contractorType,
      contractorId: contractorId,
      contractorName: contractorName,
      scopes: scopes ?? this.scopes,
      healthScore: healthScore ?? this.healthScore,
      completionPct: completionPct ?? this.completionPct,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      photoCount: photoCount,
      workerCount: workerCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // ── JSON ──────────────────────────────────────────────────────────────────

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'] as String,
        ownerId: json['owner_id'] as String? ?? '',
        name: json['name'] as String,
        status: json['status'] as String? ?? 'active',
        priority: json['priority'] as String? ?? 'medium',
        countryId: json['country_id'] as int?,
        cityId: json['city_id'] as int?,
        areaId: json['area_id'] as int?,
        cityName: json['city_name'] as String? ?? json['city'] as String?,
        areaName: json['area_name'] as String? ?? json['area'] as String?,
        address: json['address'] as String?,
        budgetAmount: (json['budget_amount'] as num?)?.toDouble() ??
            (json['total_budget'] as num?)?.toDouble() ?? 0,
        estimatedCost: (json['estimated_cost'] as num?)?.toDouble() ?? 0,
        actualCost: (json['actual_cost'] as num?)?.toDouble() ??
            (json['spent_budget'] as num?)?.toDouble() ?? 0,
        contingencyPct: (json['contingency_pct'] as num?)?.toDouble() ?? 10,
        currencyCode: json['currency_code'] as String? ?? 'PKR',
        startDate: json['start_date'] != null
            ? DateTime.parse(json['start_date'] as String)
            : null,
        targetEndDate: json['target_end_date'] != null
            ? DateTime.parse(json['target_end_date'] as String)
            : json['estimated_end_date'] != null
                ? DateTime.parse(json['estimated_end_date'] as String)
                : null,
        actualEndDate: json['actual_end_date'] != null
            ? DateTime.parse(json['actual_end_date'] as String)
            : null,
        contractorType: json['contractor_type'] as String?,
        contractorId: json['contractor_id'] as String?,
        contractorName: json['contractor_name'] as String?,
        scopes: (json['scopes'] as List<dynamic>?)
                ?.map((s) =>
                    ProjectScopeModel.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        healthScore: json['health_score'] as int? ?? 100,
        completionPct: (json['completion_pct'] as num?)?.toDouble() ??
            ((json['progress'] as num?)?.toDouble() ?? 0) * 100,
        coverPhotoUrl: json['cover_photo_url'] as String?,
        photoCount: json['photo_count'] as int? ?? 0,
        workerCount: json['worker_count'] as int? ?? 0,
        lastUpdated: json['last_updated'] != null
            ? DateTime.parse(json['last_updated'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': ownerId,
        'name': name,
        'status': status,
        'priority': priority,
        'country_id': countryId,
        'city_id': cityId,
        'area_id': areaId,
        'city_name': cityName,
        'area_name': areaName,
        'address': address,
        'budget_amount': budgetAmount,
        'estimated_cost': estimatedCost,
        'actual_cost': actualCost,
        'contingency_pct': contingencyPct,
        'currency_code': currencyCode,
        'start_date': startDate?.toIso8601String(),
        'target_end_date': targetEndDate?.toIso8601String(),
        'actual_end_date': actualEndDate?.toIso8601String(),
        'contractor_type': contractorType,
        'contractor_id': contractorId,
        'contractor_name': contractorName,
        'scopes': scopes.map((s) => s.toJson()).toList(),
        'health_score': healthScore,
        'completion_pct': completionPct,
        'cover_photo_url': coverPhotoUrl,
        'photo_count': photoCount,
        'worker_count': workerCount,
        'last_updated': lastUpdated?.toIso8601String(),
      };

  // ── Mock data ─────────────────────────────────────────────────────────────

  static List<ProjectModel> mockList() => [
        ProjectModel(
          id: 'p1',
          ownerId: 'u1',
          name: 'DHA House — 10 Marla',
          status: 'active',
          priority: 'high',
          cityId: 101,
          cityName: 'Lahore',
          areaName: 'DHA Phase 6',
          budgetAmount: 8500000,
          estimatedCost: 8200000,
          actualCost: 3400000,
          currencyCode: 'PKR',
          startDate: DateTime(2026, 1, 12),
          targetEndDate: DateTime(2027, 3, 10),
          contractorType: 'local',
          contractorName: 'Malik Construction',
          healthScore: 82,
          completionPct: 38,
          photoCount: 48,
          workerCount: 15,
          lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
          scopes: [
            ProjectScopeModel(
              id: 'sc1',
              projectId: 'p1',
              name: 'Main House',
              projectType: 'house',
              qualityTier: 'standard',
              plotSizeSqm: 505.857, // 20 Marla / 1 Kanal = 505 sqm
              constructionAreaSqm: 454.0,
              floors: 2,
              budgetAmount: 8500000,
              estimatedCost: 8200000,
              actualCost: 3400000,
              completionPct: 38,
              currencyCode: 'PKR',
              startDate: DateTime(2026, 1, 12),
              targetEndDate: DateTime(2027, 3, 10),
            ),
          ],
        ),
        ProjectModel(
          id: 'p2',
          ownerId: 'u1',
          name: 'Bahria Heights — Block C',
          status: 'active',
          priority: 'medium',
          cityId: 101,
          cityName: 'Lahore',
          areaName: 'Bahria Town',
          budgetAmount: 18000000,
          estimatedCost: 17500000,
          actualCost: 12960000,
          currencyCode: 'PKR',
          startDate: DateTime(2026, 1, 1),
          targetEndDate: DateTime(2026, 11, 1),
          contractorType: 'company',
          contractorName: 'Arif Associates',
          healthScore: 61,
          completionPct: 72,
          workerCount: 22,
          lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
          scopes: [
            ProjectScopeModel(
              id: 'sc2',
              projectId: 'p2',
              name: 'Commercial Plaza',
              projectType: 'commercial',
              qualityTier: 'premium',
              plotSizeSqm: 505.857,
              constructionAreaSqm: 1517.0,
              floors: 3,
              budgetAmount: 18000000,
              estimatedCost: 17500000,
              actualCost: 12960000,
              completionPct: 72,
              currencyCode: 'PKR',
              startDate: DateTime(2026, 1, 1),
              targetEndDate: DateTime(2026, 11, 1),
            ),
          ],
        ),
        ProjectModel(
          id: 'p3',
          ownerId: 'u1',
          name: 'Khan Villa Renovation',
          status: 'active',
          priority: 'low',
          cityId: 101,
          cityName: 'Lahore',
          areaName: 'Gulberg III',
          budgetAmount: 3800000,
          estimatedCost: 3600000,
          actualCost: 3344000,
          currencyCode: 'PKR',
          startDate: DateTime(2026, 2, 1),
          targetEndDate: DateTime(2026, 8, 1),
          contractorType: 'local',
          contractorName: 'Rana Brothers',
          healthScore: 91,
          completionPct: 88,
          workerCount: 8,
          lastUpdated:
              DateTime.now().subtract(const Duration(days: 1)),
          scopes: [
            ProjectScopeModel(
              id: 'sc3',
              projectId: 'p3',
              name: 'Interior Renovation',
              projectType: 'renovation',
              qualityTier: 'standard',
              constructionAreaSqm: 252.9,
              floors: 1,
              budgetAmount: 3800000,
              estimatedCost: 3600000,
              actualCost: 3344000,
              completionPct: 88,
              currencyCode: 'PKR',
              startDate: DateTime(2026, 2, 1),
              targetEndDate: DateTime(2026, 8, 1),
            ),
          ],
        ),
      ];

  @override
  List<Object?> get props => [id, status, completionPct, actualCost];
}
