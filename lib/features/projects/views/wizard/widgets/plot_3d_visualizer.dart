import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Isometric 3D plot visualizer.
/// Draws a clean 3D isometric block representing the plot + covered area.
/// Supports multi-floor stacking and gesture rotation.
class Plot3DVisualizer extends StatefulWidget {
  final double plotSizeSqm;
  final double? coveredAreaSqm;
  final double? widthM;
  final double? depthM;
  final int floors;

  const Plot3DVisualizer({
    super.key,
    required this.plotSizeSqm,
    this.coveredAreaSqm,
    this.widthM,
    this.depthM,
    this.floors = 1,
  });

  @override
  State<Plot3DVisualizer> createState() => _Plot3DVisualizerState();
}

class _Plot3DVisualizerState extends State<Plot3DVisualizer>
    with TickerProviderStateMixin {
  double _rotationAngle = math.pi / 6;  // initial ~30° rotation
  double _startAngle    = 0;
  double _scale         = 1.0;
  double _startScale    = 1.0;

  late AnimationController _buildController;
  late Animation<double>    _buildAnim;

  @override
  void initState() {
    super.initState();
    _buildController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _buildAnim = CurvedAnimation(
      parent: _buildController,
      curve: Curves.easeOutCubic,
    );
    _buildController.forward();
  }

  @override
  void didUpdateWidget(Plot3DVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.floors != widget.floors ||
        oldWidget.plotSizeSqm != widget.plotSizeSqm) {
      _buildController.reset();
      _buildController.forward();
    }
  }

  @override
  void dispose() {
    _buildController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (d) {
        _startAngle = _rotationAngle;
        _startScale = _scale;
      },
      onScaleUpdate: (d) {
        setState(() {
          _rotationAngle = _startAngle + d.rotation;
          _scale = (_startScale * d.scale).clamp(0.5, 2.5);
        });
      },
      onHorizontalDragUpdate: (d) {
        setState(() {
          _rotationAngle += d.delta.dx * 0.01;
        });
      },
      child: AnimatedBuilder(
        animation: _buildAnim,
        builder: (_, __) => CustomPaint(
          size: const Size(double.infinity, 220),
          painter: _IsometricPlotPainter(
            plotSizeSqm: widget.plotSizeSqm,
            coveredAreaSqm: widget.coveredAreaSqm ?? widget.plotSizeSqm * 0.7,
            widthM: widget.widthM,
            depthM: widget.depthM,
            floors: widget.floors,
            rotation: _rotationAngle,
            scale: _scale,
            buildProgress: _buildAnim.value,
          ),
        ),
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _IsometricPlotPainter extends CustomPainter {
  final double plotSizeSqm;
  final double coveredAreaSqm;
  final double? widthM;
  final double? depthM;
  final int floors;
  final double rotation;
  final double scale;
  final double buildProgress;  // 0→1 for build-up animation

  _IsometricPlotPainter({
    required this.plotSizeSqm,
    required this.coveredAreaSqm,
    required this.widthM,
    required this.depthM,
    required this.floors,
    required this.rotation,
    required this.scale,
    required this.buildProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.6);

    // Compute block dimensions in "world units"
    // 1 world unit ≈ some pixels. Scale to fit reasonably.
    double w, d;
    if (widthM != null && depthM != null) {
      w = widthM!;
      d = depthM!;
    } else {
      // Square root approximation: if plot is W × D = area, assume ~1:1.4 ratio
      final side = math.sqrt(plotSizeSqm);
      w = side;
      d = side;
    }

    // Normalize to screen units (world 1 = ~40 px)
    final maxDim = math.max(w, d);
    final unitPx  = (math.min(size.width, size.height) * 0.28 / maxDim) * scale;

    // Covered area ratio
    final coverRatio = math.sqrt(coveredAreaSqm / plotSizeSqm).clamp(0.0, 1.0);

    // Draw ground / plot surface
    _drawPlotSurface(canvas, center, w * unitPx, d * unitPx);

    // Draw floors (animated build-up)
    final floorHeight = 18.0 * scale;
    final floorsToShow = (floors * buildProgress).ceil().clamp(1, floors);

    for (int f = 0; f < floorsToShow; f++) {
      final floorAlpha  = f == 0 ? 1.0 : (1.0 - f * 0.12).clamp(0.3, 1.0);
      final floorAnimPct = ((buildProgress * floors - f)).clamp(0.0, 1.0);
      final baseZ = (f * floorHeight * floorAnimPct);

      _drawFloor(
        canvas, center,
        w * unitPx * coverRatio, d * unitPx * coverRatio,
        baseZ, floorHeight * floorAnimPct,
        floorIndex: f, alpha: floorAlpha,
      );
    }

    // Draw dimension labels
    if (widthM != null && depthM != null) {
      _drawDimensionLabels(canvas, center, w * unitPx, d * unitPx);
    }

    // Hint label
    _drawHint(canvas, size);
  }

  // ── Isometric projection ──────────────────────────────────────────────────

  /// Projects a 3D point (x, y, z) in world space to 2D screen space.
  /// x = east, y = south, z = up
  Offset _project(double x, double y, double z, Offset center) {
    // Apply Y-axis rotation
    final rx = x * math.cos(rotation) - y * math.sin(rotation);
    final ry = x * math.sin(rotation) + y * math.cos(rotation);

    // Isometric projection
    final sx = (rx - ry) * math.cos(math.pi / 6);
    final sy = (rx + ry) * math.sin(math.pi / 6) - z;

    return Offset(center.dx + sx, center.dy + sy);
  }

  // ── Draw plot ground surface ──────────────────────────────────────────────

  void _drawPlotSurface(Canvas canvas, Offset center, double w, double d) {
    final tl = _project(-w / 2,  d / 2, 0, center);
    final tr = _project( w / 2,  d / 2, 0, center);
    final br = _project( w / 2, -d / 2, 0, center);
    final bl = _project(-w / 2, -d / 2, 0, center);

    final path = Path()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(br.dx, br.dy)
      ..lineTo(bl.dx, bl.dy)
      ..close();

    // Glass-like light blue surface
    canvas.drawPath(path, Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0);
  }

  // ── Draw a floor block ────────────────────────────────────────────────────

  void _drawFloor(Canvas canvas, Offset center,
      double w, double d, double baseZ, double h, {
        required int floorIndex, required double alpha}) {
    if (h <= 0) return;

    // 8 corners of the box
    // Bottom face
    final b_tl = _project(-w / 2,  d / 2, baseZ, center);
    final b_tr = _project( w / 2,  d / 2, baseZ, center);
    final b_br = _project( w / 2, -d / 2, baseZ, center);
    final b_bl = _project(-w / 2, -d / 2, baseZ, center);
    // Top face
    final t_tl = _project(-w / 2,  d / 2, baseZ + h, center);
    final t_tr = _project( w / 2,  d / 2, baseZ + h, center);
    final t_br = _project( w / 2, -d / 2, baseZ + h, center);
    final t_bl = _project(-w / 2, -d / 2, baseZ + h, center);

    // Floor-indexed color
    final hue = 220 + floorIndex * 15;  // navy → blue → sky
    final baseColor = HSLColor.fromAHSL(alpha, hue.toDouble(), 0.65, 0.5).toColor();

    // Top face
    final topPath = Path()
      ..moveTo(t_tl.dx, t_tl.dy)
      ..lineTo(t_tr.dx, t_tr.dy)
      ..lineTo(t_br.dx, t_br.dy)
      ..lineTo(t_bl.dx, t_bl.dy)
      ..close();
    canvas.drawPath(topPath, Paint()
      ..color = HSLColor.fromAHSL(alpha, hue.toDouble(), 0.65, 0.65).toColor()
      ..style = PaintingStyle.fill);

    // Left face (south-west)
    final leftPath = Path()
      ..moveTo(b_bl.dx, b_bl.dy)
      ..lineTo(t_bl.dx, t_bl.dy)
      ..lineTo(t_tl.dx, t_tl.dy)
      ..lineTo(b_tl.dx, b_tl.dy)
      ..close();
    canvas.drawPath(leftPath, Paint()
      ..color = HSLColor.fromAHSL(alpha, hue.toDouble(), 0.65, 0.4).toColor()
      ..style = PaintingStyle.fill);

    // Right face (south-east)
    final rightPath = Path()
      ..moveTo(b_br.dx, b_br.dy)
      ..lineTo(t_br.dx, t_br.dy)
      ..lineTo(t_bl.dx, t_bl.dy)
      ..lineTo(b_bl.dx, b_bl.dy)
      ..close();
    canvas.drawPath(rightPath, Paint()
      ..color = HSLColor.fromAHSL(alpha, hue.toDouble(), 0.65, 0.3).toColor()
      ..style = PaintingStyle.fill);

    // Outline
    final outline = Paint()
      ..color = const Color(0xFF1E3A8A).withValues(alpha: alpha * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final path in [topPath, leftPath, rightPath]) {
      canvas.drawPath(path, outline);
    }

    // Floor label (only on top face)
    if (floorIndex > 0) {
      final label = 'F$floorIndex';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: alpha)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelPos = Offset(
        (t_tl.dx + t_br.dx) / 2 - tp.width / 2,
        (t_tl.dy + t_br.dy) / 2 - tp.height / 2,
      );
      tp.paint(canvas, labelPos);
    }
  }

  // ── Dimension labels ──────────────────────────────────────────────────────

  void _drawDimensionLabels(Canvas canvas, Offset center, double w, double d) {
    final style = TextStyle(
        fontSize: 10,
        color: const Color(0xFF1E3A8A).withValues(alpha: 0.7),
        fontWeight: FontWeight.w500);

    // Width label (front edge)
    final wLabel = '${widthM!.toStringAsFixed(1)}m';
    final wLeft  = _project(-w / 2, -d / 2, 0, center);
    final wRight = _project( w / 2, -d / 2, 0, center);
    _drawLabel(canvas, Offset((wLeft.dx + wRight.dx) / 2, wLeft.dy + 12), wLabel, style);

    // Depth label (right edge)
    final dLabel = '${depthM!.toStringAsFixed(1)}m';
    final dTop   = _project( w / 2,  d / 2, 0, center);
    _drawLabel(canvas, Offset(wRight.dx + 14, (wRight.dy + dTop.dy) / 2), dLabel, style);
  }

  void _drawLabel(Canvas canvas, Offset pos, String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void _drawHint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: const TextSpan(
        text: '↔ Swipe to rotate',
        style: TextStyle(fontSize: 10, color: Color(0xFFADB5BD)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, size.height - 16));
  }

  @override
  bool shouldRepaint(_IsometricPlotPainter old) =>
      old.rotation        != rotation     ||
      old.scale           != scale        ||
      old.buildProgress   != buildProgress ||
      old.floors          != floors       ||
      old.plotSizeSqm     != plotSizeSqm;
}
