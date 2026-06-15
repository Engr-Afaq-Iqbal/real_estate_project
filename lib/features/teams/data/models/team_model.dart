import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// ── Enums ─────────────────────────────────────────────────────────────────────

enum TeamType {
  structural,
  finishing,
  electrical,
  plumbing,
  general,
  specialized;

  String get label => switch (this) {
        TeamType.structural  => 'Structural',
        TeamType.finishing   => 'Finishing',
        TeamType.electrical  => 'Electrical',
        TeamType.plumbing    => 'Plumbing',
        TeamType.general     => 'General Labour',
        TeamType.specialized => 'Specialized',
      };
}

enum TeamStatus {
  active,
  inactive,
  onLeave;

  String get label => switch (this) {
        TeamStatus.active   => 'Active',
        TeamStatus.inactive => 'Inactive',
        TeamStatus.onLeave  => 'On Leave',
      };
}

enum WorkerStatus {
  active,
  inactive,
  onLeave;

  String get label => switch (this) {
        WorkerStatus.active   => 'Active',
        WorkerStatus.inactive => 'Inactive',
        WorkerStatus.onLeave  => 'On Leave',
      };
}

// ── Worker model ──────────────────────────────────────────────────────────────

class TeamWorkerModel {
  final String id;
  final String teamId;
  final String name;
  final String phone;
  final String skillType;
  final double dailyWage;
  final double? monthlySalary;
  final DateTime joiningDate;
  final WorkerStatus status;

  const TeamWorkerModel({
    required this.id,
    required this.teamId,
    required this.name,
    required this.phone,
    required this.skillType,
    required this.dailyWage,
    this.monthlySalary,
    required this.joiningDate,
    required this.status,
  });

  bool get isActive   => status == WorkerStatus.active;
  bool get isOnLeave  => status == WorkerStatus.onLeave;
  bool get isInactive => status == WorkerStatus.inactive;

  double get effectiveMonthlyCost =>
      monthlySalary ?? dailyWage * 26;

  TeamWorkerModel copyWith({
    String? name,
    String? phone,
    String? skillType,
    double? dailyWage,
    double? monthlySalary,
    WorkerStatus? status,
  }) =>
      TeamWorkerModel(
        id: id,
        teamId: teamId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        skillType: skillType ?? this.skillType,
        dailyWage: dailyWage ?? this.dailyWage,
        monthlySalary: monthlySalary ?? this.monthlySalary,
        joiningDate: joiningDate,
        status: status ?? this.status,
      );

  static TeamWorkerModel blank({required String teamId}) => TeamWorkerModel(
        id: _uuid.v4(),
        teamId: teamId,
        name: '',
        phone: '',
        skillType: 'Mason',
        dailyWage: 2000,
        joiningDate: DateTime.now(),
        status: WorkerStatus.active,
      );
}

// ── Team model ────────────────────────────────────────────────────────────────

class TeamModel {
  final String id;
  final String name;
  final String leaderName;
  final String? leaderPhone;
  final String? description;
  final TeamType type;
  final TeamStatus status;
  final String? contactNumber;
  final List<TeamWorkerModel> workers;
  final List<String> assignedProjectIds;
  final DateTime createdAt;
  final DateTime? lastActivityAt;

  const TeamModel({
    required this.id,
    required this.name,
    required this.leaderName,
    this.leaderPhone,
    this.description,
    required this.type,
    required this.status,
    this.contactNumber,
    required this.workers,
    required this.assignedProjectIds,
    required this.createdAt,
    this.lastActivityAt,
  });

  // ── Computed ───────────────────────────────────────────────────────────────

  int    get workerCount        => workers.length;
  int    get activeWorkerCount  => workers.where((w) => w.isActive).length;
  int    get workersOnLeave     => workers.where((w) => w.isOnLeave).length;
  bool   get isActive           => status == TeamStatus.active;
  int    get assignedProjectCount => assignedProjectIds.length;
  double get totalDailyWage     => workers.fold(0, (s, w) => s + w.dailyWage);
  double get totalMonthlyCost   =>
      workers.fold(0, (s, w) => s + w.effectiveMonthlyCost);

  TeamModel copyWith({
    String? name,
    String? leaderName,
    String? leaderPhone,
    String? description,
    TeamType? type,
    TeamStatus? status,
    String? contactNumber,
    List<TeamWorkerModel>? workers,
    List<String>? assignedProjectIds,
    DateTime? lastActivityAt,
  }) =>
      TeamModel(
        id: id,
        name: name ?? this.name,
        leaderName: leaderName ?? this.leaderName,
        leaderPhone: leaderPhone ?? this.leaderPhone,
        description: description ?? this.description,
        type: type ?? this.type,
        status: status ?? this.status,
        contactNumber: contactNumber ?? this.contactNumber,
        workers: workers ?? this.workers,
        assignedProjectIds: assignedProjectIds ?? this.assignedProjectIds,
        createdAt: createdAt,
        lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      );

  // ── Mock data ──────────────────────────────────────────────────────────────

  static List<TeamModel> mockList() => [
        TeamModel(
          id: 't1',
          name: 'Alpha Structural',
          leaderName: 'Usman Khan',
          leaderPhone: '+92 300 1234567',
          description: 'Specialises in RCC work, columns, slabs and beams',
          type: TeamType.structural,
          status: TeamStatus.active,
          contactNumber: '+92 300 1234567',
          assignedProjectIds: ['p1', 'p2'],
          createdAt: DateTime(2025, 1, 15),
          lastActivityAt: DateTime.now().subtract(const Duration(hours: 2)),
          workers: [
            TeamWorkerModel(
              id: 'w1', teamId: 't1',
              name: 'Ali Hassan', phone: '+92 301 1111111',
              skillType: 'Mason', dailyWage: 2200,
              joiningDate: DateTime(2025, 1, 15),
              status: WorkerStatus.active,
            ),
            TeamWorkerModel(
              id: 'w2', teamId: 't1',
              name: 'Bilal Ahmad', phone: '+92 302 2222222',
              skillType: 'Mason', dailyWage: 2000,
              joiningDate: DateTime(2025, 2, 1),
              status: WorkerStatus.active,
            ),
            TeamWorkerModel(
              id: 'w3', teamId: 't1',
              name: 'Imran Butt', phone: '+92 303 3333333',
              skillType: 'Helper', dailyWage: 1200,
              joiningDate: DateTime(2025, 2, 10),
              status: WorkerStatus.onLeave,
            ),
            TeamWorkerModel(
              id: 'w4', teamId: 't1',
              name: 'Tariq Mahmood', phone: '+92 304 4444444',
              skillType: 'Helper', dailyWage: 1200,
              joiningDate: DateTime(2025, 3, 1),
              status: WorkerStatus.active,
            ),
            TeamWorkerModel(
              id: 'w5', teamId: 't1',
              name: 'Nadeem Shah', phone: '+92 305 5555555',
              skillType: 'Shuttering Carpenter', dailyWage: 2500,
              joiningDate: DateTime(2025, 1, 20),
              status: WorkerStatus.active,
            ),
          ],
        ),
        TeamModel(
          id: 't2',
          name: 'Bravo Finishing Crew',
          leaderName: 'Sajid Mehmood',
          leaderPhone: '+92 321 9876543',
          description: 'Plastering, tiling, and premium painting works',
          type: TeamType.finishing,
          status: TeamStatus.active,
          contactNumber: '+92 321 9876543',
          assignedProjectIds: ['p2'],
          createdAt: DateTime(2025, 3, 5),
          lastActivityAt: DateTime.now().subtract(const Duration(hours: 5)),
          workers: [
            TeamWorkerModel(
              id: 'w6', teamId: 't2',
              name: 'Hamid Ali', phone: '+92 322 6666666',
              skillType: 'Plasterer', dailyWage: 2800,
              joiningDate: DateTime(2025, 3, 5),
              status: WorkerStatus.active,
            ),
            TeamWorkerModel(
              id: 'w7', teamId: 't2',
              name: 'Waseem Akhtar', phone: '+92 323 7777777',
              skillType: 'Tile Expert', dailyWage: 3000,
              joiningDate: DateTime(2025, 3, 5),
              status: WorkerStatus.active,
            ),
            TeamWorkerModel(
              id: 'w8', teamId: 't2',
              name: 'Farhan Qureshi', phone: '+92 324 8888888',
              skillType: 'Painter', dailyWage: 2200,
              joiningDate: DateTime(2025, 3, 10),
              status: WorkerStatus.active,
            ),
          ],
        ),
        TeamModel(
          id: 't3',
          name: 'Charlie Electrical',
          leaderName: 'Zubair Ahmed',
          leaderPhone: '+92 333 1122334',
          description: 'Complete electrical wiring, DB boards, and fixtures',
          type: TeamType.electrical,
          status: TeamStatus.active,
          contactNumber: '+92 333 1122334',
          assignedProjectIds: ['p1'],
          createdAt: DateTime(2025, 4, 1),
          lastActivityAt: DateTime.now().subtract(const Duration(days: 1)),
          workers: [
            TeamWorkerModel(
              id: 'w9', teamId: 't3',
              name: 'Faisal Malik', phone: '+92 334 9900112',
              skillType: 'Electrician', dailyWage: 3200,
              joiningDate: DateTime(2025, 4, 1),
              status: WorkerStatus.active,
            ),
            TeamWorkerModel(
              id: 'w10', teamId: 't3',
              name: 'Arshad Raza', phone: '+92 335 0011223',
              skillType: 'Electrician Helper', dailyWage: 1500,
              joiningDate: DateTime(2025, 4, 5),
              status: WorkerStatus.active,
            ),
          ],
        ),
        TeamModel(
          id: 't4',
          name: 'Delta Plumbing Unit',
          leaderName: 'Kashif Hussain',
          leaderPhone: '+92 341 5544332',
          description: 'Pipe work, sanitary fittings, and water systems',
          type: TeamType.plumbing,
          status: TeamStatus.inactive,
          contactNumber: '+92 341 5544332',
          assignedProjectIds: [],
          createdAt: DateTime(2025, 2, 20),
          lastActivityAt: DateTime.now().subtract(const Duration(days: 7)),
          workers: [
            TeamWorkerModel(
              id: 'w11', teamId: 't4',
              name: 'Zaheer Khan', phone: '+92 342 4433221',
              skillType: 'Plumber', dailyWage: 2800,
              joiningDate: DateTime(2025, 2, 20),
              status: WorkerStatus.inactive,
            ),
            TeamWorkerModel(
              id: 'w12', teamId: 't4',
              name: 'Shahrukh Ali', phone: '+92 343 3322110',
              skillType: 'Plumber Helper', dailyWage: 1400,
              joiningDate: DateTime(2025, 2, 25),
              status: WorkerStatus.inactive,
            ),
          ],
        ),
      ];
}
