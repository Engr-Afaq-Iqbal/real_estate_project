import 'package:equatable/equatable.dart';
import 'subtask_model.dart';
import 'checklist_item_model.dart';

enum StageStatus { notStarted, inProgress, blocked, completed, skipped }

class StageModel extends Equatable {
  final String id;
  final String scopeId;
  final String projectId;
  final String name;
  final String? description;
  final int stageOrder;
  final StageStatus status;
  final bool isMilestone;
  final String? color;       // hex, for Gantt display

  // Dates
  final DateTime? plannedStart;
  final DateTime? plannedEnd;
  final int? durationDays;
  final DateTime? actualStart;
  final DateTime? actualEnd;

  // Budget
  final double budgetAmount;
  final double budgetPct;    // % of total project budget
  final double actualCost;

  // Progress
  final double completionPct;

  // Media counts (for display)
  final int photoCount;
  final int expenseCount;

  // Sub-items
  final List<SubtaskModel> subtasks;
  final List<ChecklistItemModel> checklist;

  // Completion
  final String? completedBy;
  final DateTime? completedAt;
  final String? completionNotes;

  const StageModel({
    required this.id,
    required this.scopeId,
    required this.projectId,
    required this.name,
    this.description,
    required this.stageOrder,
    this.status = StageStatus.notStarted,
    this.isMilestone = false,
    this.color,
    this.plannedStart,
    this.plannedEnd,
    this.durationDays,
    this.actualStart,
    this.actualEnd,
    this.budgetAmount = 0,
    this.budgetPct = 0,
    this.actualCost = 0,
    this.completionPct = 0,
    this.photoCount = 0,
    this.expenseCount = 0,
    this.subtasks = const [],
    this.checklist = const [],
    this.completedBy,
    this.completedAt,
    this.completionNotes,
  });

  // ── Computed ──────────────────────────────────────────────────────────────

  bool get isNotStarted => status == StageStatus.notStarted;
  bool get isInProgress => status == StageStatus.inProgress;
  bool get isBlocked    => status == StageStatus.blocked;
  bool get isCompleted  => status == StageStatus.completed;
  bool get isSkipped    => status == StageStatus.skipped;
  bool get isActive     => isInProgress || isBlocked;

  int get daysLeft {
    if (plannedEnd == null) return 0;
    return plannedEnd!.difference(DateTime.now()).inDays;
  }

  bool get isOverdue =>
      plannedEnd != null &&
      DateTime.now().isAfter(plannedEnd!) &&
      !isCompleted &&
      !isSkipped;

  double get budgetVariance => budgetAmount - actualCost;
  bool get isOverBudget => actualCost > budgetAmount && budgetAmount > 0;

  int get checkedItemsCount => checklist.where((c) => c.isChecked).length;
  int get requiredItemsCount => checklist.where((c) => c.isRequired).length;
  int get checkedRequiredCount =>
      checklist.where((c) => c.isRequired && c.isChecked).length;
  bool get canComplete =>
      checkedRequiredCount >= requiredItemsCount;

  String get statusLabel => switch (status) {
        StageStatus.notStarted => 'Not Started',
        StageStatus.inProgress => 'In Progress',
        StageStatus.blocked    => 'Blocked',
        StageStatus.completed  => 'Completed',
        StageStatus.skipped    => 'Skipped',
      };

  // ── Backward-compat getters (used by existing screens) ───────────────────

  /// Legacy alias for stageOrder
  int get order => stageOrder;

  /// Legacy: 0–100 progress value
  double get progress => completionPct;

  /// Legacy alias — maps to actualStart (or plannedStart as fallback)
  DateTime? get startDate => actualStart ?? plannedStart;

  /// Legacy alias — plannedEnd date
  DateTime? get estimatedEndDate => plannedEnd;

  /// Legacy alias — actual or planned end date
  DateTime? get endDate => actualEnd ?? plannedEnd;

  /// Legacy isPending — true when stage not started
  bool get isPending => isNotStarted;

  // ── CopyWith ──────────────────────────────────────────────────────────────

  StageModel copyWith({
    StageStatus? status,
    double? completionPct,
    double? actualCost,
    DateTime? actualStart,
    DateTime? actualEnd,
    List<SubtaskModel>? subtasks,
    List<ChecklistItemModel>? checklist,
    String? completedBy,
    DateTime? completedAt,
    String? completionNotes,
    double? budgetAmount,
    DateTime? plannedStart,
    DateTime? plannedEnd,
  }) {
    return StageModel(
      id: id,
      scopeId: scopeId,
      projectId: projectId,
      name: name,
      description: description,
      stageOrder: stageOrder,
      status: status ?? this.status,
      isMilestone: isMilestone,
      color: color,
      plannedStart: plannedStart ?? this.plannedStart,
      plannedEnd: plannedEnd ?? this.plannedEnd,
      durationDays: durationDays,
      actualStart: actualStart ?? this.actualStart,
      actualEnd: actualEnd ?? this.actualEnd,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      budgetPct: budgetPct,
      actualCost: actualCost ?? this.actualCost,
      completionPct: completionPct ?? this.completionPct,
      photoCount: photoCount,
      expenseCount: expenseCount,
      subtasks: subtasks ?? this.subtasks,
      checklist: checklist ?? this.checklist,
      completedBy: completedBy ?? this.completedBy,
      completedAt: completedAt ?? this.completedAt,
      completionNotes: completionNotes ?? this.completionNotes,
    );
  }

  // ── JSON ──────────────────────────────────────────────────────────────────

  factory StageModel.fromJson(Map<String, dynamic> json) => StageModel(
        id: json['id'] as String,
        scopeId: json['scope_id'] as String? ?? '',
        projectId: json['project_id'] as String? ?? '',
        name: json['name'] as String,
        description: json['description'] as String?,
        stageOrder: json['stage_order'] as int? ?? json['order'] as int? ?? 0,
        status: StageStatus.values.firstWhere(
          (s) => s.name == (json['status'] as String? ?? 'notStarted'),
          orElse: () => StageStatus.notStarted,
        ),
        isMilestone: json['is_milestone'] as bool? ?? false,
        color: json['color'] as String?,
        plannedStart: json['planned_start'] != null
            ? DateTime.parse(json['planned_start'] as String)
            : null,
        plannedEnd: json['planned_end'] != null
            ? DateTime.parse(json['planned_end'] as String)
            : null,
        durationDays: json['duration_days'] as int?,
        actualStart: json['actual_start'] != null
            ? DateTime.parse(json['actual_start'] as String)
            : null,
        actualEnd: json['actual_end'] != null
            ? DateTime.parse(json['actual_end'] as String)
            : null,
        budgetAmount: (json['budget_amount'] as num?)?.toDouble() ?? 0,
        budgetPct: (json['budget_pct'] as num?)?.toDouble() ?? 0,
        actualCost: (json['actual_cost'] as num?)?.toDouble() ?? 0,
        completionPct: (json['completion_pct'] as num?)?.toDouble() ?? 0,
        photoCount: json['photo_count'] as int? ?? 0,
        expenseCount: json['expense_count'] as int? ?? 0,
        subtasks: (json['subtasks'] as List<dynamic>?)
                ?.map((s) => SubtaskModel.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        checklist: (json['checklist'] as List<dynamic>?)
                ?.map((c) =>
                    ChecklistItemModel.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [],
        completedBy: json['completed_by'] as String?,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        completionNotes: json['completion_notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'scope_id': scopeId,
        'project_id': projectId,
        'name': name,
        'description': description,
        'stage_order': stageOrder,
        'status': status.name,
        'is_milestone': isMilestone,
        'color': color,
        'planned_start': plannedStart?.toIso8601String(),
        'planned_end': plannedEnd?.toIso8601String(),
        'duration_days': durationDays,
        'actual_start': actualStart?.toIso8601String(),
        'actual_end': actualEnd?.toIso8601String(),
        'budget_amount': budgetAmount,
        'budget_pct': budgetPct,
        'actual_cost': actualCost,
        'completion_pct': completionPct,
        'photo_count': photoCount,
        'expense_count': expenseCount,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'checklist': checklist.map((c) => c.toJson()).toList(),
        'completed_by': completedBy,
        'completed_at': completedAt?.toIso8601String(),
        'completion_notes': completionNotes,
      };

  @override
  List<Object?> get props => [id, status, completionPct, actualCost];
}
