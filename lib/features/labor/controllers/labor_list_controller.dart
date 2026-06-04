import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/labor_model.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:uuid/uuid.dart';

const _uuidLabor = Uuid();

class LaborListController extends GetxController {
  final isLoading  = false.obs;
  final laborList  = <LaborModel>[].obs;
  String? _projectId;

  @override
  void onInit() {
    super.onInit();
    _projectId = Get.arguments is String ? Get.arguments as String : 'p1';
    _loadLabor();
  }

  Future<void> _loadLabor() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    laborList.value = LaborModel.mockList(_projectId ?? 'p1');
    isLoading.value = false;
  }

  List<LaborModel> get activeLabor =>
      laborList.where((l) => l.isActive).toList();

  int get totalWorkers => activeLabor.length;

  double get totalDailyWage =>
      activeLabor.fold(0.0, (sum, l) => sum + l.dailyWage);

  String get formattedDailyTotal =>
      CurrencyFormatter.formatCompact(totalDailyWage);

  // ── Add labor ─────────────────────────────────────────────────────────────
  // Form fields (used by AddLaborSheet)
  final nameCtrl        = TextEditingController();
  final phoneCtrl       = TextEditingController();
  final roleCtrl        = TextEditingController();
  final dailyWageCtrl   = TextEditingController();
  final selectedRole    = 'Mason'.obs;
  final isSaving        = false.obs;

  Future<void> addLabor() async {
    final name = nameCtrl.text.trim();
    final wage = double.tryParse(dailyWageCtrl.text.trim()) ?? 0;
    if (name.isEmpty || wage <= 0) return;

    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    laborList.add(LaborModel(
      id: _uuidLabor.v4(),
      projectId: _projectId ?? 'p1',
      fullName: name,
      phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
      role: selectedRole.value,
      dailyWage: wage,
      currencyCode: 'PKR',
      status: LaborStatus.active,
      joinDate: DateTime.now(),
    ));

    _resetForm();
    isSaving.value = false;
    Get.back();
    Get.snackbar('Worker Added', '$name has been added to the project');
  }

  void _resetForm() {
    nameCtrl.clear();
    phoneCtrl.clear();
    dailyWageCtrl.clear();
    selectedRole.value = 'Mason';
  }

  // ── Release labor ─────────────────────────────────────────────────────────
  Future<void> releaseLabor(String laborId) async {
    final idx = laborList.indexWhere((l) => l.id == laborId);
    if (idx == -1) return;
    laborList[idx] = laborList[idx].copyWith(
      status: LaborStatus.released,
      releaseDate: DateTime.now(),
    );
    laborList.refresh();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    roleCtrl.dispose();
    dailyWageCtrl.dispose();
    super.onClose();
  }
}
