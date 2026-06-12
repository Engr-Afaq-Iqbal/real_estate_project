import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/projects_controller.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';

const _kSuccess = Color(0xFF16A34A);
const _kError   = Color(0xFFEF4444);

class ProjectReportScreen extends GetView<ProjectsController> {
  const ProjectReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = controller.selectedProject.value;
    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report')),
        body: const Center(child: Text('No project selected')),
      );
    }

    final cs       = Theme.of(context).colorScheme;
    final progress = controller.overallProgress;
    final budget   = project.budgetAmount;
    final spent    = project.actualCost;
    final remaining = budget - spent;
    final pct      = budget > 0 ? (spent / budget * 100).toStringAsFixed(0) : '0';

    final reportText = _buildShareText(project, progress, budget, spent);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Progress Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share report',
            onPressed: () =>
                Share.share(reportText, subject: '${project.name} — Progress Report'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                Get.snackbar(
                  'PDF Downloaded',
                  'Report saved to Downloads folder (mock)',
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                  backgroundColor: _kSuccess.withValues(alpha: 0.9),
                  colorText: Colors.white,
                  icon: const Icon(Icons.download_done_rounded,
                      color: Colors.white, size: 18),
                );
              },
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
              label: const Text('Download PDF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
                minimumSize: Size.zero,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── PDF-style document ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.construction_rounded,
                              color: cs.primary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BuildOS',
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                              Text('Construction Progress Report',
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: Colors.white.withValues(alpha: 0.75))),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Generated',
                                style: GoogleFonts.inter(
                                    fontSize: 9,
                                    color: Colors.white.withValues(alpha: 0.65))),
                            Text(_fmtDate(DateTime.now()),
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Project info
                        _ReportSection(title: 'Project Information'),
                        const SizedBox(height: 10),
                        _InfoRow(label: 'Project Name', value: project.name),
                        _InfoRow(label: 'Location',
                            value: '${project.area}, ${project.city}'),
                        if (project.startDate != null)
                          _InfoRow(label: 'Start Date',
                              value: DateFormatter.formatDateShort(
                                  project.startDate!)),
                        _InfoRow(label: 'Estimated Completion',
                            value: DateFormatter.formatDateShort(
                                project.estimatedEndDate)),
                        const SizedBox(height: 20),

                        // Progress
                        _ReportSection(title: 'Overall Progress'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: (progress / 100).clamp(0.0, 1.0),
                                      minHeight: 12,
                                      backgroundColor:
                                          const Color(0xFFE2E8F0),
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              cs.primary),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                      'Current Stage: ${project.currentStage}',
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: const Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              children: [
                                Text(
                                  '${progress.toStringAsFixed(0)}%',
                                  style: GoogleFonts.inter(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: cs.primary),
                                ),
                                Text('Complete',
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: const Color(0xFF64748B))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Budget summary
                        _ReportSection(title: 'Budget Summary'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _BudgetBox(
                                label: 'Total Budget',
                                value: CurrencyFormatter.formatPKR(budget),
                                color: cs.primary),
                            const SizedBox(width: 8),
                            _BudgetBox(
                                label: 'Spent ($pct%)',
                                value: CurrencyFormatter.formatPKR(spent),
                                color: double.parse(pct) > 80
                                    ? _kError
                                    : _kSuccess),
                            const SizedBox(width: 8),
                            _BudgetBox(
                                label: 'Remaining',
                                value: CurrencyFormatter.formatPKR(remaining),
                                color: const Color(0xFF475569)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Stage updates
                        _ReportSection(title: 'Recent Stage Updates'),
                        const SizedBox(height: 10),
                        ..._recentUpdates().map((u) => _UpdateRow(update: u)),
                        const SizedBox(height: 20),

                        // Photo placeholders
                        _ReportSection(title: 'Site Photos'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _PhotoPlaceholder(
                                label: 'Foundation',
                                emoji: '🏗️'),
                            const SizedBox(width: 10),
                            _PhotoPlaceholder(
                                label: 'Gray Structure',
                                emoji: '🧱'),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Footer
                        Center(
                          child: Column(
                            children: [
                              const Divider(),
                              const SizedBox(height: 8),
                              Text('Generated by BuildOS — Construction Manager',
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: const Color(0xFF94A3B8))),
                              Text('This report is auto-generated from project data.',
                                  style: GoogleFonts.inter(
                                      fontSize: 9,
                                      color: const Color(0xFFCBD5E1))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static String _fmtDate(DateTime dt) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
               'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  static List<_Update> _recentUpdates() => [
        _Update(
          stage: 'Foundation',
          text: 'Foundation work completed. Plinth beam installed.',
          date: DateTime.now().subtract(const Duration(days: 5)),
          by: 'Bashir Ahmed',
        ),
        _Update(
          stage: 'Gray Structure',
          text: 'Ground floor columns and beams cast. 75% complete.',
          date: DateTime.now().subtract(const Duration(days: 12)),
          by: 'Bashir Ahmed',
        ),
        _Update(
          stage: 'Excavation',
          text: 'Excavation completed, soil testing done.',
          date: DateTime.now().subtract(const Duration(days: 28)),
          by: 'Ali Supervisor',
        ),
      ];

  String _buildShareText(dynamic project, double progress,
      double budget, double spent) {
    return '''${project.name} — Progress Report

Location: ${project.area}, ${project.city}
Current Stage: ${project.currentStage}
Overall Progress: ${progress.toStringAsFixed(0)}%

BUDGET SUMMARY
Total: ${CurrencyFormatter.formatPKR(budget)}
Spent: ${CurrencyFormatter.formatPKR(spent)}
Remaining: ${CurrencyFormatter.formatPKR(budget - spent)}

Generated by BuildOS 🏗
Report date: ${_fmtDate(DateTime.now())}''';
  }
}

class _ReportSection extends StatelessWidget {
  final String title;
  const _ReportSection({required this.title});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 3, height: 14,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface)),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: const Color(0xFF64748B))),
            ),
            Expanded(
              child: Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F172A))),
            ),
          ],
        ),
      );
}

class _BudgetBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _BudgetBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
              const SizedBox(height: 2),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 9,
                      color: const Color(0xFF64748B)),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _Update {
  final String stage, text, by;
  final DateTime date;
  const _Update(
      {required this.stage, required this.text, required this.by,
       required this.date});
}

class _UpdateRow extends StatelessWidget {
  final _Update update;
  const _UpdateRow({required this.update});

  @override
  Widget build(BuildContext context) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final d = update.date;
    final dateStr = '${d.day} ${months[d.month - 1]}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(update.stage,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary)),
                    const Spacer(),
                    Text(dateStr,
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFF94A3B8))),
                  ],
                ),
                Text(update.text,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: const Color(0xFF374151))),
                Text('— ${update.by}',
                    style: GoogleFonts.inter(
                        fontSize: 10, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  final String label, emoji;
  const _PhotoPlaceholder({required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 10, color: const Color(0xFF64748B))),
              Text('[Photo]',
                  style: GoogleFonts.inter(
                      fontSize: 9, color: const Color(0xFFCBD5E1))),
            ],
          ),
        ),
      );
}
