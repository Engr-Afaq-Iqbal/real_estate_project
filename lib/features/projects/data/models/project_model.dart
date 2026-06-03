import 'package:equatable/equatable.dart';
import 'stage_model.dart';

class ProjectModel extends Equatable {
  final String id;
  final String name;
  final String type;
  final String city;
  final String area;
  final String plotSize;
  final String status;
  final double progress;
  final double totalBudget;
  final double spentBudget;
  final DateTime startDate;
  final DateTime estimatedEndDate;
  final String currentStage;
  final List<StageModel> stages;
  final DateTime lastUpdated;
  final String contractorName;
  final String? contractorId;
  final int photoCount;
  final int workerCount;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.type,
    required this.city,
    required this.area,
    required this.plotSize,
    required this.status,
    required this.progress,
    required this.totalBudget,
    required this.spentBudget,
    required this.startDate,
    required this.estimatedEndDate,
    required this.currentStage,
    required this.stages,
    required this.lastUpdated,
    required this.contractorName,
    this.contractorId,
    this.photoCount = 0,
    this.workerCount = 0,
  });

  double get budgetProgress => totalBudget > 0 ? spentBudget / totalBudget : 0;
  double get remainingBudget => totalBudget - spentBudget;
  int get weeksLeft => estimatedEndDate.difference(DateTime.now()).inDays ~/ 7;
  bool get isOnTrack => status == 'active' && weeksLeft >= 0;
  bool get isLate => weeksLeft < 0;
  bool get isAtRisk => weeksLeft >= 0 && weeksLeft <= 4;

  String get statusLabel {
    if (isLate) return 'LATE';
    if (isAtRisk) return 'AT RISK';
    if (status == 'active') return 'ON TRACK';
    return status.toUpperCase();
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        city: json['city'] as String,
        area: json['area'] as String,
        plotSize: json['plot_size'] as String,
        status: json['status'] as String,
        progress: (json['progress'] as num).toDouble(),
        totalBudget: (json['total_budget'] as num).toDouble(),
        spentBudget: (json['spent_budget'] as num).toDouble(),
        startDate: DateTime.parse(json['start_date'] as String),
        estimatedEndDate:
            DateTime.parse(json['estimated_end_date'] as String),
        currentStage: json['current_stage'] as String,
        stages: (json['stages'] as List<dynamic>?)
                ?.map((s) => StageModel.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        lastUpdated: DateTime.parse(json['last_updated'] as String),
        contractorName: json['contractor_name'] as String,
        contractorId: json['contractor_id'] as String?,
        photoCount: json['photo_count'] as int? ?? 0,
        workerCount: json['worker_count'] as int? ?? 0,
      );

  static List<ProjectModel> mockList() => [
        ProjectModel(
          id: 'p1',
          name: 'DHA House — 10 Marla',
          type: 'House',
          city: 'Lahore',
          area: 'DHA Phase 6',
          plotSize: '10 Marla',
          status: 'active',
          progress: 0.68,
          totalBudget: 5000000,
          spentBudget: 3400000,
          startDate: DateTime(2025, 1, 12),
          estimatedEndDate: DateTime(2025, 10, 10),
          currentStage: 'Gray Structure',
          stages: StageModel.defaultStages(),
          lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
          contractorName: 'Malik Construction',
          contractorId: 'c1',
          photoCount: 48,
          workerCount: 15,
        ),
        ProjectModel(
          id: 'p2',
          name: 'Bahria Heights — Block C',
          type: 'Commercial',
          city: 'Lahore',
          area: 'Bahria Town',
          plotSize: '1 Kanal',
          status: 'active',
          progress: 0.72,
          totalBudget: 18000000,
          spentBudget: 12960000,
          startDate: DateTime(2025, 1, 1),
          estimatedEndDate: DateTime(2025, 9, 1),
          currentStage: 'Plastering',
          stages: [],
          lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
          contractorName: 'Malik Construction',
          workerCount: 22,
        ),
        ProjectModel(
          id: 'p3',
          name: 'Khan Villa Renovation',
          type: 'Renovation',
          city: 'Lahore',
          area: 'Gulberg III',
          plotSize: '1 Kanal',
          status: 'active',
          progress: 0.88,
          totalBudget: 3800000,
          spentBudget: 3344000,
          startDate: DateTime(2025, 2, 1),
          estimatedEndDate: DateTime(2025, 6, 1),
          currentStage: 'Finishing',
          stages: [],
          lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
          contractorName: 'Malik Construction',
          workerCount: 8,
        ),
      ];

  @override
  List<Object?> get props => [id, status, progress];
}
