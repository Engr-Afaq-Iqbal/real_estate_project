import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/market_prices_controller.dart';

const _kUp     = Color(0xFF16A34A);
const _kDown   = Color(0xFFDC2626);
const _kStable = Color(0xFF64748B);

class MarketPricesScreen extends StatelessWidget {
  const MarketPricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(MarketPricesController());
    final cs   = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(ctrl: ctrl, cs: cs, isDark: isDark),
            _SearchBar(ctrl: ctrl, cs: cs),
            _CategoryChips(ctrl: ctrl, cs: cs),
            _MarketInfoBar(ctrl: ctrl, cs: cs),
            Expanded(child: _MaterialList(ctrl: ctrl, cs: cs)),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final MarketPricesController ctrl;
  final ColorScheme cs;
  final bool isDark;
  const _Header({required this.ctrl, required this.cs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, Color.lerp(cs.primary, const Color(0xFF1D4ED8), 0.5)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                Text("Today's Market Prices",
                    style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('Pakistan Construction Materials',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.75))),
              ],
            ),
          ),
          // City selector
          Obx(() => GestureDetector(
                onTap: () => _showCityPicker(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                      const SizedBox(width: 4),
                      Text(ctrl.selectedCity.value,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(width: 3),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 14, color: Colors.white),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _showCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CityPickerSheet(ctrl: ctrl),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final MarketPricesController ctrl;
  final ColorScheme cs;
  const _SearchBar({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: ctrl.onSearch,
        style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface),
        decoration: InputDecoration(
          hintText: 'Search materials (e.g. Cement, Steel...)',
          hintStyle: GoogleFonts.inter(
              fontSize: 13, color: cs.onSurfaceVariant),
          prefixIcon: Icon(Icons.search_rounded, size: 18, color: cs.onSurfaceVariant),
          filled: true,
          fillColor: cs.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Category filter chips ─────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final MarketPricesController ctrl;
  final ColorScheme cs;
  const _CategoryChips({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Obx(() {
        final selectedCat = ctrl.selectedCategory.value;
        return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: MarketPricesController.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat      = MarketPricesController.categories[i];
              final selected = selectedCat == cat;
              return GestureDetector(
                onTap: () => ctrl.selectCategory(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: selected ? cs.primary : cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? cs.primary
                          : cs.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(cat,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: selected ? Colors.white : cs.onSurfaceVariant)),
                  ),
                ),
              );
            },
          );
        }),
    );
  }
}

// ── Market info bar ───────────────────────────────────────────────────────────

class _MarketInfoBar extends StatelessWidget {
  final MarketPricesController ctrl;
  final ColorScheme cs;
  const _MarketInfoBar({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lu = ctrl.lastUpdated.value;
      if (lu == null) return const SizedBox.shrink();
      final h = lu.hour.toString().padLeft(2, '0');
      final m = lu.minute.toString().padLeft(2, '0');
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                  color: Color(0xFF16A34A), shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text('Live • Updated $h:$m',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface)),
            const Spacer(),
            GestureDetector(
              onTap: ctrl.loadPrices,
              child: Row(
                children: [
                  Icon(Icons.refresh_rounded, size: 13, color: cs.primary),
                  const SizedBox(width: 3),
                  Text('Refresh',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.primary)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Material list ─────────────────────────────────────────────────────────────

class _MaterialList extends StatelessWidget {
  final MarketPricesController ctrl;
  final ColorScheme cs;
  const _MaterialList({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
        );
      }
      final items = ctrl.filteredMaterials;
      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔍', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              Text('No materials found',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant)),
            ],
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _MaterialCard(entry: items[i], cs: cs),
      );
    });
  }
}

// ── Material card ─────────────────────────────────────────────────────────────

class _MaterialCard extends StatelessWidget {
  final MaterialPriceEntry entry;
  final ColorScheme cs;
  const _MaterialCard({required this.entry, required this.cs});

  @override
  Widget build(BuildContext context) {
    final trendColor = entry.isUp
        ? _kUp
        : entry.isDown
            ? _kDown
            : _kStable;
    final trendIcon = entry.isUp
        ? Icons.trending_up_rounded
        : entry.isDown
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;
    final trendBg = entry.isUp
        ? _kUp.withValues(alpha: 0.08)
        : entry.isDown
            ? _kDown.withValues(alpha: 0.08)
            : _kStable.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: cs.onSurface.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(entry.icon,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),

          // Name + prices
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(entry.name,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface)),
                    ),
                    // Trend badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: trendBg,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(trendIcon, size: 13, color: trendColor),
                          const SizedBox(width: 3),
                          Text(entry.changePctLabel,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: trendColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(entry.unit,
                    style: GoogleFonts.inter(
                        fontSize: 10, color: cs.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Previous + Current + Change (wrapped in Flexible to prevent overflow)
                    Flexible(
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Previous',
                                  style: GoogleFonts.inter(
                                      fontSize: 9, color: cs.onSurfaceVariant)),
                              Text(
                                'Rs ${_fmt(entry.previousPrice)}',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: cs.onSurfaceVariant,
                                    decoration: TextDecoration.lineThrough),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Current',
                                  style: GoogleFonts.inter(
                                      fontSize: 9, color: cs.onSurfaceVariant)),
                              Text(
                                'Rs ${_fmt(entry.currentPrice)}',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface),
                              ),
                            ],
                          ),
                          if (!entry.isStable) ...[
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Change',
                                    style: GoogleFonts.inter(
                                        fontSize: 9, color: cs.onSurfaceVariant)),
                                Text(
                                  '${entry.isUp ? '+' : '−'}Rs ${_fmt(entry.change.abs())}',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: trendColor),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Mini sparkline
                    SizedBox(
                      width: 52, height: 30,
                      child: _Sparkline(
                          data: entry.priceHistory, color: trendColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000)   return v.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return v.toStringAsFixed(0);
  }
}

// ── Sparkline using fl_chart ──────────────────────────────────────────────────

class _Sparkline extends StatelessWidget {
  final List<double> data;
  final Color color;
  const _Sparkline({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return const SizedBox.shrink();
    final spots = data.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final minY = data.reduce((a, b) => a < b ? a : b);
    final maxY = data.reduce((a, b) => a > b ? a : b);
    final range = (maxY - minY).abs();
    final pad   = range > 0 ? range * 0.2 : 10;

    return LineChart(
      LineChartData(
        minY: minY - pad,
        maxY: maxY + pad,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 1.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
      duration: Duration.zero,
    );
  }
}

// ── City picker sheet ─────────────────────────────────────────────────────────

class _CityPickerSheet extends StatelessWidget {
  final MarketPricesController ctrl;
  const _CityPickerSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Text('Select City',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
          ),
          ...MarketPricesController.cities.map((city) {
            return Obx(() => ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 2),
                  leading: Icon(Icons.location_city_rounded,
                      size: 20,
                      color: ctrl.selectedCity.value == city
                          ? cs.primary
                          : cs.onSurfaceVariant),
                  title: Text(city,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: ctrl.selectedCity.value == city
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
                ));
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
