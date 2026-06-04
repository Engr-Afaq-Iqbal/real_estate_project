import 'package:equatable/equatable.dart';

class ChecklistItemModel extends Equatable {
  final String id;
  final String stageId;
  final String description;
  final bool isRequired;
  final bool isChecked;
  final String? checkedBy;
  final DateTime? checkedAt;
  final int sortOrder;

  const ChecklistItemModel({
    required this.id,
    required this.stageId,
    required this.description,
    this.isRequired = true,
    this.isChecked = false,
    this.checkedBy,
    this.checkedAt,
    this.sortOrder = 99,
  });

  ChecklistItemModel copyWith({
    bool? isChecked,
    String? checkedBy,
    DateTime? checkedAt,
  }) {
    return ChecklistItemModel(
      id: id,
      stageId: stageId,
      description: description,
      isRequired: isRequired,
      isChecked: isChecked ?? this.isChecked,
      checkedBy: checkedBy ?? this.checkedBy,
      checkedAt: checkedAt ?? this.checkedAt,
      sortOrder: sortOrder,
    );
  }

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) =>
      ChecklistItemModel(
        id: json['id'] as String,
        stageId: json['stage_id'] as String,
        description: json['description'] as String,
        isRequired: json['is_required'] as bool? ?? true,
        isChecked: json['is_checked'] as bool? ?? false,
        checkedBy: json['checked_by'] as String?,
        checkedAt: json['checked_at'] != null
            ? DateTime.parse(json['checked_at'] as String)
            : null,
        sortOrder: json['sort_order'] as int? ?? 99,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'stage_id': stageId,
        'description': description,
        'is_required': isRequired,
        'is_checked': isChecked,
        'checked_by': checkedBy,
        'checked_at': checkedAt?.toIso8601String(),
        'sort_order': sortOrder,
      };

  @override
  List<Object?> get props => [id, isChecked];
}
