import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/wizard_step_config.dart';
import '../../../../../core/utils/date_formatter.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kPrimary   = Color(0xFF1C3A7A);
// ignore: unused_element
const _kBg        = Color(0xFFF8F9FC);
const _kCardBg    = Color(0xFFFFFFFF);
const _kBorder    = Color(0xFFE5E7EB);
const _kTextBody  = Color(0xFF374151);
const _kMuted     = Color(0xFF9CA3AF);
const _kLineColor = Color(0xFFE2E8F0);

/// Interactive drag-and-drop timeline with iOS-style shake edit mode.
///
/// Normal mode: clean vertical timeline with connecting line, colored dots,
///              and content cards.
///
/// Long-press to enter edit mode:
///  - Cards shake with staggered phase offsets (max ±1.8°) — adjacent cards
///    move in opposite directions so it looks organic, not mechanical
///  - Red delete circle on top-left of each dot
///  - Drag handle (≡) on the right side of each card
///  - "Done" button in the header exits edit mode
class InteractiveTimeline extends StatefulWidget {
  final List<WizardStage> stages;
  final bool editMode;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(String id) onDelete;
  final VoidCallback onToggleEditMode;

  const InteractiveTimeline({
    super.key,
    required this.stages,
    required this.editMode,
    required this.onReorder,
    required this.onDelete,
    required this.onToggleEditMode,
  });

  @override
  State<InteractiveTimeline> createState() => _InteractiveTimelineState();
}

class _InteractiveTimelineState extends State<InteractiveTimeline>
    with SingleTickerProviderStateMixin {
  // Single animation controller drives all cards.
  // Each card derives its own phase-offset from its index.
  late AnimationController _shakeController;
  String? _pendingDeleteId;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(InteractiveTimeline old) {
    super.didUpdateWidget(old);
    if (widget.editMode && !old.editMode) {
      _shakeController.repeat(reverse: false);
      _pendingDeleteId = null;
    } else if (!widget.editMode && old.editMode) {
      _shakeController.stop();
      _shakeController.reset();
      _pendingDeleteId = null;
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: Text(
            'No stages yet.\nGenerate the timeline in Step 4.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Proxy decorator: keeps the timeline-row shape during drag
      proxyDecorator: (child, index, anim) => Material(
        color: Colors.transparent,
        child: child,
      ),
      onReorder: (oldIdx, newIdx) {
        HapticFeedback.mediumImpact();
        widget.onReorder(oldIdx, newIdx);
      },
      itemCount: widget.stages.length,
      itemBuilder: (_, i) {
        final stage   = widget.stages[i];
        final isLast  = i == widget.stages.length - 1;
        final color   = _hexColor(stage.color);

        return _TimelineRow(
          key: ValueKey(stage.id),
          stage: stage,
          index: i,
          isLast: isLast,
          color: color,
          editMode: widget.editMode,
          isPendingDelete: _pendingDeleteId == stage.id,
          shakeController: _shakeController,
          onLongPress: () {
            if (!widget.editMode) {
              HapticFeedback.heavyImpact();
              widget.onToggleEditMode();
            }
          },
          onDeleteTap: () {
            setState(() {
              _pendingDeleteId =
                  _pendingDeleteId == stage.id ? null : stage.id;
            });
          },
          onDeleteConfirm: () {
            setState(() { _pendingDeleteId = null; });
            widget.onDelete(stage.id);
          },
          onDeleteCancel: () {
            setState(() { _pendingDeleteId = null; });
          },
        );
      },
    );
  }

  static Color _hexColor(String hex) {
    try { return Color(int.parse(hex.replaceFirst('#', '0xFF'))); }
    catch (_) { return const Color(0xFF1C3A7A); }
  }
}

// ── Timeline Row ──────────────────────────────────────────────────────────────
// Layout: [left column: dot + line] + [right: content card]

class _TimelineRow extends StatelessWidget {
  final WizardStage stage;
  final int index;
  final bool isLast;
  final Color color;
  final bool editMode;
  final bool isPendingDelete;
  final AnimationController shakeController;
  final VoidCallback onLongPress;
  final VoidCallback onDeleteTap;
  final VoidCallback onDeleteConfirm;
  final VoidCallback onDeleteCancel;

  const _TimelineRow({
    super.key,
    required this.stage,
    required this.index,
    required this.isLast,
    required this.color,
    required this.editMode,
    required this.isPendingDelete,
    required this.shakeController,
    required this.onLongPress,
    required this.onDeleteTap,
    required this.onDeleteConfirm,
    required this.onDeleteCancel,
  });

  @override
  Widget build(BuildContext context) {
    Widget row = GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: editMode ? 12 : 20,
          bottom: isLast ? 8 : 0,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left column: dot + vertical line ─────────────────────────
              _LeftColumn(
                color: color,
                index: index,
                isLast: isLast,
                editMode: editMode,
                isPendingDelete: isPendingDelete,
                onDeleteTap: onDeleteTap,
              ),
              const SizedBox(width: 12),

              // ── Right: card ───────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ContentCard(
                    stage: stage,
                    color: color,
                    index: index,
                    editMode: editMode,
                    isPendingDelete: isPendingDelete,
                    onDeleteConfirm: onDeleteConfirm,
                    onDeleteCancel: onDeleteCancel,
                  ),
                ),
              ),

              // ── Drag handle (edit mode only) ──────────────────────────────
              if (editMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: ReorderableDragStartListener(
                      index: index,
                      child: Container(
                        width: 32,
                        alignment: Alignment.center,
                        child: Icon(Icons.drag_handle_rounded,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    // Shake animation: stagger phase by index so cards alternate direction
    if (editMode && !isPendingDelete) {
      row = AnimatedBuilder(
        animation: shakeController,
        builder: (_, child) {
          // Phase offset: odd indices shake opposite to even indices
          // Max angle reduced to 1.8° — subtle but perceptible
          const maxAngle = 1.8;
          const phaseShift = math.pi; // half cycle offset
          final t = shakeController.value * 2 * math.pi;
          final phase = index.isOdd ? t + phaseShift : t;
          final angle = maxAngle * math.sin(phase) * (math.pi / 180);

          return Transform.rotate(
            angle: angle,
            alignment: Alignment.center,
            child: child,
          );
        },
        child: row,
      );
    }

    return row;
  }
}

// ── Left column: dot + connector line ────────────────────────────────────────

class _LeftColumn extends StatelessWidget {
  final Color color;
  final int index;
  final bool isLast;
  final bool editMode;
  final bool isPendingDelete;
  final VoidCallback onDeleteTap;

  const _LeftColumn({
    required this.color,
    required this.index,
    required this.isLast,
    required this.editMode,
    required this.isPendingDelete,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // ── Stage dot ────────────────────────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 32, height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
              // Red delete button (edit mode, top-left of dot)
              if (editMode)
                Positioned(
                  left: -6, top: -6,
                  child: GestureDetector(
                    onTap: onDeleteTap,
                    child: Container(
                      width: 18, height: 18,
                      decoration: const BoxDecoration(
                          color: Color(0xFFDC2626), shape: BoxShape.circle),
                      child: const Icon(Icons.remove, color: Colors.white, size: 10),
                    ),
                  ).animate(target: editMode ? 1 : 0)
                      .scale(begin: const Offset(0, 0), end: const Offset(1, 1),
                          curve: Curves.elasticOut)
                      .fadeIn(),
                ),
            ],
          ),

          // ── Connector line to next stage ──────────────────────────────────
          if (!isLast)
            Expanded(
              child: Center(
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: 0.4),
                        Theme.of(context).dividerColor,
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Content card ──────────────────────────────────────────────────────────────

class _ContentCard extends StatelessWidget {
  final WizardStage stage;
  final Color color;
  final int index;
  final bool editMode;
  final bool isPendingDelete;
  final VoidCallback onDeleteConfirm;
  final VoidCallback onDeleteCancel;

  const _ContentCard({
    required this.stage,
    required this.color,
    required this.index,
    required this.editMode,
    required this.isPendingDelete,
    required this.onDeleteConfirm,
    required this.onDeleteCancel,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final divider = Theme.of(context).dividerColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPendingDelete
              ? const Color(0xFFDC2626).withValues(alpha: 0.4)
              : editMode
                  ? color.withValues(alpha: 0.25)
                  : divider,
          width: isPendingDelete || editMode ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Colored left accent bar
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(width: 3, color: color),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
              child: _CardBody(stage: stage, color: color),
            ),
            // Delete confirm overlay
            if (isPendingDelete)
              Positioned.fill(
                child: _DeleteConfirmOverlay(
                  stageName: stage.name,
                  onConfirm: onDeleteConfirm,
                  onCancel: onDeleteCancel,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Card body ─────────────────────────────────────────────────────────────────

class _CardBody extends StatelessWidget {
  final WizardStage stage;
  final Color color;
  const _CardBody({required this.stage, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final muted = cs.onSurfaceVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stage.name,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: cs.onSurface, height: 1.3),
              ),
              if (stage.startDate != null) ...[
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 10, color: muted),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.formatDateShort(stage.startDate!),
                      style: TextStyle(fontSize: 11, color: muted),
                    ),
                    if (stage.endDate != null) ...[
                      Text(' → ', style: TextStyle(fontSize: 10, color: muted)),
                      Text(
                        DateFormatter.formatDateShort(stage.endDate!),
                        style: TextStyle(fontSize: 11, color: muted),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Duration badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            stage.formattedDuration,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    );
  }
}

// ── Delete confirmation overlay ───────────────────────────────────────────────

class _DeleteConfirmOverlay extends StatelessWidget {
  final String stageName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const _DeleteConfirmOverlay({
    required this.stageName,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    const danger = Color(0xFFDC2626);

    return Container(
      color: danger.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 14, color: danger),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Remove "${_stageShort(stageName)}"?',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w500, color: danger),
            ),
          ),
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: Text('Cancel',
                style: TextStyle(color: muted, fontSize: 11)),
          ),
          GestureDetector(
            onTap: onConfirm,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Remove',
                  style: TextStyle(
                      color: Colors.white, fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: 0.3, end: 0, duration: 200.ms,
        curve: Curves.easeOutCubic);
  }
}

String _stageShort(String name) =>
    name.length > 20 ? '${name.substring(0, 20)}…' : name;
