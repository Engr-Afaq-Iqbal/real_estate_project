import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../presentation/theme/app_colors.dart';

class BudgetController extends GetxController {
  final isLoading = false.obs;
  final totalBudget = 5000000.0.obs;
  final spentBudget = 3400000.0.obs;

  // Log expense form
  final selectedCategory = 'Materials'.obs;
  final itemNameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final vendorCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final selectedDate = DateTime.now().obs;
  final isSaving = false.obs;

  final categoryBreakdown = <String, Map<String, double>>{
    'Materials & Steel': {'spent': 1420000, 'budget': 2000000},
    'Labor': {'spent': 840000, 'budget': 1200000},
    'Contractor Fee': {'spent': 500000, 'budget': 800000},
    'Equipment': {'spent': 360000, 'budget': 600000},
    'Approvals': {'spent': 180000, 'budget': 200000},
    'Misc': {'spent': 100000, 'budget': 200000},
  }.obs;

  double get budgetProgress => spentBudget.value / totalBudget.value;
  double get remainingBudget => totalBudget.value - spentBudget.value;

  Future<void> saveExpense() async {
    isSaving.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isSaving.value = false;
    Get.back();
    Get.snackbar(
      'Success',
      'Expense logged successfully',
      backgroundColor: AppColors.successLight,
      colorText: AppColors.success,
    );
  }

  void resetForm() {
    itemNameCtrl.clear();
    amountCtrl.clear();
    vendorCtrl.clear();
    noteCtrl.clear();
    selectedCategory.value = 'Materials';
    selectedDate.value = DateTime.now();
  }

  @override
  void onClose() {
    itemNameCtrl.dispose();
    amountCtrl.dispose();
    vendorCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }
}

