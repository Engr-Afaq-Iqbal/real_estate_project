import 'package:equatable/equatable.dart';
import 'stage_model.dart';

/// A scope is a self-contained unit of construction within a project.
/// A project can have multiple scopes:
///   Project: "Khan Family Properties"
///     Scope 1: "5-Marla House" (type: house)
///     Scope 2: "Boundary Wall"  (type: custom)
///     Scope 3: "Kitchen Reno"   (added later, type: kitchen)
class ProjectScopeModel extends Equatable {
  final String id;
  final String projectId;
  final String name;
  final String projectType;   // house, villa, commercial, renovation, etc.
  final String qualityTier;   // economy, standard, premium, luxury
  final String status;        // active, completed, on_hold, cancelled
  final int scopeOrder;

  // Measurements — stored as sq_meters internally
  final double? plotSizeSqm;
  final double? constructionAreaSqm;
  final double? plotWidthM;
  final double? plotDepthM;
  final int floors;
  final bool hasBasement;
  final String structureType;   // rcc, steel, load_bearing, wood_frame
  final String buildingUse;     // residential, commercial, mixed

  // Budget
  final double budgetAmount;
  final double estimatedCost;
  final double actualCost;
  final double completionPct;
  final String currencyCode;

  // Timeline
  final DateTime? startDate;
  final DateTime? targetEndDate;
  final DateTime? actualEndDate;

  // Stages
  final List<StageModel> stages;

  // Template reference
  final String? templateId;
  final String? notes;

  const ProjectScopeModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.projectType,
    this.qualityTier = 'standard',
    this.status = 'active',
    this.scopeOrder = 1,
    this.plotSizeSqm,
    this.constructionAreaSqm,
    this.plotWidthM,
    this.plotDepthM,
    this.floors = 1,
    this.hasBasement = false,
    this.structureType = 'rcc',
    this.buildingUse = 'residential',
    this.budgetAmount = 0,
    this.estimatedCost = 0,
    this.actualCost = 0,
    this.completionPct = 0,
    this.currencyCode = 'PKR',
    this.startDate,
    this.targetEndDate,
    this.actualEndDate,
    this.stages = const [],
    this.templateId,
    this.notes,
  });

  // ── Computed ──────────────────────────────────────────────────────────────

  double get budgetVariance => budgetAmount - estimatedCost;
  bool get isOverBudget => estimatedCost > budgetAmount && budgetAmount > 0;
  double get remainingBudget => budgetAmount - actualCost;

  int get completedStages  => stages.where((s) => s.isCompleted).length;
  int get totalStages      => stages.length;
  int get inProgressStages => stages.where((s) => s.isInProgress).length;

  StageModel? get activeStage {
    try {
      return stages.firstWhere((s) => s.isInProgress);
    } catch (_) {
      try {
        return stages.firstWhere((s) => s.isNotStarted);
      } catch (_) {
        return null;
      }
    }
  }

  int get daysLeft {
    if (targetEndDate == null) return 0;
    return targetEndDate!.difference(DateTime.now()).inDays;
  }

  bool get isCompleted => status == 'completed';
  bool get isActive    => status == 'active';

  // ── CopyWith ──────────────────────────────────────────────────────────────

  ProjectScopeModel copyWith({
    String? status,
    double? actualCost,
    double? completionPct,
    double? estimatedCost,
    List<StageModel>? stages,
    DateTime? actualEndDate,
  }) {
    return ProjectScopeModel(
      id: id,
      projectId: projectId,
      name: name,
      projectType: projectType,
      qualityTier: qualityTier,
      status: status ?? this.status,
      scopeOrder: scopeOrder,
      plotSizeSqm: plotSizeSqm,
      constructionAreaSqm: constructionAreaSqm,
      plotWidthM: plotWidthM,
      plotDepthM: plotDepthM,
      floors: floors,
      hasBasement: hasBasement,
      structureType: structureType,
      buildingUse: buildingUse,
      budgetAmount: budgetAmount,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      completionPct: completionPct ?? this.completionPct,
      currencyCode: currencyCode,
      startDate: startDate,
      targetEndDate: targetEndDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      stages: stages ?? this.stages,
      templateId: templateId,
      notes: notes,
    );
  }

  // ── JSON ──────────────────────────────────────────────────────────────────

  factory ProjectScopeModel.fromJson(Map<String, dynamic> json) =>
      ProjectScopeModel(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        name: json['name'] as String,
        projectType: json['project_type'] as String,
        qualityTier: json['quality_tier'] as String? ?? 'standard',
        status: json['status'] as String? ?? 'active',
        scopeOrder: json['scope_order'] as int? ?? 1,
        plotSizeSqm: (json['plot_size_sqm'] as num?)?.toDouble(),
        constructionAreaSqm:
            (json['construction_area_sqm'] as num?)?.toDouble(),
        plotWidthM: (json['plot_width_m'] as num?)?.toDouble(),
        plotDepthM: (json['plot_depth_m'] as num?)?.toDouble(),
        floors: json['floors'] as int? ?? 1,
        hasBasement: json['has_basement'] as bool? ?? false,
        structureType: json['structure_type'] as String? ?? 'rcc',
        buildingUse: json['building_use'] as String? ?? 'residential',
        budgetAmount: (json['budget_amount'] as num?)?.toDouble() ?? 0,
        estimatedCost: (json['estimated_cost'] as num?)?.toDouble() ?? 0,
        actualCost: (json['actual_cost'] as num?)?.toDouble() ?? 0,
        completionPct: (json['completion_pct'] as num?)?.toDouble() ?? 0,
        currencyCode: json['currency_code'] as String? ?? 'PKR',
        startDate: json['start_date'] != null
            ? DateTime.parse(json['start_date'] as String)
            : null,
        targetEndDate: json['target_end_date'] != null
            ? DateTime.parse(json['target_end_date'] as String)
            : null,
        actualEndDate: json['actual_end_date'] != null
            ? DateTime.parse(json['actual_end_date'] as String)
            : null,
        stages: (json['stages'] as List<dynamic>?)
                ?.map((s) => StageModel.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        templateId: json['template_id'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'name': name,
        'project_type': projectType,
        'quality_tier': qualityTier,
        'status': status,
        'scope_order': scopeOrder,
        'plot_size_sqm': plotSizeSqm,
        'construction_area_sqm': constructionAreaSqm,
        'plot_width_m': plotWidthM,
        'plot_depth_m': plotDepthM,
        'floors': floors,
        'has_basement': hasBasement,
        'structure_type': structureType,
        'building_use': buildingUse,
        'budget_amount': budgetAmount,
        'estimated_cost': estimatedCost,
        'actual_cost': actualCost,
        'completion_pct': completionPct,
        'currency_code': currencyCode,
        'start_date': startDate?.toIso8601String(),
        'target_end_date': targetEndDate?.toIso8601String(),
        'actual_end_date': actualEndDate?.toIso8601String(),
        'stages': stages.map((s) => s.toJson()).toList(),
        'template_id': templateId,
        'notes': notes,
      };

  @override
  List<Object?> get props => [id, status, completionPct];
}
