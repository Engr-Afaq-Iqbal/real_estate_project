import 'dart:math' as math;

// ── Enums ─────────────────────────────────────────────────────────────────────

enum FieldType {
  textInput,
  numberCounter,
  qualitySelector,
  chipSelector,
  yesNoToggle,
  areaInput,
  textArea,
}

// ── Field config ──────────────────────────────────────────────────────────────

class FieldConfig {
  final String key;
  final String label;
  final String? hint;
  final FieldType type;
  final dynamic defaultValue;
  final List<String>? options;     // for chipSelector
  final int? min;                  // for counter
  final int? max;                  // for counter
  final bool required;

  const FieldConfig({
    required this.key,
    required this.label,
    this.hint,
    required this.type,
    this.defaultValue,
    this.options,
    this.min,
    this.max,
    this.required = false,
  });
}

// ── Stage template ────────────────────────────────────────────────────────────

class WizardStageTemplate {
  final String name;
  final int baseDurationDays;
  final double costPct;
  final String color;            // hex

  const WizardStageTemplate({
    required this.name,
    required this.baseDurationDays,
    required this.costPct,
    this.color = '#3B82F6',
  });
}

// ── Team option ───────────────────────────────────────────────────────────────

class TeamOption {
  final String key;
  final String label;
  final String subtitle;
  final String icon;

  const TeamOption({
    required this.key,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}

// ── Project type config ───────────────────────────────────────────────────────

class ProjectTypeConfig {
  final String key;
  final String label;
  final String icon;
  final List<FieldConfig> step2Fields;
  final bool showPlotArea;      // show plot section in Step 3
  final List<WizardStageTemplate> stages;
  final List<TeamOption> teamOptions;

  const ProjectTypeConfig({
    required this.key,
    required this.label,
    required this.icon,
    required this.step2Fields,
    this.showPlotArea = true,
    required this.stages,
    required this.teamOptions,
  });
}

// ── Quality tiers ─────────────────────────────────────────────────────────────

const List<String> kQualityTiers = [
  'Economy', 'Standard', 'Premium', 'Luxury',
];

// ── Standard team options ─────────────────────────────────────────────────────

const _standardTeam = [
  TeamOption(key: 'self',       label: 'Self-Managed',       subtitle: 'I will manage everything', icon: '👤'),
  TeamOption(key: 'contractor', label: 'Local Contractor',   subtitle: 'Hire a local mistry or contractor', icon: '🔨'),
  TeamOption(key: 'company',    label: 'Construction Co.',   subtitle: 'Registered construction company', icon: '🏢'),
];

const _interiorTeam = [
  TeamOption(key: 'self',       label: 'Self-Managed',       subtitle: 'I will manage everything', icon: '👤'),
  TeamOption(key: 'designer',   label: 'Interior Designer',  subtitle: 'Hire a professional designer', icon: '🎨'),
  TeamOption(key: 'company',    label: 'Construction Co.',   subtitle: 'Registered construction company', icon: '🏢'),
];

const _landscapeTeam = [
  TeamOption(key: 'self',       label: 'Self-Managed',       subtitle: 'I will manage everything', icon: '👤'),
  TeamOption(key: 'contractor', label: 'Landscape Contractor', subtitle: 'Hire a landscape specialist', icon: '🌿'),
  TeamOption(key: 'company',    label: 'Construction Co.',   subtitle: 'Registered construction company', icon: '🏢'),
];

// ── Stage templates ───────────────────────────────────────────────────────────

const _houseStages = [
  WizardStageTemplate(name: 'Design & Approvals',      baseDurationDays: 21,  costPct: 2,  color: '#8B5CF6'),
  WizardStageTemplate(name: 'Site Preparation',         baseDurationDays: 5,   costPct: 1,  color: '#64748B'),
  WizardStageTemplate(name: 'Excavation',               baseDurationDays: 7,   costPct: 3,  color: '#92400E'),
  WizardStageTemplate(name: 'Foundation',               baseDurationDays: 21,  costPct: 12, color: '#B45309'),
  WizardStageTemplate(name: 'Plinth Beam',              baseDurationDays: 10,  costPct: 5,  color: '#D97706'),
  WizardStageTemplate(name: 'Ground Floor Structure',   baseDurationDays: 35,  costPct: 14, color: '#1D4ED8'),
  WizardStageTemplate(name: 'First Floor Structure',    baseDurationDays: 30,  costPct: 12, color: '#1D4ED8'),
  WizardStageTemplate(name: 'Roof Slab',                baseDurationDays: 14,  costPct: 8,  color: '#7C3AED'),
  WizardStageTemplate(name: 'Brick / Block Work',       baseDurationDays: 21,  costPct: 5,  color: '#DC2626'),
  WizardStageTemplate(name: 'Plumbing Rough-In',        baseDurationDays: 10,  costPct: 3,  color: '#0891B2'),
  WizardStageTemplate(name: 'Electrical Rough-In',      baseDurationDays: 10,  costPct: 3,  color: '#CA8A04'),
  WizardStageTemplate(name: 'Plaster & Waterproofing',  baseDurationDays: 21,  costPct: 5,  color: '#0EA5E9'),
  WizardStageTemplate(name: 'Flooring',                 baseDurationDays: 14,  costPct: 7,  color: '#16A34A'),
  WizardStageTemplate(name: 'Ceiling Work',             baseDurationDays: 10,  costPct: 4,  color: '#475569'),
  WizardStageTemplate(name: 'Doors & Windows',          baseDurationDays: 10,  costPct: 5,  color: '#92400E'),
  WizardStageTemplate(name: 'Paint',                    baseDurationDays: 14,  costPct: 4,  color: '#E879F9'),
  WizardStageTemplate(name: 'Kitchen & Fixtures',       baseDurationDays: 14,  costPct: 5,  color: '#F97316'),
  WizardStageTemplate(name: 'Final Inspection',         baseDurationDays: 5,   costPct: 1,  color: '#22C55E'),
];

const _renovationStages = [
  WizardStageTemplate(name: 'Scope & Design',           baseDurationDays: 7,   costPct: 3,  color: '#8B5CF6'),
  WizardStageTemplate(name: 'Demolition',               baseDurationDays: 5,   costPct: 5,  color: '#DC2626'),
  WizardStageTemplate(name: 'Plumbing & Electrical',    baseDurationDays: 10,  costPct: 20, color: '#0891B2'),
  WizardStageTemplate(name: 'Waterproofing',            baseDurationDays: 5,   costPct: 8,  color: '#0EA5E9'),
  WizardStageTemplate(name: 'Tiling',                   baseDurationDays: 10,  costPct: 25, color: '#16A34A'),
  WizardStageTemplate(name: 'Fixtures & Finishing',     baseDurationDays: 7,   costPct: 30, color: '#F97316'),
  WizardStageTemplate(name: 'Final Handover',           baseDurationDays: 3,   costPct: 9,  color: '#22C55E'),
];

const _commercialStages = [
  WizardStageTemplate(name: 'Approvals & NOC',          baseDurationDays: 30,  costPct: 2,  color: '#8B5CF6'),
  WizardStageTemplate(name: 'Site Preparation',         baseDurationDays: 7,   costPct: 1,  color: '#64748B'),
  WizardStageTemplate(name: 'Excavation & Dewatering',  baseDurationDays: 14,  costPct: 3,  color: '#92400E'),
  WizardStageTemplate(name: 'Foundation & Piling',      baseDurationDays: 28,  costPct: 12, color: '#B45309'),
  WizardStageTemplate(name: 'Ground Floor Structure',   baseDurationDays: 30,  costPct: 10, color: '#1D4ED8'),
  WizardStageTemplate(name: 'Upper Floors Structure',   baseDurationDays: 45,  costPct: 18, color: '#1D4ED8'),
  WizardStageTemplate(name: 'Roof & Terrace',           baseDurationDays: 14,  costPct: 6,  color: '#7C3AED'),
  WizardStageTemplate(name: 'MEP Rough-In',             baseDurationDays: 21,  costPct: 8,  color: '#0891B2'),
  WizardStageTemplate(name: 'External Cladding',        baseDurationDays: 21,  costPct: 10, color: '#0EA5E9'),
  WizardStageTemplate(name: 'Internal Fit-Out',         baseDurationDays: 30,  costPct: 15, color: '#16A34A'),
  WizardStageTemplate(name: 'MEP Commissioning',        baseDurationDays: 14,  costPct: 4,  color: '#CA8A04'),
  WizardStageTemplate(name: 'Handover',                 baseDurationDays: 7,   costPct: 1,  color: '#22C55E'),
];

const _kitchenStages = [
  WizardStageTemplate(name: 'Demo & Prep',              baseDurationDays: 3,   costPct: 5,  color: '#DC2626'),
  WizardStageTemplate(name: 'Plumbing & Electrical',    baseDurationDays: 7,   costPct: 15, color: '#0891B2'),
  WizardStageTemplate(name: 'Wall & Floor Tiling',      baseDurationDays: 7,   costPct: 20, color: '#16A34A'),
  WizardStageTemplate(name: 'Cabinets & Counter',       baseDurationDays: 7,   costPct: 35, color: '#92400E'),
  WizardStageTemplate(name: 'Appliances & Finish',      baseDurationDays: 4,   costPct: 20, color: '#F97316'),
  WizardStageTemplate(name: 'Final Handover',           baseDurationDays: 1,   costPct: 5,  color: '#22C55E'),
];

const _bathroomStages = [
  WizardStageTemplate(name: 'Demolition & Removal',     baseDurationDays: 3,   costPct: 8,  color: '#DC2626'),
  WizardStageTemplate(name: 'Plumbing Rough-In',        baseDurationDays: 5,   costPct: 20, color: '#0891B2'),
  WizardStageTemplate(name: 'Waterproofing',            baseDurationDays: 4,   costPct: 10, color: '#0EA5E9'),
  WizardStageTemplate(name: 'Tiling',                   baseDurationDays: 7,   costPct: 25, color: '#16A34A'),
  WizardStageTemplate(name: 'Electrical & Lighting',    baseDurationDays: 3,   costPct: 12, color: '#CA8A04'),
  WizardStageTemplate(name: 'Fixtures & Fittings',      baseDurationDays: 4,   costPct: 20, color: '#F97316'),
  WizardStageTemplate(name: 'Final Touch',              baseDurationDays: 2,   costPct: 5,  color: '#22C55E'),
];

const _boundaryStages = [
  WizardStageTemplate(name: 'Excavation',               baseDurationDays: 3,   costPct: 10, color: '#92400E'),
  WizardStageTemplate(name: 'Foundation',               baseDurationDays: 5,   costPct: 20, color: '#B45309'),
  WizardStageTemplate(name: 'Brick / Block Work',       baseDurationDays: 10,  costPct: 45, color: '#DC2626'),
  WizardStageTemplate(name: 'Plaster & Coping',         baseDurationDays: 5,   costPct: 20, color: '#0EA5E9'),
  WizardStageTemplate(name: 'Gate & Finish',            baseDurationDays: 3,   costPct: 5,  color: '#22C55E'),
];

const _landscapeStages = [
  WizardStageTemplate(name: 'Site Preparation',         baseDurationDays: 3,   costPct: 10, color: '#64748B'),
  WizardStageTemplate(name: 'Earthwork & Grading',      baseDurationDays: 5,   costPct: 15, color: '#92400E'),
  WizardStageTemplate(name: 'Irrigation System',        baseDurationDays: 7,   costPct: 20, color: '#0EA5E9'),
  WizardStageTemplate(name: 'Hardscape (Paths/Walls)',  baseDurationDays: 10,  costPct: 25, color: '#B45309'),
  WizardStageTemplate(name: 'Planting & Lawn',          baseDurationDays: 7,   costPct: 25, color: '#16A34A'),
  WizardStageTemplate(name: 'Finishing & Cleanup',      baseDurationDays: 3,   costPct: 5,  color: '#22C55E'),
];

const _greyStructureStages = [
  WizardStageTemplate(name: 'Excavation',               baseDurationDays: 7,   costPct: 4,  color: '#92400E'),
  WizardStageTemplate(name: 'Foundation',               baseDurationDays: 21,  costPct: 15, color: '#B45309'),
  WizardStageTemplate(name: 'Plinth Beam',              baseDurationDays: 10,  costPct: 6,  color: '#D97706'),
  WizardStageTemplate(name: 'Ground Floor Structure',   baseDurationDays: 35,  costPct: 20, color: '#1D4ED8'),
  WizardStageTemplate(name: 'First Floor Structure',    baseDurationDays: 30,  costPct: 18, color: '#1D4ED8'),
  WizardStageTemplate(name: 'Roof Slab',                baseDurationDays: 14,  costPct: 12, color: '#7C3AED'),
  WizardStageTemplate(name: 'Brick / Block Work',       baseDurationDays: 21,  costPct: 15, color: '#DC2626'),
  WizardStageTemplate(name: 'Lintels & Staircase',      baseDurationDays: 14,  costPct: 5,  color: '#8B5CF6'),
  WizardStageTemplate(name: 'Structure Handover',       baseDurationDays: 3,   costPct: 5,  color: '#22C55E'),
];

// ── Step 2 field definitions per type ────────────────────────────────────────

const _houseFields = [
  FieldConfig(key: 'name',      label: 'Project Name',  hint: 'e.g. DHA House — 10 Marla',   type: FieldType.textInput),
  FieldConfig(key: 'floors',    label: 'Number of Floors', type: FieldType.numberCounter, defaultValue: 1, min: 1, max: 4),
  FieldConfig(key: 'quality',   label: 'Construction Quality', type: FieldType.qualitySelector, defaultValue: 'Standard'),
  FieldConfig(key: 'bedrooms',  label: 'Bedrooms',      type: FieldType.numberCounter, defaultValue: 3, min: 1, max: 10),
  FieldConfig(key: 'bathrooms', label: 'Bathrooms',     type: FieldType.numberCounter, defaultValue: 2, min: 1, max: 10),
  FieldConfig(key: 'extras',    label: 'Additional Spaces', type: FieldType.chipSelector,
      options: ['Drawing Room', 'Lounge', 'Servant Quarter', 'Store Room', 'Garage']),
];

const _commercialFields = [
  FieldConfig(key: 'name',     label: 'Project Name',  hint: 'e.g. Bahria Commercial Plaza', type: FieldType.textInput),
  FieldConfig(key: 'floors',   label: 'Number of Floors', type: FieldType.numberCounter, defaultValue: 3, min: 1, max: 20),
  FieldConfig(key: 'quality',  label: 'Construction Quality', type: FieldType.qualitySelector, defaultValue: 'Standard'),
  FieldConfig(key: 'purpose',  label: 'Purpose',       type: FieldType.chipSelector,
      options: ['Shops', 'Offices', 'Mix-Use', 'Showroom', 'Hospital']),
  FieldConfig(key: 'basement', label: 'Basement Required?', type: FieldType.yesNoToggle, defaultValue: false),
];

const _shopOfficeFields = [
  FieldConfig(key: 'name',    label: 'Project Name',   hint: 'e.g. Corner Shop — Block C',  type: FieldType.textInput),
  FieldConfig(key: 'floor',   label: 'Which Floor?',   type: FieldType.chipSelector,
      options: ['Ground Floor', 'First Floor', 'Second Floor', 'Basement']),
  FieldConfig(key: 'quality', label: 'Finish Quality', type: FieldType.qualitySelector, defaultValue: 'Standard'),
];

const _kitchenFields = [
  FieldConfig(key: 'name',   label: 'Project Name',  hint: 'e.g. Kitchen Remodel — Master',  type: FieldType.textInput),
  FieldConfig(key: 'floor',  label: 'Which Floor?',  type: FieldType.numberCounter, defaultValue: 1, min: 1, max: 5),
  FieldConfig(key: 'scope',  label: 'Scope of Work', type: FieldType.chipSelector,
      options: ['Full Renovation', 'Partial', 'New Installation', 'Cabinet Replacement']),
  FieldConfig(key: 'quality', label: 'Finish Quality', type: FieldType.qualitySelector, defaultValue: 'Standard'),
];

const _bathroomFields = [
  FieldConfig(key: 'name',   label: 'Project Name',  hint: 'e.g. Master Bathroom Remodel',  type: FieldType.textInput),
  FieldConfig(key: 'floor',  label: 'Which Floor?',  type: FieldType.numberCounter, defaultValue: 1, min: 1, max: 5),
  FieldConfig(key: 'scope',  label: 'Scope of Work', type: FieldType.chipSelector,
      options: ['Full Renovation', 'Partial', 'New Installation', 'Waterproofing Only']),
  FieldConfig(key: 'quality', label: 'Finish Quality', type: FieldType.qualitySelector, defaultValue: 'Standard'),
];

const _boundaryFields = [
  FieldConfig(key: 'name',     label: 'Project Name',  hint: 'e.g. Front Boundary Wall',    type: FieldType.textInput),
  FieldConfig(key: 'length',   label: 'Wall Length',   type: FieldType.areaInput, hint: 'Running feet'),
  FieldConfig(key: 'height',   label: 'Wall Height',   type: FieldType.areaInput, hint: 'Feet'),
  FieldConfig(key: 'gate',     label: 'Gate Required?', type: FieldType.yesNoToggle, defaultValue: true),
  FieldConfig(key: 'material', label: 'Material',      type: FieldType.chipSelector,
      options: ['Brick', 'Block', 'Stone', 'RCC']),
];

const _landscapeFields = [
  FieldConfig(key: 'name',       label: 'Project Name',    hint: 'e.g. Front Garden',    type: FieldType.textInput),
  FieldConfig(key: 'type',       label: 'Landscape Type',  type: FieldType.chipSelector,
      options: ['Garden', 'Driveway', 'Lawn', 'Rooftop', 'Both Garden & Driveway']),
  FieldConfig(key: 'irrigation', label: 'Irrigation System Needed?', type: FieldType.yesNoToggle, defaultValue: false),
  FieldConfig(key: 'quality',    label: 'Quality',         type: FieldType.qualitySelector, defaultValue: 'Standard'),
];

const _greyStructureFields = [
  FieldConfig(key: 'name',    label: 'Project Name',  hint: 'e.g. DHA Grey Structure — 10 Marla', type: FieldType.textInput),
  FieldConfig(key: 'floors',  label: 'Number of Floors', type: FieldType.numberCounter, defaultValue: 1, min: 1, max: 4),
  FieldConfig(key: 'quality', label: 'Structure Quality', type: FieldType.qualitySelector, defaultValue: 'Standard'),
  FieldConfig(key: 'bedrooms', label: 'Bedrooms (for reference)', type: FieldType.numberCounter, defaultValue: 3, min: 1, max: 10),
];

const _extensionFields = [
  FieldConfig(key: 'name',     label: 'Project Name',  hint: 'e.g. First Floor Addition', type: FieldType.textInput),
  FieldConfig(key: 'part',     label: 'Extending Which Part?', type: FieldType.chipSelector,
      options: ['Room', 'Floor', 'Basement', 'Garage', 'Terrace', 'Other']),
  FieldConfig(key: 'floors',   label: 'Floors Being Added', type: FieldType.numberCounter, defaultValue: 1, min: 1, max: 4),
  FieldConfig(key: 'quality',  label: 'Quality', type: FieldType.qualitySelector, defaultValue: 'Standard'),
];

const _renovationFields = [
  FieldConfig(key: 'name',   label: 'Project Name',  hint: 'e.g. Villa Renovation',    type: FieldType.textInput),
  FieldConfig(key: 'scope',  label: 'Renovation Scope', type: FieldType.chipSelector,
      options: ['Full Renovation', 'Partial', 'Exterior Only', 'Interior Only']),
  FieldConfig(key: 'floors', label: 'Floors Involved', type: FieldType.numberCounter, defaultValue: 1, min: 1, max: 5),
  FieldConfig(key: 'quality', label: 'Finish Quality', type: FieldType.qualitySelector, defaultValue: 'Standard'),
];

const _interiorFields = [
  FieldConfig(key: 'name',   label: 'Project Name',  hint: 'e.g. Drawing Room Interior', type: FieldType.textInput),
  FieldConfig(key: 'scope',  label: 'Interior Scope', type: FieldType.chipSelector,
      options: ['Full Interior', 'Living Areas', 'Bedrooms', 'Commercial', 'Office']),
  FieldConfig(key: 'floors', label: 'Floors Involved', type: FieldType.numberCounter, defaultValue: 1, min: 1, max: 5),
  FieldConfig(key: 'quality', label: 'Quality', type: FieldType.qualitySelector, defaultValue: 'Premium'),
];

const _customFields = [
  FieldConfig(key: 'name',        label: 'Project Name',   hint: 'Enter project name', type: FieldType.textInput, required: true),
  FieldConfig(key: 'description', label: 'Description',    hint: 'Describe what you want to build...', type: FieldType.textArea),
  FieldConfig(key: 'quality',     label: 'Quality',        type: FieldType.qualitySelector, defaultValue: 'Standard'),
];

// ── Main config map ───────────────────────────────────────────────────────────

const List<ProjectTypeConfig> kProjectTypeConfigs = [
  ProjectTypeConfig(key: 'house',         label: 'New House',         icon: '🏠', step2Fields: _houseFields,         showPlotArea: true,  stages: _houseStages,         teamOptions: _standardTeam),
  ProjectTypeConfig(key: 'villa',         label: 'Villa',             icon: '🏛️', step2Fields: _houseFields,         showPlotArea: true,  stages: _houseStages,         teamOptions: _standardTeam),
  ProjectTypeConfig(key: 'apartment',     label: 'Apartment',         icon: '🏢', step2Fields: _houseFields,         showPlotArea: true,  stages: _houseStages,         teamOptions: _standardTeam),
  ProjectTypeConfig(key: 'commercial',    label: 'Commercial Bldg',   icon: '🏗️', step2Fields: _commercialFields,    showPlotArea: true,  stages: _commercialStages,    teamOptions: _standardTeam),
  ProjectTypeConfig(key: 'shop',          label: 'Shop',              icon: '🏪', step2Fields: _shopOfficeFields,    showPlotArea: false, stages: _renovationStages,    teamOptions: _standardTeam),
  ProjectTypeConfig(key: 'office',        label: 'Office',            icon: '💼', step2Fields: _shopOfficeFields,    showPlotArea: false, stages: _renovationStages,    teamOptions: _standardTeam),
  ProjectTypeConfig(key: 'renovation',    label: 'Renovation',        icon: '🔧', step2Fields: _renovationFields,    showPlotArea: true,  stages: _renovationStages,    teamOptions: _standardTeam),
  ProjectTypeConfig(key: 'grey_structure',label: 'Grey Structure',    icon: '🏗️', step2Fields: _greyStructureFields, showPlotArea: true,  stages: _greyStructureStages, teamOptions: _standardTeam),
  ProjectTypeConfig(key: 'interior',      label: 'Interior Design',   icon: '🛋️', step2Fields: _interiorFields,      showPlotArea: false, stages: _renovationStages,    teamOptions: _interiorTeam),
  ProjectTypeConfig(key: 'boundary_wall', label: 'Boundary Wall',     icon: '🧱', step2Fields: _boundaryFields,      showPlotArea: false, stages: _boundaryStages,      teamOptions: _standardTeam),
  ProjectTypeConfig(key: 'kitchen',       label: 'Kitchen Remodel',   icon: '🍳', step2Fields: _kitchenFields,       showPlotArea: false, stages: _kitchenStages,       teamOptions: _interiorTeam),
  ProjectTypeConfig(key: 'bathroom',      label: 'Bathroom Remodel',  icon: '🚿', step2Fields: _bathroomFields,      showPlotArea: false, stages: _bathroomStages,      teamOptions: _interiorTeam),
  ProjectTypeConfig(key: 'extension',     label: 'Extension/Addition',icon: '➕', step2Fields: _extensionFields,     showPlotArea: true,  stages: _houseStages,         teamOptions: _standardTeam),
  ProjectTypeConfig(key: 'landscaping',   label: 'Landscaping',       icon: '🌿', step2Fields: _landscapeFields,     showPlotArea: false, stages: _landscapeStages,     teamOptions: _landscapeTeam),
  ProjectTypeConfig(key: 'farmhouse',     label: 'Farmhouse',         icon: '🏡', step2Fields: _houseFields,         showPlotArea: true,  stages: _houseStages,         teamOptions: _standardTeam),
  ProjectTypeConfig(key: 'warehouse',     label: 'Warehouse',         icon: '🏭', step2Fields: _commercialFields,    showPlotArea: true,  stages: _commercialStages,    teamOptions: _standardTeam),
  ProjectTypeConfig(key: 'plaza',         label: 'Plaza / Multi-Storey', icon: '🏬', step2Fields: _commercialFields, showPlotArea: true,  stages: _commercialStages,    teamOptions: _standardTeam),
  ProjectTypeConfig(key: 'custom',        label: 'Custom Project',    icon: '⚙️', step2Fields: _customFields,        showPlotArea: true,  stages: _houseStages,         teamOptions: _standardTeam),
];

ProjectTypeConfig? configForType(String key) {
  try { return kProjectTypeConfigs.firstWhere((c) => c.key == key); }
  catch (_) { return null; }
}

// ── Country + City data ───────────────────────────────────────────────────────

class CountryInfo {
  final String code;
  final String name;
  final String currency;
  final String phonePrefix;
  final List<String> cities;

  const CountryInfo({
    required this.code,
    required this.name,
    required this.currency,
    required this.phonePrefix,
    required this.cities,
  });
}

const List<CountryInfo> kAllCountries = [
  CountryInfo(code: 'PK', name: 'Pakistan',             currency: 'PKR', phonePrefix: '+92',  cities: ['Lahore', 'Karachi', 'Islamabad', 'Rawalpindi', 'Faisalabad', 'Multan', 'Peshawar', 'Quetta', 'Sialkot', 'Gujranwala']),
  CountryInfo(code: 'SA', name: 'Saudi Arabia',         currency: 'SAR', phonePrefix: '+966', cities: ['Riyadh', 'Jeddah', 'Mecca', 'Medina', 'Dammam', 'Khobar', 'Tabuk', 'Abha']),
  CountryInfo(code: 'AE', name: 'United Arab Emirates', currency: 'AED', phonePrefix: '+971', cities: ['Dubai', 'Abu Dhabi', 'Sharjah', 'Ajman', 'Ras Al Khaimah', 'Fujairah']),
  CountryInfo(code: 'QA', name: 'Qatar',                currency: 'QAR', phonePrefix: '+974', cities: ['Doha', 'Al Wakra', 'Al Khor', 'Mesaieed']),
  CountryInfo(code: 'BH', name: 'Bahrain',              currency: 'BHD', phonePrefix: '+973', cities: ['Manama', 'Riffa', 'Muharraq', 'Hamad Town']),
  CountryInfo(code: 'KW', name: 'Kuwait',               currency: 'KWD', phonePrefix: '+965', cities: ['Kuwait City', 'Hawalli', 'Salmiya', 'Farwaniya']),
  CountryInfo(code: 'OM', name: 'Oman',                 currency: 'OMR', phonePrefix: '+968', cities: ['Muscat', 'Salalah', 'Sohar', 'Nizwa']),
  CountryInfo(code: 'TR', name: 'Turkey',               currency: 'TRY', phonePrefix: '+90',  cities: ['Istanbul', 'Ankara', 'Izmir', 'Bursa', 'Adana']),
  CountryInfo(code: 'EG', name: 'Egypt',                currency: 'EGP', phonePrefix: '+20',  cities: ['Cairo', 'Alexandria', 'Giza', 'Sharm El Sheikh', 'Luxor']),
  CountryInfo(code: 'IN', name: 'India',                currency: 'INR', phonePrefix: '+91',  cities: ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai', 'Kolkata', 'Pune', 'Ahmedabad']),
  CountryInfo(code: 'BD', name: 'Bangladesh',           currency: 'BDT', phonePrefix: '+880', cities: ['Dhaka', 'Chittagong', 'Sylhet', 'Rajshahi']),
  CountryInfo(code: 'MY', name: 'Malaysia',             currency: 'MYR', phonePrefix: '+60',  cities: ['Kuala Lumpur', 'Penang', 'Johor Bahru', 'Kota Kinabalu']),
  CountryInfo(code: 'GB', name: 'United Kingdom',       currency: 'GBP', phonePrefix: '+44',  cities: ['London', 'Birmingham', 'Manchester', 'Leeds', 'Glasgow', 'Bradford', 'Sheffield']),
  CountryInfo(code: 'US', name: 'United States',        currency: 'USD', phonePrefix: '+1',   cities: ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'Dallas']),
  CountryInfo(code: 'CA', name: 'Canada',               currency: 'CAD', phonePrefix: '+1',   cities: ['Toronto', 'Montreal', 'Vancouver', 'Calgary', 'Edmonton', 'Ottawa']),
  CountryInfo(code: 'AU', name: 'Australia',            currency: 'AUD', phonePrefix: '+61',  cities: ['Sydney', 'Melbourne', 'Brisbane', 'Perth', 'Adelaide']),
  CountryInfo(code: 'DE', name: 'Germany',              currency: 'EUR', phonePrefix: '+49',  cities: ['Berlin', 'Hamburg', 'Munich', 'Cologne', 'Frankfurt']),
  CountryInfo(code: 'FR', name: 'France',               currency: 'EUR', phonePrefix: '+33',  cities: ['Paris', 'Marseille', 'Lyon', 'Toulouse', 'Nice']),
  CountryInfo(code: 'NG', name: 'Nigeria',              currency: 'NGN', phonePrefix: '+234', cities: ['Lagos', 'Abuja', 'Kano', 'Ibadan', 'Port Harcourt']),
  CountryInfo(code: 'KE', name: 'Kenya',                currency: 'KES', phonePrefix: '+254', cities: ['Nairobi', 'Mombasa', 'Kisumu', 'Nakuru']),
  CountryInfo(code: 'GH', name: 'Ghana',                currency: 'GHS', phonePrefix: '+233', cities: ['Accra', 'Kumasi', 'Tamale', 'Takoradi']),
  CountryInfo(code: 'ZA', name: 'South Africa',         currency: 'ZAR', phonePrefix: '+27',  cities: ['Johannesburg', 'Cape Town', 'Durban', 'Pretoria']),
  CountryInfo(code: 'AF', name: 'Afghanistan',          currency: 'AFN', phonePrefix: '+93',  cities: ['Kabul', 'Kandahar', 'Herat', 'Mazar-i-Sharif']),
  CountryInfo(code: 'IR', name: 'Iran',                 currency: 'IRR', phonePrefix: '+98',  cities: ['Tehran', 'Mashhad', 'Isfahan', 'Tabriz', 'Shiraz']),
  CountryInfo(code: 'IQ', name: 'Iraq',                 currency: 'IQD', phonePrefix: '+964', cities: ['Baghdad', 'Basra', 'Erbil', 'Mosul', 'Najaf']),
  CountryInfo(code: 'JO', name: 'Jordan',               currency: 'JOD', phonePrefix: '+962', cities: ['Amman', 'Zarqa', 'Irbid', 'Aqaba']),
  CountryInfo(code: 'LB', name: 'Lebanon',              currency: 'LBP', phonePrefix: '+961', cities: ['Beirut', 'Tripoli', 'Sidon', 'Tyre']),
  CountryInfo(code: 'PH', name: 'Philippines',          currency: 'PHP', phonePrefix: '+63',  cities: ['Manila', 'Quezon City', 'Cebu', 'Davao']),
  CountryInfo(code: 'ID', name: 'Indonesia',            currency: 'IDR', phonePrefix: '+62',  cities: ['Jakarta', 'Surabaya', 'Bandung', 'Medan']),
  CountryInfo(code: 'LK', name: 'Sri Lanka',            currency: 'LKR', phonePrefix: '+94',  cities: ['Colombo', 'Kandy', 'Galle', 'Jaffna']),
  CountryInfo(code: 'NP', name: 'Nepal',                currency: 'NPR', phonePrefix: '+977', cities: ['Kathmandu', 'Pokhara', 'Lalitpur', 'Biratnagar']),
  CountryInfo(code: 'CN', name: 'China',                currency: 'CNY', phonePrefix: '+86',  cities: ['Beijing', 'Shanghai', 'Guangzhou', 'Shenzhen', 'Chengdu']),
];

// ── Date computation helpers ──────────────────────────────────────────────────

class WizardStage {
  final String id;
  final String name;
  final int durationDays;
  final double costPct;
  final String color;
  DateTime? startDate;
  DateTime? endDate;
  int order;

  WizardStage({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.costPct,
    required this.color,
    this.startDate,
    this.endDate,
    required this.order,
  });

  WizardStage copyWith({int? order, DateTime? startDate, DateTime? endDate}) {
    return WizardStage(
      id: id, name: name,
      durationDays: durationDays, costPct: costPct, color: color,
      order: order ?? this.order,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  String get formattedDuration {
    if (durationDays < 7) return '${durationDays}d';
    final weeks = (durationDays / 7).round();
    return '${weeks}w';
  }
}

/// Computes start/end dates for all stages sequentially from a start date
List<WizardStage> computeStageDates(List<WizardStage> stages, DateTime startDate) {
  DateTime cursor = startDate;
  return stages.asMap().entries.map((e) {
    final stage = e.value;
    final start = cursor;
    final end   = cursor.add(Duration(days: stage.durationDays));
    cursor = end;
    return stage.copyWith(order: e.key, startDate: start, endDate: end);
  }).toList();
}

/// Scale stage durations by area (sqm) and quality
int scaleDuration(int baseDays, double areaSqm, String quality) {
  final sizeFactor = areaSqm < 80 ? 0.8 : areaSqm < 200 ? 1.0 : areaSqm < 400 ? 1.3 : 1.7;
  final qFactor    = {'Economy': 0.85, 'Standard': 1.0, 'Premium': 1.3, 'Luxury': 1.8}[quality] ?? 1.0;
  return (baseDays * sizeFactor * qFactor).round().clamp(baseDays, baseDays * 4);
}
