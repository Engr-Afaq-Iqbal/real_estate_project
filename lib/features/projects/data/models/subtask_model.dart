import 'package:equatable/equatable.dart';

enum SubtaskStatus { pending, inProgress, done, skipped }

class SubtaskModel extends Equatable {
  final String id;
  final String stageId;
  final String name;
  final SubtaskStatus status;
  final int taskOrder;
  final String? assignedTo;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String? notes;

  const SubtaskModel({
    required this.id,
    required this.stageId,
    required this.name,
    this.status = SubtaskStatus.pending,
    this.taskOrder = 99,
    this.assignedTo,
    this.dueDate,
    this.completedAt,
    this.notes,
  });

  bool get isPending    => status == SubtaskStatus.pending;
  bool get isInProgress => status == SubtaskStatus.inProgress;
  bool get isDone       => status == SubtaskStatus.done;
  bool get isSkipped    => status == SubtaskStatus.skipped;

  SubtaskModel copyWith({SubtaskStatus? status, String? notes}) {
    return SubtaskModel(
      id: id,
      stageId: stageId,
      name: name,
      status: status ?? this.status,
      taskOrder: taskOrder,
      assignedTo: assignedTo,
      dueDate: dueDate,
      completedAt: completedAt,
      notes: notes ?? this.notes,
    );
  }

  factory SubtaskModel.fromJson(Map<String, dynamic> json) => SubtaskModel(
        id: json['id'] as String,
        stageId: json['stage_id'] as String,
        name: json['name'] as String,
        status: SubtaskStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => SubtaskStatus.pending,
        ),
        taskOrder: json['task_order'] as int? ?? 99,
        assignedTo: json['assigned_to'] as String?,
        dueDate: json['due_date'] != null
            ? DateTime.parse(json['due_date'] as String)
            : null,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'stage_id': stageId,
        'name': name,
        'status': status.name,
        'task_order': taskOrder,
        'assigned_to': assignedTo,
        'due_date': dueDate?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'notes': notes,
      };

  @override
  List<Object?> get props => [id, status];
}
