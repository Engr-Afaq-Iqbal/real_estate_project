import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/material_cost_calc_controller.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class MaterialCostCalculatorScreen extends StatelessWidget {
  const MaterialCostCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(MaterialCostCalcController());
    final cs   = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(ctrl: ctrl, cs: cs),
            _Toolbar(ctrl: ctrl, cs: cs),
            _TableHeader(cs: cs),
            Expanded(child: _MaterialRows(ctrl: ctrl, cs: cs)),
            _GrandTotal(ctrl: ctrl, cs: cs),
          ],
        ),
      ),
      floatingActionButton: _AddMaterialFab(ctrl: ctrl, cs: cs),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final MaterialCostCalcController ctrl;
  final ColorScheme cs;
  const _Header({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, Color.lerp(cs.primary, const Color(0xFF0EA5E9), 0.5)!],
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
                Text('Material Cost Calculator',
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('Spreadsheet-style • Live calculations',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.75))),
              ],
            ),
          ),
          // City selector
          Obx(() => GestureDetector(
                onTap: () => _showCityPicker(context, ctrl),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 12, color: Colors.white),
                      const SizedBox(width: 3),
                      Text(ctrl.selectedCity.value,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const Icon(Icons.arrow_drop_down_rounded,
                          size: 16, color: Colors.white),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _showCityPicker(BuildContext context, MaterialCostCalcController ctrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final cs = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: cs.outline.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Text('Select City',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: MaterialCostCalcController.cities.map((city) =>
                  Obx(() => ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        leading: Icon(Icons.location_city_rounded,
                            size: 20,
                            color: ctrl.selectedCity.value == city
                                ? cs.primary
                                : cs.onSurfaceVariant),
                        title: Text(city,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight:
                                    ctrl.selectedCity.value == city
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                color: ctrl.selectedCity.value == city
                                    ? cs.primary
                                    : cs.onSurface)),
                        trailing: ctrl.selectedCity.value == city
                            ? Icon(Icons.check_circle_rounded,
                                size: 18, color: cs.primary)
                            : null,
                        onTap: () {
                          ctrl.selectCity(city);
                          Navigator.of(context).pop();
                        },
                      ))).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

// ── Toolbar (search + category filter) ───────────────────────────────────────

class _Toolbar extends StatelessWidget {
  final MaterialCostCalcController ctrl;
  final ColorScheme cs;
  const _Toolbar({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: TextField(
            onChanged: ctrl.onSearch,
            style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Search materials...',
              hintStyle: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
              prefixIcon: Icon(Icons.search_rounded, size: 17, color: cs.onSurfaceVariant),
              filled: true,
              fillColor: cs.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: cs.primary, width: 1.5),
              ),
            ),
          ),
        ),
        // Category chips
        SizedBox(
          height: 38,
          child: Obx(() {
            final selectedCat = ctrl.selectedCategory.value;
            return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                itemCount: MaterialCostCalcController.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final cat      = MaterialCostCalcController.categories[i];
                  final selected = selectedCat == cat;
                  return GestureDetector(
                    onTap: () => ctrl.selectCategory(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: selected ? cs.primary : cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? cs.primary
                              : cs.outline.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Center(
                        child: Text(cat,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: selected
                                    ? Colors.white
                                    : cs.onSurfaceVariant)),
                      ),
                    ),
                  );
                },
              );
          }),
        ),
      ],
    );
  }
}

// ── Spreadsheet table header ──────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  final ColorScheme cs;
  const _TableHeader({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text('Material',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.primary)),
          ),
          SizedBox(
            width: 80,
            child: Text('Latest Price',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: cs.primary)),
          ),
          SizedBox(
            width: 60,
            child: Text('Qty',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: cs.primary)),
          ),
          SizedBox(
            width: 36,
            child: Text('Unit',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: cs.primary)),
          ),
          SizedBox(
            width: 72,
            child: Text('Total',
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: cs.primary)),
          ),
        ],
      ),
    );
  }
}

// ── Material rows ─────────────────────────────────────────────────────────────

class _MaterialRows extends StatelessWidget {
  final MaterialCostCalcController ctrl;
  final ColorScheme cs;
  const _MaterialRows({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = ctrl.filteredItems;
      if (items.isEmpty) {
        return Center(
          child: Text('No materials found',
              style: GoogleFonts.inter(
                  fontSize: 13, color: cs.onSurfaceVariant)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
        itemCount: items.length,
        itemBuilder: (_, i) => _MaterialRow(
          item: items[i],
          cs: cs,
          isEven: i.isEven,
          onQtyChanged: (qty) => ctrl.setQuantity(items[i].id, qty),
          onDelete: items[i].isCustom
              ? () => ctrl.removeCustomItem(items[i].id)
              : null,
        ),
      );
    });
  }
}

class _MaterialRow extends StatefulWidget {
  final CalcMaterialItem item;
  final ColorScheme cs;
  final bool isEven;
  final ValueChanged<double> onQtyChanged;
  final VoidCallback? onDelete;

  const _MaterialRow({
    required this.item,
    required this.cs,
    required this.isEven,
    required this.onQtyChanged,
    this.onDelete,
  });

  @override
  State<_MaterialRow> createState() => _MaterialRowState();
}

class _MaterialRowState extends State<_MaterialRow> {
  late TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(
      text: widget.item.quantity > 0
          ? widget.item.quantity.toStringAsFixed(
              widget.item.quantity == widget.item.quantity.roundToDouble()
                  ? 0
                  : 1)
          : '',
    );
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs     = widget.cs;
    final item   = widget.item;
    final total  = item.totalCost;
    final hasCost = total > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: widget.isEven
            ? cs.surface
            : cs.surface.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: cs.outline.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Material name + unit
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Text(item.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface)),
                      Text(item.category,
                          style: GoogleFonts.inter(
                              fontSize: 9, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Latest price
          SizedBox(
            width: 80,
            child: Text(
              'Rs ${_fmtPrice(item.unitPrice)}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface),
            ),
          ),

          // Qty input
          SizedBox(
            width: 60,
            child: TextFormField(
              controller: _qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.primary),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: GoogleFonts.inter(
                    fontSize: 12, color: cs.onSurfaceVariant),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 6),
                filled: true,
                fillColor: cs.primary.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                      color: cs.primary.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                      color: cs.primary.withValues(alpha: 0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide:
                      BorderSide(color: cs.primary, width: 1.5),
                ),
              ),
              onChanged: (v) {
                final qty = double.tryParse(v) ?? 0;
                widget.onQtyChanged(qty);
              },
            ),
          ),

          // Unit
          SizedBox(
            width: 36,
            child: Text(item.unit,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 9, color: cs.onSurfaceVariant)),
          ),

          // Total cost
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hasCost ? _fmtTotal(total) : '—',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight:
                          hasCost ? FontWeight.w700 : FontWeight.w400,
                      color: hasCost ? cs.onSurface : cs.onSurfaceVariant),
                ),
                if (widget.onDelete != null)
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: const Icon(Icons.close_rounded,
                        size: 13, color: Color(0xFFDC2626)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtPrice(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(0)}L';
    if (v >= 1000)   return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  String _fmtTotal(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000)     return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Grand total bar ───────────────────────────────────────────────────────────

class _GrandTotal extends StatelessWidget {
  final MaterialCostCalcController ctrl;
  final ColorScheme cs;
  const _GrandTotal({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, Color.lerp(cs.primary, const Color(0xFF1D4ED8), 0.5)!],
        ),
      ),
      child: Obx(() {
        final total    = ctrl.grandTotal;
        final itemsCt  = ctrl.activeItemCount;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Grand Total',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8))),
                      Text(_fmtTotal(total),
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$itemsCt item${itemsCt == 1 ? '' : 's'}',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.75))),
                    if (total > 0)
                      GestureDetector(
                        onTap: ctrl.clearAll,
                        child: Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Clear All',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  String _fmtTotal(double v) {
    if (v >= 1e7) return 'Rs ${(v / 1e7).toStringAsFixed(2)} Crore';
    if (v >= 1e5) return 'Rs ${(v / 1e5).toStringAsFixed(2)} Lakh';
    if (v >= 1000) return 'Rs ${v.toStringAsFixed(0)}';
    return 'Rs 0';
  }
}

// ── Add material FAB ──────────────────────────────────────────────────────────

class _AddMaterialFab extends StatelessWidget {
  final MaterialCostCalcController ctrl;
  final ColorScheme cs;
  const _AddMaterialFab({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddDialog(context),
      backgroundColor: cs.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded, size: 20),
      label: Text('Add Material',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  void _showAddDialog(BuildContext context) {
    final cs        = Theme.of(context).colorScheme;
    final nameCtrl  = TextEditingController();
    final priceCtrl = TextEditingController();
    final unitCtrl  = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: cs.outline.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Text('Add Custom Material',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _DialogField(ctrl: nameCtrl, label: 'Material Name', hint: 'e.g. Granite Tiles'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DialogField(
                        ctrl: priceCtrl,
                        label: 'Unit Price (Rs)',
                        hint: '1000',
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogField(
                        ctrl: unitCtrl,
                        label: 'Unit',
                        hint: 'sqft / bag / kg'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name  = nameCtrl.text.trim();
                    final price = double.tryParse(priceCtrl.text) ?? 0;
                    final unit  = unitCtrl.text.trim();
                    if (name.isNotEmpty && price > 0) {
                      ctrl.addCustomMaterial(
                          name: name, unitPrice: price, unit: unit);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Add Material',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  const _DialogField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                fontSize: 12, color: cs.onSurfaceVariant),
            filled: true,
            fillColor: cs.surface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: cs.outline.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: cs.outline.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: cs.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
