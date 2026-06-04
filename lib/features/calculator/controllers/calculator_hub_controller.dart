import 'package:get/get.dart';
import '../../../core/services/price_master_service.dart';
import '../data/models/saved_calculation_model.dart';
import '../../../presentation/routes/app_routes.dart';

class CalculatorHubController extends GetxController {
  final savedCalculations = <SavedCalculationModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    savedCalculations.value = SavedCalculationModel.mockList();
    isLoading.value = false;
  }

  String get priceLastUpdated {
    try {
      return Get.find<PriceMasterService>().effectiveDate;
    } catch (_) {
      return '2026-06-01';
    }
  }

  void openMaterialCalculator() =>
      Get.toNamed(AppRoutes.materialCalculator);

  void openHouseEstimator() =>
      Get.toNamed(AppRoutes.houseEstimator);

  void openWhatIf() =>
      Get.toNamed(AppRoutes.whatIfCalculator);

  void openSaved() =>
      Get.toNamed(AppRoutes.savedCalculations);

  void deleteSaved(String id) {
    savedCalculations.removeWhere((c) => c.id == id);
  }
}
