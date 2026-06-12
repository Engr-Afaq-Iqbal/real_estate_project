/// Task / meeting / alert item shown in the Tasks hub and the dashboard
/// "Today's Alert" card.
///
/// API-ready: `fromJson` / `toJson` match a conventional REST payload so the
/// mock list can be swapped for a paginated endpoint without touching the UI.
class TaskModel {
  final String id;
  final String title;

  /// task | meeting | site_visit | alert | reminder | approval | deadline |
  /// follow_up
  final String type;

  /// high | medium | low
  final String priority;

  /// pending | completed
  final String status;

  final DateTime dueDate;
  final String? projectId;
  final String? projectName;
  final String assignedBy;
  final String? description;

  const TaskModel({
    required this.id,
    required this.title,
    required this.type,
    required this.dueDate,
    this.priority = 'medium',
    this.status = 'pending',
    this.projectId,
    this.projectName,
    this.assignedBy = 'You',
    this.description,
  });

  // ── Derived state ──────────────────────────────────────────────────────────

  bool get isCompleted => status == 'completed';
  bool get isPending   => status == 'pending';

  bool get isOverdue =>
      isPending && dueDate.isBefore(DateTime.now());

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  /// Tab category: tasks | meetings | alerts.
  String get category => switch (type) {
        'meeting' || 'site_visit'            => 'meetings',
        'alert' || 'reminder'                => 'alerts',
        _                                    => 'tasks',
      };

  String get typeLabel => switch (type) {
        'meeting'    => 'Meeting',
        'site_visit' => 'Site Visit',
        'alert'      => 'Alert',
        'reminder'   => 'Reminder',
        'approval'   => 'Approval',
        'deadline'   => 'Deadline',
        'follow_up'  => 'Follow-up',
        _            => 'Task',
      };

  /// Numeric weight for "most important first" ordering.
  int get priorityWeight => switch (priority) {
        'high'   => 0,
        'medium' => 1,
        _        => 2,
      };

  TaskModel copyWith({String? status}) => TaskModel(
        id: id,
        title: title,
        type: type,
        dueDate: dueDate,
        priority: priority,
        status: status ?? this.status,
        projectId: projectId,
        projectName: projectName,
        assignedBy: assignedBy,
        description: description,
      );

  // ── Serialization (API-driven loading) ─────────────────────────────────────

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as String,
        title: json['title'] as String,
        type: json['type'] as String? ?? 'task',
        priority: json['priority'] as String? ?? 'medium',
        status: json['status'] as String? ?? 'pending',
        dueDate: DateTime.parse(json['due_date'] as String),
        projectId: json['project_id'] as String?,
        projectName: json['project_name'] as String?,
        assignedBy: json['assigned_by'] as String? ?? 'You',
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'priority': priority,
        'status': status,
        'due_date': dueDate.toIso8601String(),
        'project_id': projectId,
        'project_name': projectName,
        'assigned_by': assignedBy,
        'description': description,
      };

  // ── Mock data (matches ProjectModel.mockList ids/names) ───────────────────

  static List<TaskModel> mockList() {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      TaskModel(
        id: 't1',
        title: 'Site Visit — DHA Phase 6',
        type: 'site_visit',
        priority: 'high',
        dueDate: today.add(const Duration(hours: 15)), // 3:00 PM today
        projectId: 'p1',
        projectName: 'DHA House — 10 Marla',
        assignedBy: 'Malik Construction',
        description: 'Inspect gray structure progress with site engineer.',
      ),
      TaskModel(
        id: 't2',
        title: 'Contractor Meeting',
        type: 'meeting',
        priority: 'medium',
        dueDate: today.add(const Duration(hours: 17, minutes: 30)), // 5:30 PM
        projectId: 'p2',
        projectName: 'Bahria Heights — Block C',
        assignedBy: 'Ahmed Khan',
        description: 'Review steel order and next-week labor plan.',
      ),
      TaskModel(
        id: 't3',
        title: 'Material Approval Pending',
        type: 'approval',
        priority: 'high',
        dueDate: today.add(const Duration(hours: 18)),
        projectId: 'p1',
        projectName: 'DHA House — 10 Marla',
        assignedBy: 'Site Engineer',
        description: 'Approve tile samples before finishing work starts.',
      ),
      TaskModel(
        id: 't4',
        title: 'Budget Review Due Today',
        type: 'deadline',
        priority: 'medium',
        dueDate: today.add(const Duration(hours: 20)),
        projectId: 'p2',
        projectName: 'Bahria Heights — Block C',
        assignedBy: 'You',
        description: 'Monthly budget vs. actual spending review.',
      ),
      TaskModel(
        id: 't5',
        title: 'Approve payroll for this week',
        type: 'task',
        priority: 'high',
        dueDate: today.add(const Duration(days: 1, hours: 11)),
        projectId: 'p1',
        projectName: 'DHA House — 10 Marla',
        assignedBy: 'Foreman',
      ),
      TaskModel(
        id: 't6',
        title: 'Upload foundation completion photos',
        type: 'task',
        priority: 'medium',
        dueDate: today.subtract(const Duration(days: 2)),
        projectId: 'p2',
        projectName: 'Bahria Heights — Block C',
        assignedBy: 'You',
      ),
      TaskModel(
        id: 't7',
        title: 'Cement price increased in your city',
        type: 'alert',
        priority: 'low',
        dueDate: today.add(const Duration(hours: 9)),
        assignedBy: 'Market Watch',
        description: 'Cement up Rs 20/bag since yesterday.',
      ),
      TaskModel(
        id: 't8',
        title: 'Follow up with electrician quote',
        type: 'follow_up',
        priority: 'low',
        dueDate: today.add(const Duration(days: 2, hours: 10)),
        projectId: 'p3',
        projectName: 'Khan Villa Renovation',
        assignedBy: 'You',
      ),
      TaskModel(
        id: 't9',
        title: 'Mark plaster stage complete',
        type: 'task',
        priority: 'medium',
        dueDate: today.add(const Duration(days: 3, hours: 12)),
        projectId: 'p3',
        projectName: 'Khan Villa Renovation',
        assignedBy: 'You',
      ),
      TaskModel(
        id: 't10',
        title: 'Pay water tanker supplier',
        type: 'task',
        priority: 'low',
        status: 'completed',
        dueDate: today.subtract(const Duration(days: 1)),
        projectId: 'p1',
        projectName: 'DHA House — 10 Marla',
        assignedBy: 'You',
      ),
      TaskModel(
        id: 't11',
        title: 'Weekly progress photos uploaded',
        type: 'task',
        priority: 'medium',
        status: 'completed',
        dueDate: today.subtract(const Duration(days: 3)),
        projectId: 'p3',
        projectName: 'Khan Villa Renovation',
        assignedBy: 'Site Engineer',
      ),
    ];
  }
}
