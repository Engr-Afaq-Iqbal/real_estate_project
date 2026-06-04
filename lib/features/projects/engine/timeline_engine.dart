import '../data/models/stage_model.dart';
import '../data/models/project_scope_model.dart';
import '../data/models/subtask_model.dart';
import '../data/models/checklist_item_model.dart';
import 'package:uuid/uuid.dart';

// ── Template structures ───────────────────────────────────────────────────────

class _TemplateStage {
  final int order;
  final String name;
  final String nameUr;
  final double costPct;
  final int baseDays;
  final bool isMilestone;
  final List<int> dependsOn;      // order indices of dependencies
  final List<String> subtasks;
  final List<String> checklist;   // required checklist items
  final String color;

  const _TemplateStage({
    required this.order,
    required this.name,
    required this.nameUr,
    required this.costPct,
    required this.baseDays,
    this.isMilestone = false,
    this.dependsOn = const [],
    this.subtasks = const [],
    this.checklist = const [],
    this.color = '#3B82F6',
  });
}

// ── Template Library ─────────────────────────────────────────────────────────

class TimelineTemplates {
  TimelineTemplates._();

  static const List<_TemplateStage> house = [
    _TemplateStage(order: 1,  name: 'Design & Approvals',        nameUr: 'ڈیزائن اور منظوری',    costPct: 2,  baseDays: 21, dependsOn: [],     isMilestone: false, color: '#8B5CF6',
      subtasks: ['Hire architect', 'Prepare drawings', 'Submit for NOC', 'Receive approval'],
      checklist: ['Drawings finalized', 'NOC received', 'Approval letter obtained'],
    ),
    _TemplateStage(order: 2,  name: 'Site Preparation',           nameUr: 'سائٹ کی تیاری',        costPct: 1,  baseDays: 5,  dependsOn: [1],   color: '#64748B',
      subtasks: ['Clear site', 'Mark boundaries', 'Set up tools store'],
      checklist: ['Site cleared', 'Boundary marked'],
    ),
    _TemplateStage(order: 3,  name: 'Excavation',                 nameUr: 'کھدائی',               costPct: 3,  baseDays: 7,  dependsOn: [2],   color: '#92400E',
      subtasks: ['Excavate to required depth', 'Soil testing', 'Dispose soil'],
      checklist: ['Depth verified by engineer', 'Soil stable'],
    ),
    _TemplateStage(order: 4,  name: 'Foundation',                 nameUr: 'بنیاد',                costPct: 12, baseDays: 21, dependsOn: [3],   isMilestone: true, color: '#B45309',
      subtasks: ['PCC base layer', 'Rebar placement', 'Formwork', 'Concrete pour', 'Curing'],
      checklist: ['Foundation depth checked', 'Rebar spacing verified', 'Concrete grade confirmed', 'Curing complete (21 days)'],
    ),
    _TemplateStage(order: 5,  name: 'Plinth Beam',               nameUr: 'پلنتھ بیم',            costPct: 5,  baseDays: 10, dependsOn: [4],   color: '#D97706',
      subtasks: ['DPC layer', 'Plinth filling', 'Plinth beam casting'],
      checklist: ['DPC applied', 'Plinth level verified'],
    ),
    _TemplateStage(order: 6,  name: 'Ground Floor Structure',    nameUr: 'گراؤنڈ فلور ڈھانچہ',   costPct: 14, baseDays: 35, dependsOn: [5],   color: '#1D4ED8',
      subtasks: ['Column shuttering', 'Column casting', 'Beam reinforcement', 'Slab reinforcement', 'Slab casting'],
      checklist: ['Column casting complete', 'Beam casting complete', 'Slab level verified'],
    ),
    _TemplateStage(order: 7,  name: 'First Floor Structure',     nameUr: 'پہلی منزل کا ڈھانچہ', costPct: 12, baseDays: 30, dependsOn: [6],   color: '#1D4ED8',
      subtasks: ['Column shuttering', 'Column casting', 'Beam & slab reinforcement', 'Slab casting'],
      checklist: ['Columns complete', 'Slab casting complete', 'Curing done'],
    ),
    _TemplateStage(order: 8,  name: 'Roof Slab',                 nameUr: 'چھت',                  costPct: 8,  baseDays: 14, dependsOn: [7],   isMilestone: true, color: '#7C3AED',
      subtasks: ['Shuttering', 'Reinforcement', 'Concrete pour', 'Curing'],
      checklist: ['Roof reinforcement verified', 'Concrete pour complete', 'Curing complete'],
    ),
    _TemplateStage(order: 9,  name: 'Brick / Block Work',        nameUr: 'اینٹوں کا کام',        costPct: 5,  baseDays: 21, dependsOn: [8],   color: '#DC2626',
      subtasks: ['External walls', 'Internal partition walls', 'Arch / lintels'],
      checklist: ['External walls complete', 'Internal walls complete', 'Openings correctly positioned'],
    ),
    _TemplateStage(order: 10, name: 'Plumbing Rough-In',         nameUr: 'پلمبنگ',              costPct: 3,  baseDays: 10, dependsOn: [9],   color: '#0891B2',
      subtasks: ['Waste pipes', 'Water supply pipes', 'Drainage lines'],
      checklist: ['All pipes pressure tested', 'Waste line slope verified'],
    ),
    _TemplateStage(order: 11, name: 'Electrical Rough-In',       nameUr: 'الیکٹریکل',            costPct: 3,  baseDays: 10, dependsOn: [9],   color: '#CA8A04',
      subtasks: ['Conduit installation', 'Pull wires', 'Distribution board position'],
      checklist: ['Conduit complete', 'Wires pulled', 'DB position confirmed'],
    ),
    _TemplateStage(order: 12, name: 'Plaster & Waterproofing',  nameUr: 'پلستر',               costPct: 5,  baseDays: 21, dependsOn: [10, 11], color: '#0EA5E9',
      subtasks: ['External plaster', 'Internal plaster', 'Roof waterproofing', 'Wet area waterproofing'],
      checklist: ['External plaster complete', 'Internal plaster complete', 'Waterproofing tested (water ponding)'],
    ),
    _TemplateStage(order: 13, name: 'Flooring',                  nameUr: 'فرش',                  costPct: 7,  baseDays: 14, dependsOn: [12],  color: '#16A34A',
      subtasks: ['Screed layer', 'Tile bedding', 'Floor tile installation', 'Grouting'],
      checklist: ['Floor level verified', 'No hollow tiles', 'Grouting complete'],
    ),
    _TemplateStage(order: 14, name: 'Ceiling Work',              nameUr: 'چھت کا کام',           costPct: 4,  baseDays: 10, dependsOn: [12],  color: '#475569',
      subtasks: ['False ceiling framing', 'Ceiling board', 'Cornice'],
      checklist: ['Ceiling level verified', 'No sagging'],
    ),
    _TemplateStage(order: 15, name: 'Doors & Windows',           nameUr: 'دروازے اور کھڑکیاں',  costPct: 5,  baseDays: 10, dependsOn: [13, 14], color: '#92400E',
      subtasks: ['Door frames', 'Door shutters', 'Window frames', 'Window panes', 'Hardware'],
      checklist: ['All doors installed & operating', 'All windows installed & sealed'],
    ),
    _TemplateStage(order: 16, name: 'Paint',                     nameUr: 'پینٹ',                 costPct: 4,  baseDays: 14, dependsOn: [15],  color: '#E879F9',
      subtasks: ['Wall putty', 'Primer coat', 'First paint coat', 'Second paint coat'],
      checklist: ['Putty smooth', 'Two coats applied', 'No patches'],
    ),
    _TemplateStage(order: 17, name: 'Kitchen & Fixtures',        nameUr: 'کچن اور فکسچر',       costPct: 5,  baseDays: 14, dependsOn: [16],  color: '#F97316',
      subtasks: ['Kitchen cabinets', 'Counter top', 'Sanitary fixtures', 'Electrical fixtures'],
      checklist: ['Kitchen installed', 'All fixtures installed & working'],
    ),
    _TemplateStage(order: 18, name: 'Final Inspection & Handover', nameUr: 'حوالگی',            costPct: 1,  baseDays: 5,  dependsOn: [17],  isMilestone: true, color: '#22C55E',
      subtasks: ['Snag list walk-through', 'Defects rectified', 'Keys handover', 'Documents handover'],
      checklist: ['Snag list cleared', 'All documents prepared', 'Final walk-through done'],
    ),
  ];

  static const List<_TemplateStage> renovation = [
    _TemplateStage(order: 1, name: 'Scope & Design',         nameUr: 'ڈیزائن',           costPct: 3,  baseDays: 7,  dependsOn: [],    color: '#8B5CF6',
      subtasks: ['Measure existing', 'Agree on scope', 'Final design'],
      checklist: ['Scope signed off', 'Materials list ready'],
    ),
    _TemplateStage(order: 2, name: 'Demolition',             nameUr: 'توڑ پھوڑ',         costPct: 5,  baseDays: 5,  dependsOn: [1],  color: '#DC2626',
      subtasks: ['Protect existing areas', 'Demolition', 'Debris removal'],
      checklist: ['Demolition complete', 'Debris removed', 'Existing services marked'],
    ),
    _TemplateStage(order: 3, name: 'Plumbing & Electrical',  nameUr: 'پلمبنگ اور بجلی', costPct: 20, baseDays: 10, dependsOn: [2],  color: '#0891B2',
      subtasks: ['Rough-in plumbing', 'Rough-in electrical', 'Pressure test'],
      checklist: ['Plumbing tested', 'Electrical conduit complete'],
    ),
    _TemplateStage(order: 4, name: 'Waterproofing',          nameUr: 'واٹر پروفنگ',     costPct: 8,  baseDays: 5,  dependsOn: [3],  color: '#0EA5E9',
      subtasks: ['Apply waterproofing membrane', 'Test with water'],
      checklist: ['Waterproofing passes 24h water test'],
    ),
    _TemplateStage(order: 5, name: 'Tiling',                 nameUr: 'ٹائلیں',           costPct: 25, baseDays: 10, dependsOn: [4],  color: '#16A34A',
      subtasks: ['Floor tiles', 'Wall tiles', 'Grouting'],
      checklist: ['No hollow tiles', 'Grout joints even'],
    ),
    _TemplateStage(order: 6, name: 'Fixtures & Finishing',   nameUr: 'فکسچر',           costPct: 30, baseDays: 7,  dependsOn: [5],  color: '#F97316',
      subtasks: ['Sanitary fixtures', 'Electrical fixtures', 'Accessories', 'Silicon joints'],
      checklist: ['All fixtures working', 'No leaks'],
    ),
    _TemplateStage(order: 7, name: 'Final Touch & Handover', nameUr: 'حوالگی',           costPct: 9,  baseDays: 3,  dependsOn: [6],  isMilestone: true, color: '#22C55E',
      subtasks: ['Clean up', 'Touch-up paint', 'Client walk-through'],
      checklist: ['Clean complete', 'Client sign-off'],
    ),
  ];

  static const List<_TemplateStage> commercial = [
    _TemplateStage(order: 1,  name: 'Approvals & NOC',          nameUr: 'منظوری',         costPct: 2,  baseDays: 30, dependsOn: [],    isMilestone: true, color: '#8B5CF6',
      checklist: ['NOC obtained', 'Building plan approved', 'EOBI registration'],
    ),
    _TemplateStage(order: 2,  name: 'Site Preparation',          nameUr: 'سائٹ کی تیاری', costPct: 1,  baseDays: 7,  dependsOn: [1],  color: '#64748B'),
    _TemplateStage(order: 3,  name: 'Excavation & Dewatering',   nameUr: 'کھدائی',         costPct: 3,  baseDays: 14, dependsOn: [2],  color: '#92400E'),
    _TemplateStage(order: 4,  name: 'Foundation & Pile Work',    nameUr: 'بنیاد',           costPct: 12, baseDays: 28, dependsOn: [3],  isMilestone: true, color: '#B45309',
      checklist: ['Pile test report received', 'Foundation level certified by engineer'],
    ),
    _TemplateStage(order: 5,  name: 'Ground Floor Structure',    nameUr: 'گراؤنڈ فلور',    costPct: 10, baseDays: 30, dependsOn: [4],  color: '#1D4ED8'),
    _TemplateStage(order: 6,  name: 'Upper Floors Structure',    nameUr: 'اوپری منزلیں',   costPct: 18, baseDays: 45, dependsOn: [5],  color: '#1D4ED8'),
    _TemplateStage(order: 7,  name: 'Roof & Terrace',            nameUr: 'چھت',             costPct: 6,  baseDays: 14, dependsOn: [6],  isMilestone: true, color: '#7C3AED'),
    _TemplateStage(order: 8,  name: 'MEP Rough-In',              nameUr: 'MEP',             costPct: 8,  baseDays: 21, dependsOn: [7],  color: '#0891B2'),
    _TemplateStage(order: 9,  name: 'External Cladding & Glazing',nameUr:'بیرونی',         costPct: 10, baseDays: 21, dependsOn: [7],  color: '#0EA5E9'),
    _TemplateStage(order: 10, name: 'Internal Fit-Out',          nameUr: 'اندرونی',        costPct: 15, baseDays: 30, dependsOn: [8],  color: '#16A34A'),
    _TemplateStage(order: 11, name: 'MEP Commissioning',         nameUr: 'کمیشننگ',        costPct: 4,  baseDays: 14, dependsOn: [10], color: '#CA8A04',
      checklist: ['HVAC commissioned', 'Electrical load tested', 'Fire suppression tested'],
    ),
    _TemplateStage(order: 12, name: 'Snag List & Handover',      nameUr: 'حوالگی',         costPct: 1,  baseDays: 7,  dependsOn: [11], isMilestone: true, color: '#22C55E',
      checklist: ['Snag list cleared', 'Completion certificate obtained'],
    ),
  ];

  static const List<_TemplateStage> bathroom = [
    _TemplateStage(order: 1, name: 'Demolition & Removal',  nameUr: 'توڑ پھوڑ',        costPct: 8,  baseDays: 3, dependsOn: [], color: '#DC2626'),
    _TemplateStage(order: 2, name: 'Plumbing Rough-In',     nameUr: 'پلمبنگ',          costPct: 20, baseDays: 5, dependsOn: [1], color: '#0891B2'),
    _TemplateStage(order: 3, name: 'Waterproofing',         nameUr: 'واٹر پروفنگ',    costPct: 10, baseDays: 4, dependsOn: [2], color: '#0EA5E9'),
    _TemplateStage(order: 4, name: 'Tiling',                nameUr: 'ٹائلیں',          costPct: 25, baseDays: 7, dependsOn: [3], color: '#16A34A'),
    _TemplateStage(order: 5, name: 'Electrical & Lighting', nameUr: 'الیکٹریکل',       costPct: 12, baseDays: 3, dependsOn: [3], color: '#CA8A04'),
    _TemplateStage(order: 6, name: 'Fixtures & Fittings',   nameUr: 'فکسچر',           costPct: 20, baseDays: 4, dependsOn: [4, 5], color: '#F97316'),
    _TemplateStage(order: 7, name: 'Final Touch',           nameUr: 'حوالگی',           costPct: 5,  baseDays: 2, dependsOn: [6], isMilestone: true, color: '#22C55E'),
  ];

  static const List<_TemplateStage> kitchen = [
    _TemplateStage(order: 1, name: 'Demo & Prep',         nameUr: 'تیاری',             costPct: 5,  baseDays: 3, dependsOn: [], color: '#DC2626'),
    _TemplateStage(order: 2, name: 'Plumbing & Electrical',nameUr:'پلمبنگ اور بجلی',  costPct: 15, baseDays: 7, dependsOn: [1], color: '#0891B2'),
    _TemplateStage(order: 3, name: 'Wall & Floor Tiling', nameUr: 'ٹائلیں',            costPct: 20, baseDays: 7, dependsOn: [2], color: '#16A34A'),
    _TemplateStage(order: 4, name: 'Cabinets & Counter',  nameUr: 'الماری',             costPct: 35, baseDays: 7, dependsOn: [3], color: '#92400E'),
    _TemplateStage(order: 5, name: 'Appliances & Finish', nameUr: 'آلات',              costPct: 20, baseDays: 4, dependsOn: [4], isMilestone: true, color: '#22C55E'),
    _TemplateStage(order: 6, name: 'Final Handover',      nameUr: 'حوالگی',            costPct: 5,  baseDays: 1, dependsOn: [5], isMilestone: true, color: '#22C55E'),
  ];

  static const List<_TemplateStage> boundaryWall = [
    _TemplateStage(order: 1, name: 'Excavation',          nameUr: 'کھدائی',            costPct: 10, baseDays: 3, dependsOn: [], color: '#92400E'),
    _TemplateStage(order: 2, name: 'Foundation',          nameUr: 'بنیاد',              costPct: 20, baseDays: 5, dependsOn: [1], color: '#B45309'),
    _TemplateStage(order: 3, name: 'Brick / Block Work',  nameUr: 'اینٹوں کا کام',    costPct: 45, baseDays: 10, dependsOn: [2], color: '#DC2626'),
    _TemplateStage(order: 4, name: 'Plaster & Coping',   nameUr: 'پلستر',              costPct: 20, baseDays: 5, dependsOn: [3], color: '#0EA5E9'),
    _TemplateStage(order: 5, name: 'Gate & Finish',       nameUr: 'گیٹ',               costPct: 5,  baseDays: 3, dependsOn: [4], isMilestone: true, color: '#22C55E'),
  ];

  static const List<_TemplateStage> greyStructure = [
    _TemplateStage(order: 1,  name: 'Excavation',                nameUr: 'کھدائی',    costPct: 4,  baseDays: 7,  dependsOn: [],    color: '#92400E'),
    _TemplateStage(order: 2,  name: 'Foundation',                nameUr: 'بنیاد',     costPct: 15, baseDays: 21, dependsOn: [1],   isMilestone: true, color: '#B45309'),
    _TemplateStage(order: 3,  name: 'Plinth Beam',               nameUr: 'پلنتھ بیم', costPct: 6,  baseDays: 10, dependsOn: [2],   color: '#D97706'),
    _TemplateStage(order: 4,  name: 'Ground Floor Structure',    nameUr: 'گراؤنڈ فلور',costPct: 20, baseDays: 35, dependsOn: [3],   color: '#1D4ED8'),
    _TemplateStage(order: 5,  name: 'First Floor Structure',     nameUr: 'پہلی منزل', costPct: 18, baseDays: 30, dependsOn: [4],   color: '#1D4ED8'),
    _TemplateStage(order: 6,  name: 'Roof Slab',                 nameUr: 'چھت',       costPct: 12, baseDays: 14, dependsOn: [5],   isMilestone: true, color: '#7C3AED'),
    _TemplateStage(order: 7,  name: 'Brick / Block Work',        nameUr: 'اینٹیں',   costPct: 15, baseDays: 21, dependsOn: [6],   color: '#DC2626'),
    _TemplateStage(order: 8,  name: 'Lintels & Arches',         nameUr: 'لنٹل',     costPct: 5,  baseDays: 7,  dependsOn: [7],   color: '#B45309'),
    _TemplateStage(order: 9,  name: 'Staircase',                nameUr: 'سیڑھی',   costPct: 5,  baseDays: 14, dependsOn: [7],   color: '#8B5CF6'),
    _TemplateStage(order: 10, name: 'Structure Handover',        nameUr: 'حوالگی',  costPct: 0,  baseDays: 3,  dependsOn: [8, 9], isMilestone: true, color: '#22C55E'),
  ];

  /// Returns the correct template for a given project type
  static List<_TemplateStage> forType(String projectType) => switch (projectType) {
        'house' || 'villa'   => house,
        'commercial' || 'office' || 'plaza' => commercial,
        'renovation'         => renovation,
        'bathroom'           => bathroom,
        'kitchen'            => kitchen,
        'boundary_wall'      => boundaryWall,
        'grey_structure'     => greyStructure,
        'apartment'          => house, // same structure as house, larger scale
        'extension'          => greyStructure,
        _                    => house,
      };
}

// ── Timeline Engine ───────────────────────────────────────────────────────────

class TimelineEngine {
  TimelineEngine._();

  static const _uuid = Uuid();

  /// Main entry point. Generates stages for a scope.
  static List<StageModel> generateForScope({
    required ProjectScopeModel scope,
    required DateTime projectStart,
    String region = 'PK',
  }) {
    final template = TimelineTemplates.forType(scope.projectType);
    final scaled   = _scaleByProjectParams(template, scope);
    final dated    = _computeDates(scaled, projectStart);
    final budgeted = _distributeBudget(dated, scope.budgetAmount);
    return budgeted;
  }

  // ── Duration scaling ──────────────────────────────────────────────────────

  static List<_ScaledStage> _scaleByProjectParams(
    List<_TemplateStage> template,
    ProjectScopeModel scope,
  ) {
    final areaSqm = scope.constructionAreaSqm ?? scope.plotSizeSqm ?? 126.0;
    final sizeFactor    = _sizeFactor(areaSqm);
    final qualityFactor = _qualityFactor(scope.qualityTier);
    final floorFactor   = scope.floors > 1
        ? 1.0 + (scope.floors - 1) * 0.55
        : 1.0;

    return template.map((s) {
      double factor = sizeFactor * qualityFactor;
      if (_isStructureStage(s.name)) factor *= floorFactor;

      final scaled = (s.baseDays * factor).round();
      return _ScaledStage(
        template: s,
        scaledDays: scaled.clamp(s.baseDays, (s.baseDays * 4).ceil()),
      );
    }).toList();
  }

  static double _sizeFactor(double sqm) {
    if (sqm < 60)  return 0.65;
    if (sqm < 130) return 1.0;   // 5 Marla ≈ 126 sqm
    if (sqm < 260) return 1.3;
    if (sqm < 520) return 1.65;
    return 2.1;
  }

  static double _qualityFactor(String tier) => switch (tier) {
        'economy'  => 0.8,
        'standard' => 1.0,
        'premium'  => 1.35,
        'luxury'   => 1.8,
        _          => 1.0,
      };

  static bool _isStructureStage(String name) {
    final lower = name.toLowerCase();
    return lower.contains('structure') ||
        lower.contains('floor') ||
        lower.contains('slab') ||
        lower.contains('column');
  }

  // ── Date computation (critical path) ─────────────────────────────────────

  static List<_DatedStage> _computeDates(
    List<_ScaledStage> stages,
    DateTime projectStart,
  ) {
    final computed = <int, _DatedStage>{};

    for (final s in stages) {
      DateTime start = projectStart;

      for (final depOrder in s.template.dependsOn) {
        final dep = computed[depOrder];
        if (dep != null && dep.end.isAfter(start)) {
          start = dep.end;
        }
      }

      start = _nextWorkingDay(start);
      final end = _addWorkingDays(start, s.scaledDays);

      computed[s.template.order] = _DatedStage(
        scaled: s,
        start: start,
        end: end,
      );
    }

    return computed.values.toList()
      ..sort((a, b) =>
          a.scaled.template.order.compareTo(b.scaled.template.order));
  }

  /// Skip Friday (Pakistan) — configurable per country in future
  static DateTime _nextWorkingDay(DateTime date) {
    while (date.weekday == DateTime.friday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  static DateTime _addWorkingDays(DateTime start, int days) {
    var d = start;
    var added = 0;
    while (added < days) {
      d = d.add(const Duration(days: 1));
      if (d.weekday != DateTime.friday) added++;
    }
    return d;
  }

  // ── Budget distribution ───────────────────────────────────────────────────

  static List<StageModel> _distributeBudget(
    List<_DatedStage> dated,
    double totalBudget,
  ) {
    final totalPct = dated.fold(0.0, (s, d) => s + d.scaled.template.costPct);

    return dated.asMap().entries.map((entry) {
      final idx = entry.key;
      final d   = entry.value;
      final t   = d.scaled.template;

      final normalizedPct = totalPct > 0 ? t.costPct / totalPct : 0.0;
      final stageBudget   = totalBudget * normalizedPct;

      final scopeId   = ''; // filled in by caller
      final projectId = ''; // filled in by caller

      return StageModel(
        id: _uuid.v4(),
        scopeId: scopeId,
        projectId: projectId,
        name: t.name,
        description: null,
        stageOrder: t.order,
        status: idx == 0
            ? StageStatus.inProgress
            : StageStatus.notStarted,
        isMilestone: t.isMilestone,
        color: t.color,
        plannedStart: d.start,
        plannedEnd: d.end,
        durationDays: d.scaled.scaledDays,
        budgetAmount: stageBudget,
        budgetPct: normalizedPct * 100,
        subtasks: t.subtasks
            .asMap()
            .entries
            .map((e) => SubtaskModel(
                  id: _uuid.v4(),
                  stageId: '',  // filled in after stage is saved
                  name: e.value,
                  taskOrder: e.key + 1,
                ))
            .toList(),
        checklist: t.checklist
            .asMap()
            .entries
            .map((e) => ChecklistItemModel(
                  id: _uuid.v4(),
                  stageId: '',
                  description: e.value,
                  isRequired: true,
                  sortOrder: e.key + 1,
                ))
            .toList(),
      );
    }).toList();
  }

  // ── Dependency validation (for drag-drop reordering) ─────────────────────

  /// Returns true if moving [stageId] to [targetIndex] is valid.
  static bool canReorder({
    required List<StageModel> stages,
    required String stageId,
    required int targetIndex,
  }) {
    final currentIndex = stages.indexWhere((s) => s.id == stageId);
    if (currentIndex == -1 || targetIndex == currentIndex) return true;

    // We store dependencies by stageOrder in templates.
    // In the live list, dependencies = stages that must come BEFORE this stage.
    // For simplicity in Phase 1: a stage cannot be moved before any stage
    // that it appears after in the current ordered list if that stage has
    // a lower order. This is a conservative check.

    // Cannot move forward (to lower index) past a stage that was originally
    // defined as a dependency.
    // Full dependency graph validation requires storing dependsOn IDs — Phase 2.
    return true; // Permit all reordering in Phase 1; validation added in Phase 2
  }

  /// Recomputes planned dates after a reorder.
  static List<StageModel> recomputeDatesAfterReorder({
    required List<StageModel> stages,
    required DateTime projectStart,
  }) {
    DateTime cursor = projectStart;
    return stages.asMap().entries.map((entry) {
      final s = entry.value;
      final start = _nextWorkingDay(cursor);
      final end = _addWorkingDays(start, s.durationDays ?? 14);
      cursor = end;
      return s.copyWith(plannedStart: start, plannedEnd: end);
    }).toList();
  }
}

// ── Internal value objects ────────────────────────────────────────────────────

class _ScaledStage {
  final _TemplateStage template;
  final int scaledDays;
  const _ScaledStage({required this.template, required this.scaledDays});
}

class _DatedStage {
  final _ScaledStage scaled;
  final DateTime start;
  final DateTime end;
  const _DatedStage({required this.scaled, required this.start, required this.end});
}
