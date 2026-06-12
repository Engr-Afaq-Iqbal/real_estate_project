import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/data/market_config_data.dart';
import '../../market/controllers/market_controller.dart';

/// Bottom sheet for picking a market / country.
class MarketSelectorSheet extends StatefulWidget {
  const MarketSelectorSheet._();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MarketSelectorSheet._(),
    );
  }

  @override
  State<MarketSelectorSheet> createState() => _MarketSelectorSheetState();
}

class _MarketSelectorSheetState extends State<MarketSelectorSheet> {
  final _searchCtrl = TextEditingController();
  String _query     = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final ctrl   = Get.find<MarketController>();
    final height = MediaQuery.of(context).size.height * 0.82;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),

          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text('Select Market',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close_rounded,
                      size: 22, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              autofocus: false,
              onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
              decoration: InputDecoration(
                hintText: 'Search country…',
                hintStyle: GoogleFonts.inter(
                    fontSize: 13, color: cs.onSurfaceVariant),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 18, color: cs.onSurfaceVariant),
                filled: true,
                fillColor: cs.surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.primary, width: 1.5)),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        child: Icon(Icons.clear_rounded,
                            size: 16, color: cs.onSurfaceVariant),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: Theme.of(context).dividerColor),

          // Market list
          Expanded(
            child: Obx(() {
              final selected = ctrl.selectedCode;
              final recents  = ctrl.recentMarkets;

              // Filter
              final allFiltered = _query.isEmpty
                  ? kAllMarkets
                  : kAllMarkets.where((m) =>
                      m.name.toLowerCase().contains(_query) ||
                      m.currency.toLowerCase().contains(_query) ||
                      m.code.toLowerCase().contains(_query) ||
                      m.region.toLowerCase().contains(_query)).toList();

              if (allFiltered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('No countries found for "$_query"',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: cs.onSurfaceVariant),
                        textAlign: TextAlign.center),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // Recent section (only when not searching)
                  if (_query.isEmpty && recents.isNotEmpty) ...[
                    _SectionHeader(label: 'Recent'),
                    ...recents.map((m) => _MarketTile(
                          market: m,
                          selected: m.code == selected,
                          onTap: () {
                            ctrl.selectMarket(m.code);
                            Navigator.of(context).pop();
                          },
                        )),
                    Divider(
                        height: 1,
                        color: Theme.of(context).dividerColor),
                    const SizedBox(height: 4),
                  ],

                  // Grouped sections
                  if (_query.isEmpty)
                    ...kRegionOrder
                        .where((r) => allFiltered.any((m) => m.region == r))
                        .expand((region) {
                      final items =
                          allFiltered.where((m) => m.region == region).toList();
                      return [
                        _SectionHeader(label: region),
                        ...items.map((m) => _MarketTile(
                              market: m,
                              selected: m.code == selected,
                              onTap: () {
                                ctrl.selectMarket(m.code);
                                Navigator.of(context).pop();
                              },
                            )),
                      ];
                    })
                  else
                    ...allFiltered.map((m) => _MarketTile(
                          market: m,
                          selected: m.code == selected,
                          onTap: () {
                            ctrl.selectMarket(m.code);
                            Navigator.of(context).pop();
                          },
                        )),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
}

// ── Market tile ───────────────────────────────────────────────────────────────

class _MarketTile extends StatelessWidget {
  final MarketInfo market;
  final bool selected;
  final VoidCallback onTap;
  const _MarketTile({
    required this.market,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? cs.primary.withValues(alpha: 0.05) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(market.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(market.name,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: cs.onSurface)),
                  Text('${market.currency}  ·  ${market.region}',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: cs.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
