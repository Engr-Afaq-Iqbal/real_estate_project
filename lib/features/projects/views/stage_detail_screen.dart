import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../controllers/projects_controller.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_badge.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/routes/app_routes.dart';

class StageDetailScreen extends GetView<ProjectsController> {
  const StageDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stage = controller.currentStage;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(stage?.name ?? 'Stage Detail'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz_rounded)),
        ],
      ),
      body: stage == null
          ? const Center(child: Text('No stage selected'))
          : Column(
              children: [
                // Stage header card
                Container(
                  margin: const EdgeInsets.all(AppDimensions.pagePaddingH),
                  padding: const EdgeInsets.all(AppDimensions.base),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: const Icon(Icons.business_outlined, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(stage.name, style: AppTextStyles.h3(context)),
                            const SizedBox(height: 2),
                            AppBadge(label: 'IN PROGRESS', variant: BadgeVariant.inProgress),
                          ],
                        ),
                      ),
                      CircularPercentIndicator(
                        radius: 32,
                        lineWidth: 5,
                        percent: stage.progress / 100,
                        center: Text(
                          '${stage.progress.toStringAsFixed(0)}%',
                          style: AppTextStyles.labelSmall(context),
                        ),
                        progressColor: AppColors.primary,
                        backgroundColor: isDark ? AppColors.borderDark : AppColors.dividerLight,
                      ),
                    ],
                  ),
                ),

                // Date stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePaddingH),
                  child: Row(
                    children: [
                      _DateStat(
                        label: 'STARTED',
                        value: stage.startDate != null
                            ? DateFormatter.formatDate(stage.startDate!)
                            : '—',
                      ),
                      _DateStat(
                        label: 'EST. END',
                        value: stage.estimatedEndDate != null
                            ? DateFormatter.formatDate(stage.estimatedEndDate!)
                            : '—',
                      ),
                      _DateStat(
                        label: 'DAYS LEFT',
                        value: '${stage.daysLeft} days',
                        valueColor: stage.daysLeft < 7 ? AppColors.warning : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.md),

                // Tabs
                DefaultTabController(
                  length: 4,
                  child: Expanded(
                    child: Column(
                      children: [
                        const TabBar(
                          isScrollable: true,
                          tabs: [
                            Tab(text: 'Updates'),
                            Tab(text: 'Expenses'),
                            Tab(text: 'Materials'),
                            Tab(text: 'Notes'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              const Center(child: Text('Updates coming soon')),
                              _ExpensesTab(stage: stage),
                              const Center(child: Text('Materials coming soon')),
                              const Center(child: Text('Notes coming soon')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.dividerLight)),
        ),
        child: AppButton(
          label: '+ Log Expense for Stage',
          onPressed: () => Get.toNamed(AppRoutes.logExpense),
        ),
      ),
    );
  }
}

class _DateStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DateStat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.overline(context)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTextStyles.h4(context).color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpensesTab extends StatelessWidget {
  final stage;
  const _ExpensesTab({required this.stage});

  @override
  Widget build(BuildContext context) {
    final mockExpenses = [
      {'name': 'Cement — Lucky 120 bags', 'category': 'Materials', 'date': '20 May', 'amount': 68400.0, 'hasReceipt': true},
      {'name': 'Mason wages — week 8', 'category': 'Labor', 'date': '18 May', 'amount': 42000.0, 'hasReceipt': false},
      {'name': 'Steel TMT 60 grade — 2.4 ton', 'category': 'Materials', 'date': '14 May', 'amount': 684000.0, 'hasReceipt': true},
      {'name': 'Mixer rental · 3 days', 'category': 'Equipment', 'date': '12 May', 'amount': 18500.0, 'hasReceipt': true},
      {'name': 'Bricks · 8,000 pcs', 'category': 'Materials', 'date': '10 May', 'amount': 112000.0, 'hasReceipt': false},
    ];

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        Text(
          'THIS STAGE · ${mockExpenses.length} EXPENSES',
          style: AppTextStyles.overline(context),
        ),
        const SizedBox(height: AppDimensions.md),
        ...mockExpenses.map((e) => _ExpenseRow(expense: e)),
      ],
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final Map<String, dynamic> expense;
  const _ExpenseRow({required this.expense});

  @override
  Widget build(BuildContext context) {
    final category = expense['category'] as String;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _categoryColor(category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense['name'] as String, style: AppTextStyles.labelLarge(context)),
                Text(
                  '${expense['category']} · ${expense['date']}',
                  style: AppTextStyles.caption(context),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(expense['amount'] as double),
                style: AppTextStyles.h4(context),
              ),
              if (expense['hasReceipt'] as bool)
                const Text(
                  '📎 Receipt',
                  style: TextStyle(fontSize: 11, color: AppColors.accent),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Materials': return AppColors.primary;
      case 'Labor': return AppColors.success;
      case 'Equipment': return AppColors.warning;
      default: return AppColors.textSecondaryLight;
    }
  }
}
