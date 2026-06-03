import 'package:equatable/equatable.dart';

enum StageStatus { pending, inProgress, completed }

class StageModel extends Equatable {
  final String id;
  final String name;
  final int order;
  final StageStatus status;
  final double progress;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? estimatedEndDate;
  final int photoCount;
  final int expenseCount;
  final double totalExpenses;

  const StageModel({
    required this.id,
    required this.name,
    required this.order,
    required this.status,
    this.progress = 0,
    this.startDate,
    this.endDate,
    this.estimatedEndDate,
    this.photoCount = 0,
    this.expenseCount = 0,
    this.totalExpenses = 0,
  });

  bool get isCompleted => status == StageStatus.completed;
  bool get isInProgress => status == StageStatus.inProgress;
  bool get isPending => status == StageStatus.pending;

  int get daysLeft {
    if (estimatedEndDate == null) return 0;
    return estimatedEndDate!.difference(DateTime.now()).inDays;
  }

  factory StageModel.fromJson(Map<String, dynamic> json) => StageModel(
        id: json['id'] as String,
        name: json['name'] as String,
        order: json['order'] as int,
        status: StageStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => StageStatus.pending,
        ),
        progress: (json['progress'] as num?)?.toDouble() ?? 0,
        startDate: json['start_date'] != null
            ? DateTime.parse(json['start_date'] as String)
            : null,
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'] as String)
            : null,
        estimatedEndDate: json['estimated_end_date'] != null
            ? DateTime.parse(json['estimated_end_date'] as String)
            : null,
        photoCount: json['photo_count'] as int? ?? 0,
        expenseCount: json['expense_count'] as int? ?? 0,
        totalExpenses:
            (json['total_expenses'] as num?)?.toDouble() ?? 0,
      );

  static List<StageModel> defaultStages() => [
        const StageModel(
          id: 's1', name: 'Land & Registry', order: 1,
          status: StageStatus.completed, progress: 100,
        ),
        const StageModel(
          id: 's2', name: 'Approvals & NOC', order: 2,
          status: StageStatus.completed, progress: 100,
        ),
        const StageModel(
          id: 's3', name: 'Architecture & Drawings', order: 3,
          status: StageStatus.completed, progress: 100,
        ),
        const StageModel(
          id: 's4', name: 'Foundation & Plinth', order: 4,
          status: StageStatus.completed, progress: 100,
        ),
        StageModel(
          id: 's5', name: 'Gray Structure', order: 5,
          status: StageStatus.inProgress, progress: 64,
          startDate: DateTime(2025, 3, 22),
          estimatedEndDate: DateTime(2025, 6, 14),
          photoCount: 12, expenseCount: 12, totalExpenses: 924900,
        ),
        StageModel(
          id: 's6', name: 'Electrical & Plumbing', order: 6,
          status: StageStatus.pending,
          estimatedEndDate: DateTime(2025, 7, 28),
        ),
        StageModel(
          id: 's7', name: 'Plastering & Waterproofing', order: 7,
          status: StageStatus.pending,
          estimatedEndDate: DateTime(2025, 8, 22),
        ),
        StageModel(
          id: 's8', name: 'Finishing & Tiling', order: 8,
          status: StageStatus.pending,
          estimatedEndDate: DateTime(2025, 9, 18),
        ),
        const StageModel(
          id: 's9', name: 'Doors / Windows / Kitchen', order: 9,
          status: StageStatus.pending,
        ),
        const StageModel(
          id: 's10', name: 'Handover', order: 10,
          status: StageStatus.pending,
        ),
      ];

  @override
  List<Object?> get props => [id, status, progress];
}
