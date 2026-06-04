import 'package:get/get.dart';
import '../controllers/calculator_controller.dart';
import '../controllers/calculator_hub_controller.dart';
import '../controllers/house_estimator_controller.dart';
import '../controllers/material_calculator_controller.dart';
import '../controllers/what_if_controller.dart';

class CalculatorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalculatorController>(() => CalculatorController());
    Get.lazyPut<CalculatorHubController>(() => CalculatorHubController());
    Get.lazyPut<HouseEstimatorController>(() => HouseEstimatorController());
    Get.lazyPut<MaterialCalculatorController>(
        () => MaterialCalculatorController());
    Get.lazyPut<WhatIfController>(() => WhatIfController());
  }
}
