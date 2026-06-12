import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/area_estimator_controller.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

extension _CS on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class AreaBasedEstimatorScreen extends StatelessWidget {
  const AreaBasedEstimatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AreaEstimatorController());
    final cs   = context.cs;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(ctrl: ctrl, cs: cs),
            _StepIndicator(ctrl: ctrl, cs: cs),
            Expanded(
              child: Obx(() => _buildStep(context, ctrl)),
            ),
            _BottomNav(ctrl: ctrl, cs: cs),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, AreaEstimatorController ctrl) {
    return switch (ctrl.currentStep.value) {
      0 => _StepCity(ctrl: ctrl),
      1 => _StepGeneral(ctrl: ctrl),
      2 => _StepFloorDetails(ctrl: ctrl),
      3 => _StepExtras(ctrl: ctrl),
      4 => _StepResults(ctrl: ctrl),
      _ => const SizedBox.shrink(),
    };
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final AreaEstimatorController ctrl;
  final ColorScheme cs;
  const _AppBar({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, Color.lerp(cs.primary, const Color(0xFF1D4ED8), 0.5)!],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Area-Based Estimator',
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('Step-by-step construction cost estimation',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.75))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final AreaEstimatorController ctrl;
  final ColorScheme cs;
  const _StepIndicator({required this.ctrl, required this.cs});

  static const _labels = ['City', 'General', 'Floors', 'Extras', 'Results'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Obx(() => Row(
            children: List.generate(5, (i) {
              final isDone    = i < ctrl.currentStep.value;
              final isActive  = i == ctrl.currentStep.value;
              final stepColor = isDone || isActive ? cs.primary : cs.outline.withValues(alpha: 0.4);

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? cs.primary
                                  : isActive
                                      ? cs.primary.withValues(alpha: 0.15)
                                      : cs.outline.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: stepColor,
                                width: isActive ? 2 : 1.5,
                              ),
                            ),
                            child: Center(
                              child: isDone
                                  ? Icon(Icons.check_rounded,
                                      size: 13, color: Colors.white)
                                  : Text('${i + 1}',
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isActive
                                              ? cs.primary
                                              : cs.onSurfaceVariant)),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(_labels[i],
                              style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isActive
                                      ? cs.primary
                                      : cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    if (i < 4)
                      Expanded(
                        child: Container(
                          height: 1.5,
                          margin: const EdgeInsets.only(bottom: 16),
                          color: i < ctrl.currentStep.value
                              ? cs.primary
                              : cs.outline.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
              );
            }),
          )),
    );
  }
}

// ── Step 1: City ──────────────────────────────────────────────────────────────

class _StepCity extends StatelessWidget {
  final AreaEstimatorController ctrl;
  const _StepCity({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Which city are you building in?',
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  height: 1.2)),
          const SizedBox(height: 6),
          Text('Material prices vary by city — this helps us give accurate estimates.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: cs.onSurfaceVariant, height: 1.4)),
          const SizedBox(height: 24),
          Obx(() {
            final selectedCity = ctrl.selectedCity.value;
            return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: AreaEstimatorController.cities.length,
                itemBuilder: (_, i) {
                  final city     = AreaEstimatorController.cities[i];
                  final selected = selectedCity == city;
                  return GestureDetector(
                    onTap: () => ctrl.selectedCity.value = city,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? cs.primary
                            : cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? cs.primary
                              : cs.outline.withValues(alpha: 0.25),
                          width: selected ? 2 : 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3))
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Text(
                            AreaEstimatorController.cityEmojis[city] ?? '🏙️',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(city,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : cs.onSurface)),
                          ),
                          if (selected)
                            const Icon(Icons.check_circle_rounded,
                                size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  );
                },
              );
          }),
        ],
      ),
    );
  }
}

// ── Step 2: General info ──────────────────────────────────────────────────────

class _StepGeneral extends StatelessWidget {
  final AreaEstimatorController ctrl;
  const _StepGeneral({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('General Information',
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface)),
          const SizedBox(height: 6),
          Text('Tell us about the basic layout of your project.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: cs.onSurfaceVariant)),
          const SizedBox(height: 24),

          _NumberField(
            label: 'Number of Floors',
            hint: 'e.g. 2',
            icon: Icons.layers_rounded,
            initialValue: ctrl.numFloors.value.toString(),
            onChanged: (v) {
              final n = int.tryParse(v) ?? 1;
              ctrl.numFloors.value = n.clamp(1, 10);
            },
          ),
          const SizedBox(height: 16),
          _NumberField(
            label: 'Plot Size (Marla)',
            hint: 'e.g. 10',
            icon: Icons.square_foot_rounded,
            initialValue: ctrl.plotSizeMarla.value > 0
                ? ctrl.plotSizeMarla.value.toString()
                : '',
            onChanged: (v) =>
                ctrl.plotSizeMarla.value = double.tryParse(v) ?? 0,
          ),
          const SizedBox(height: 16),
          _NumberField(
            label: 'Total Covered Area (Sqft)',
            hint: 'e.g. 2500',
            icon: Icons.home_outlined,
            initialValue: ctrl.coveredAreaSqft.value > 0
                ? ctrl.coveredAreaSqft.value.toString()
                : '',
            onChanged: (v) =>
                ctrl.coveredAreaSqft.value = double.tryParse(v) ?? 0,
          ),
          const SizedBox(height: 20),

          // Construction quality
          Text('Construction Quality',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
          const SizedBox(height: 10),
          Obx(() {
            final selectedQuality = ctrl.quality.value;
            return Row(
                children: AreaEstimatorController.qualities.map((q) {
                  final selected = selectedQuality == q['key'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => ctrl.quality.value = q['key']!,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? cs.primary : cs.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? cs.primary
                                : cs.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(q['icon']!,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 3),
                            Text(q['label']!,
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : cs.onSurface)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
          }),
        ],
      ),
    );
  }
}

// ── Step 3: Per-floor details ─────────────────────────────────────────────────

class _StepFloorDetails extends StatelessWidget {
  final AreaEstimatorController ctrl;
  const _StepFloorDetails({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Obx(() {
      final floors = ctrl.numFloors.value;
      return DefaultTabController(
        length: floors,
        child: Column(
          children: [
            if (floors > 1)
              TabBar(
                isScrollable: true,
                labelStyle: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600),
                unselectedLabelStyle:
                    GoogleFonts.inter(fontSize: 12),
                labelColor: cs.primary,
                unselectedLabelColor: cs.onSurfaceVariant,
                indicatorColor: cs.primary,
                tabs: List.generate(
                  floors,
                  (i) => Tab(
                    text: i == 0
                        ? 'Ground Floor'
                        : i == floors - 1 && i > 1
                            ? 'Top Floor'
                            : 'Floor ${i + 1}',
                  ),
                ),
              ),
            Expanded(
              child: floors == 1
                  ? _FloorForm(ctrl: ctrl, floorIndex: 0)
                  : TabBarView(
                      children: List.generate(
                        floors,
                        (i) => _FloorForm(ctrl: ctrl, floorIndex: i),
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}

class _FloorForm extends StatelessWidget {
  final AreaEstimatorController ctrl;
  final int floorIndex;
  const _FloorForm({required this.ctrl, required this.floorIndex});

  @override
  Widget build(BuildContext context) {
    final cs    = context.cs;
    final floor = ctrl.getFloor(floorIndex);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            floorIndex == 0 ? 'Ground Floor Details' : 'Floor ${floorIndex + 1} Details',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface),
          ),
          const SizedBox(height: 16),

          // Rooms grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _RoomCounter(
                  label: 'Bedrooms', icon: '🛏️',
                  value: floor.bedrooms, onChanged: (v) => floor.bedrooms = v),
              _RoomCounter(
                  label: 'Washrooms', icon: '🚿',
                  value: floor.washrooms, onChanged: (v) => floor.washrooms = v),
              _RoomCounter(
                  label: 'Kitchens', icon: '🍳',
                  value: floor.kitchens, onChanged: (v) => floor.kitchens = v),
              _RoomCounter(
                  label: 'TV Lounges', icon: '📺',
                  value: floor.tvLounges, onChanged: (v) => floor.tvLounges = v),
              _RoomCounter(
                  label: 'Drawing Rooms', icon: '🛋️',
                  value: floor.drawingRooms, onChanged: (v) => floor.drawingRooms = v),
              _RoomCounter(
                  label: 'Dining Areas', icon: '🍽️',
                  value: floor.diningAreas, onChanged: (v) => floor.diningAreas = v),
              _RoomCounter(
                  label: 'Store Rooms', icon: '📦',
                  value: floor.storeRooms, onChanged: (v) => floor.storeRooms = v),
              _RoomCounter(
                  label: 'Staircases', icon: '🪜',
                  value: floor.staircases, onChanged: (v) => floor.staircases = v),
              _RoomCounter(
                  label: 'Balconies', icon: '🌿',
                  value: floor.balconies, onChanged: (v) => floor.balconies = v),
              _RoomCounter(
                  label: 'Servant Rooms', icon: '🏠',
                  value: floor.servantRooms, onChanged: (v) => floor.servantRooms = v),
            ],
          ),
          const SizedBox(height: 16),

          // Floor height
          Text('Floor Height',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
          const SizedBox(height: 8),
          GetBuilder<AreaEstimatorController>(
              builder: (_) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AreaEstimatorController.floorHeights.map((h) {
                  final selected = floor.heightFt == h;
                  return GestureDetector(
                    onTap: () {
                      floor.heightFt = h;
                      ctrl.refresh();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? cs.primary : cs.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? cs.primary
                              : cs.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text('$h ft',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : cs.onSurface)),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 16),

          // Elevator
          GetBuilder<AreaEstimatorController>(
              builder: (_) => _ToggleRow(
                label: 'Elevator / Lift',
                icon: '🛗',
                value: floor.hasElevator,
                onToggle: (v) {
                  floor.hasElevator = v;
                  ctrl.refresh();
                },
              )),

          // Parking
          const SizedBox(height: 10),
          _NumberFieldSmall(
            label: 'Parking Area (sqft)',
            icon: Icons.directions_car_rounded,
            initialValue:
                floor.parkingAreaSqft > 0 ? floor.parkingAreaSqft.toString() : '',
            onChanged: (v) {
              floor.parkingAreaSqft = double.tryParse(v) ?? 0;
              ctrl.refresh();
            },
          ),

          // Terrace
          const SizedBox(height: 10),
          _NumberFieldSmall(
            label: 'Terrace Area (sqft)',
            icon: Icons.roofing_rounded,
            initialValue:
                floor.terraceAreaSqft > 0 ? floor.terraceAreaSqft.toString() : '',
            onChanged: (v) {
              floor.terraceAreaSqft = double.tryParse(v) ?? 0;
              ctrl.refresh();
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _RoomCounter extends StatefulWidget {
  final String label;
  final String icon;
  final int value;
  final ValueChanged<int> onChanged;
  const _RoomCounter(
      {required this.label,
      required this.icon,
      required this.value,
      required this.onChanged});

  @override
  State<_RoomCounter> createState() => _RoomCounterState();
}

class _RoomCounterState extends State<_RoomCounter> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(widget.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(widget.label,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  if (_count > 0) {
                    setState(() => _count--);
                    widget.onChanged(_count);
                  }
                },
                child: Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.remove_rounded, size: 14, color: cs.primary),
                ),
              ),
              SizedBox(
                width: 28,
                child: Text('$_count',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface)),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _count++);
                  widget.onChanged(_count);
                },
                child: Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Step 4: Extras ────────────────────────────────────────────────────────────

class _StepExtras extends StatelessWidget {
  final AreaEstimatorController ctrl;
  const _StepExtras({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Additional Details',
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface)),
          const SizedBox(height: 6),
          Text('A few more details to improve accuracy.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: cs.onSurfaceVariant)),
          const SizedBox(height: 24),

          Obx(() => Column(
                children: [
                  _ToggleRow(
                    label: 'Double Height Area',
                    icon: '🏛️',
                    value: ctrl.hasDoubleHeight.value,
                    onToggle: (v) => ctrl.hasDoubleHeight.value = v,
                  ),
                  if (ctrl.hasDoubleHeight.value) ...[
                    const SizedBox(height: 10),
                    _NumberFieldSmall(
                      label: 'Double Height Area Size (sqft)',
                      icon: Icons.height_rounded,
                      onChanged: (v) =>
                          ctrl.doubleHeightArea.value = double.tryParse(v) ?? 0,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _ToggleRow(
                    label: 'Basement / Lower Ground',
                    icon: '⬇️',
                    value: ctrl.hasBasement.value,
                    onToggle: (v) => ctrl.hasBasement.value = v,
                  ),
                  const SizedBox(height: 16),
                  _ToggleRow(
                    label: 'Boundary Wall Required',
                    icon: '🧱',
                    value: ctrl.hasBoundaryWall.value,
                    onToggle: (v) => ctrl.hasBoundaryWall.value = v,
                  ),
                  const SizedBox(height: 16),
                  _ToggleRow(
                    label: 'Septic Tank Required',
                    icon: '🚽',
                    value: ctrl.hasSepticTank.value,
                    onToggle: (v) => ctrl.hasSepticTank.value = v,
                  ),
                  const SizedBox(height: 16),
                  _ToggleRow(
                    label: 'Garden / Lawn Area',
                    icon: '🌳',
                    value: ctrl.hasGarden.value,
                    onToggle: (v) => ctrl.hasGarden.value = v,
                  ),
                  if (ctrl.hasGarden.value) ...[
                    const SizedBox(height: 10),
                    _NumberFieldSmall(
                      label: 'Garden Area (sqft)',
                      icon: Icons.park_rounded,
                      onChanged: (v) =>
                          ctrl.gardenAreaSqft.value = double.tryParse(v) ?? 0,
                    ),
                  ],
                ],
              )),
          const SizedBox(height: 20),

          // Roof type
          Text('Roof Type',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
          const SizedBox(height: 10),
          Obx(() {
            final selectedRoof = ctrl.roofType.value;
            return Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    AreaEstimatorController.roofTypes.map((r) {
                  final selected = selectedRoof == r['key'];
                  return GestureDetector(
                    onTap: () => ctrl.roofType.value = r['key']!,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? cs.primary : cs.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? cs.primary
                              : cs.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text('${r['icon']} ${r['label']}',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  selected ? Colors.white : cs.onSurface)),
                    ),
                  );
                }).toList(),
              );
          }),
          const SizedBox(height: 20),

          // Water tank
          _NumberFieldSmall(
            label: 'Water Tank Capacity (gallons)',
            icon: Icons.water_drop_rounded,
            onChanged: (v) =>
                ctrl.waterTankGallons.value = int.tryParse(v) ?? 0,
          ),
        ],
      ),
    );
  }
}

// ── Step 5: Results ───────────────────────────────────────────────────────────

class _StepResults extends StatelessWidget {
  final AreaEstimatorController ctrl;
  const _StepResults({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Obx(() {
      if (ctrl.isCalculating.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: cs.primary, strokeWidth: 2),
              const SizedBox(height: 16),
              Text('Calculating your estimate...',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: cs.onSurfaceVariant)),
            ],
          ),
        );
      }
      final r = ctrl.result.value;
      if (r == null) return const SizedBox.shrink();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total cost hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primary,
                    Color.lerp(cs.primary, const Color(0xFF1D4ED8), 0.5)!
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text('Total Estimated Cost',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(height: 6),
                  Text(r.formattedTotal,
                      style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('${ctrl.selectedCity.value}  ·  ${ctrl.coveredAreaSqft.value.toInt()} sqft  ·  ${ctrl.numFloors.value} floor${ctrl.numFloors.value > 1 ? 's' : ''}',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cost breakdown
            _SectionTitle('Cost Breakdown'),
            const SizedBox(height: 10),
            _CostRow(label: 'Grey Structure', amount: r.greyStructureCost, cs: cs,
                icon: Icons.foundation_rounded, color: const Color(0xFF8B5CF6)),
            _CostRow(label: 'Finishing Work', amount: r.finishingCost, cs: cs,
                icon: Icons.format_paint_rounded, color: const Color(0xFF3B82F6)),
            _CostRow(label: 'Labour & Supervision', amount: r.laborCost, cs: cs,
                icon: Icons.engineering_rounded, color: const Color(0xFFF59E0B)),
            _CostRow(label: 'Plumbing & Electrical', amount: r.plumbingElecCost, cs: cs,
                icon: Icons.electrical_services_rounded, color: const Color(0xFF22C55E)),
            _CostRow(label: 'Miscellaneous (10%)', amount: r.miscCost, cs: cs,
                icon: Icons.more_horiz_rounded, color: const Color(0xFF64748B)),

            const SizedBox(height: 16),

            // Material breakdown
            _SectionTitle('Material Breakdown'),
            const SizedBox(height: 10),
            ...r.materials.map((m) => _MaterialResultRow(m: m, cs: cs)),

            const SizedBox(height: 16),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: cs.outline.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'These estimations are generated based on the information provided by the user. Actual material consumption and project costs may vary depending on design specifications, site conditions, construction methods, and market fluctuations.',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
    });
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(title,
      style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface));
}

class _CostRow extends StatelessWidget {
  final String label;
  final double amount;
  final ColorScheme cs;
  final IconData icon;
  final Color color;
  const _CostRow(
      {required this.label,
      required this.amount,
      required this.cs,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: cs.onSurface.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface)),
          ),
          Text(
            _fmt(amount),
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.onSurface),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1e7) return 'Rs ${(v / 1e7).toStringAsFixed(2)} Crore';
    if (v >= 1e5) return 'Rs ${(v / 1e5).toStringAsFixed(2)} Lakh';
    if (v >= 1000) return 'Rs ${v.toStringAsFixed(0)}';
    return 'Rs ${v.toStringAsFixed(0)}';
  }
}

class _MaterialResultRow extends StatelessWidget {
  final MaterialResult m;
  final ColorScheme cs;
  const _MaterialResultRow({required this.m, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(m.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface)),
                Text('${m.quantity.toStringAsFixed(0)} ${m.unit}',
                    style: GoogleFonts.inter(
                        fontSize: 10, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Text(
            'Rs ${_fmtNum(m.totalCost)}',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.onSurface),
          ),
        ],
      ),
    );
  }

  String _fmtNum(double v) {
    if (v >= 1e5) return '${(v / 1e5).toStringAsFixed(1)}L';
    return v.toStringAsFixed(0);
  }
}

// ── Shared field widgets ──────────────────────────────────────────────────────

class _NumberField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final String initialValue;
  final ValueChanged<String> onChanged;
  const _NumberField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.initialValue = '',
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          onChanged: onChanged,
          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: cs.onSurfaceVariant),
            filled: true,
            fillColor: cs.surface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: cs.outline.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: cs.outline.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _NumberFieldSmall extends StatelessWidget {
  final String label;
  final IconData icon;
  final String initialValue;
  final ValueChanged<String> onChanged;
  const _NumberFieldSmall({
    required this.label,
    required this.icon,
    required this.onChanged,
    this.initialValue = '',
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant),
        prefixIcon: Icon(icon, size: 17, color: cs.onSurfaceVariant),
        filled: true,
        fillColor: cs.surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String icon;
  final bool value;
  final ValueChanged<bool> onToggle;
  const _ToggleRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface)),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onToggle,
            activeColor: cs.primary,
          ),
        ],
      ),
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final AreaEstimatorController ctrl;
  final ColorScheme cs;
  const _BottomNav({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
            top: BorderSide(color: cs.outline.withValues(alpha: 0.15))),
      ),
      child: Obx(() => Row(
            children: [
              if (ctrl.currentStep.value > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: ctrl.prevStep,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.primary,
                      side:
                          BorderSide(color: cs.primary.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Back',
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: ctrl.currentStep.value == 4
                      ? () => Get.back()
                      : ctrl.nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    ctrl.currentStep.value == 3
                        ? 'Calculate Estimate'
                        : ctrl.currentStep.value == 4
                            ? 'Done'
                            : 'Continue',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
