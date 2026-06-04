import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../data/models/expense_model.dart';
import '../../projects/data/models/project_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/theme/app_colors.dart';

const _uuidBudget = Uuid();

class BudgetController extends GetxController {
  final isLoading    = false.obs;
  final expenses     = <ExpenseModel>[].obs;
  ProjectModel? _project;
  String _projectId  = 'p1';

  // ── Project budget data ───────────────────────────────────────────────────
  final totalBudget  = 0.0.obs;
  final spentBudget  = 0.0.obs;

  double get budgetProgress =>
      totalBudget.value > 0 ? spentBudget.value / totalBudget.value : 0;
  double get remainingBudget => totalBudget.value - spentBudget.value;

  // ── Category breakdown (Map<name, {spent, budget}>) — matches existing view ─
  Map<String, Map<String, double>> get categoryBreakdown {
    final total = totalBudget.value;
    final allocations = {
      'Materials & Steel': 0.60,
      'Labor':             0.25,
      'Contractor Fee':    0.05,
      'Equipment':         0.04,
      'Approvals':         0.03,
      'Misc':              0.03,
    };
    // Map expense types to display categories
    final spentByDisplay = <String, double>{};
    for (final e in expenses) {
      final display = switch (e.expenseType) {
        'material'  => 'Materials & Steel',
        'labor'     => 'Labor',
        'service'   => 'Contractor Fee',
        'equipment' => 'Equipment',
        'approval'  => 'Approvals',
        _           => 'Misc',
      };
      spentByDisplay[display] = (spentByDisplay[display] ?? 0) + e.amount;
    }
    return allocations.map((name, pct) => MapEntry(name, {
          'budget': total * pct,
          'spent': spentByDisplay[name] ?? 0,
        }));
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ProjectModel) {
      _project   = Get.arguments as ProjectModel;
      _projectId = _project!.id;
      totalBudget.value  = _project!.budgetAmount;
      spentBudget.value  = _project!.actualCost;
    }
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    expenses.value = ExpenseModel.mockList(_projectId);
    // Recompute spent from actual expense data
    spentBudget.value = expenses.fold(0.0, (sum, e) => sum + e.amount);
    isLoading.value = false;
  }

  // ── Log Expense Form ──────────────────────────────────────────────────────
  final selectedCategory = 'material'.obs;
  final itemNameCtrl     = TextEditingController();
  final amountCtrl       = TextEditingController();
  final vendorCtrl       = TextEditingController();
  final noteCtrl         = TextEditingController();
  final quantityCtrl     = TextEditingController();
  final unitPriceCtrl    = TextEditingController();
  final selectedDate     = DateTime.now().obs;
  final selectedStageId  = Rxn<String>();
  final isSaving         = false.obs;

  Future<void> saveExpense() async {
    final title  = itemNameCtrl.text.trim();
    final amount = double.tryParse(amountCtrl.text.trim().replaceAll(',', '')) ?? 0;
    if (title.isEmpty || amount <= 0) return;

    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    final expense = ExpenseModel(
      id: _uuidBudget.v4(),
      projectId: _projectId,
      stageId: selectedStageId.value,
      title: title,
      amount: amount,
      currencyCode: 'PKR',
      quantity: double.tryParse(quantityCtrl.text.trim()),
      unitPrice: double.tryParse(unitPriceCtrl.text.trim()),
      expenseType: selectedCategory.value,
      vendorName: vendorCtrl.text.trim().isNotEmpty ? vendorCtrl.text.trim() : null,
      notes: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : null,
      expenseDate: selectedDate.value,
      loggedBy: 'current_user',
      createdAt: DateTime.now(),
    );

    expenses.insert(0, expense);
    spentBudget.value += amount;

    resetForm();
    isSaving.value = false;
    Get.back();
    Get.snackbar(
      'Expense Logged',
      '${CurrencyFormatter.formatCompact(amount)} added to project budget',
      backgroundColor: AppColors.successLight,
      colorText: AppColors.success,
    );
  }

  void resetForm() {
    itemNameCtrl.clear();
    amountCtrl.clear();
    vendorCtrl.clear();
    noteCtrl.clear();
    quantityCtrl.clear();
    unitPriceCtrl.clear();
    selectedCategory.value = 'material';
    selectedDate.value = DateTime.now();
    selectedStageId.value = null;
  }

  // ── Expense list helpers ──────────────────────────────────────────────────

  List<ExpenseModel> get recentExpenses =>
      expenses.take(5).toList();

  List<ExpenseModel> expensesForStage(String stageId) =>
      expenses.where((e) => e.stageId == stageId).toList();

  double totalForStage(String stageId) =>
      expensesForStage(stageId).fold(0.0, (s, e) => s + e.amount);

  @override
  void onClose() {
    itemNameCtrl.dispose();
    amountCtrl.dispose();
    vendorCtrl.dispose();
    noteCtrl.dispose();
    quantityCtrl.dispose();
    unitPriceCtrl.dispose();
    super.onClose();
  }
}
