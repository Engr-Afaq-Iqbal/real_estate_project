import 'package:get/get.dart';

class SavedCalculation {
  final String id;
  final String name;
  final String city;
  final String quality;
  final int floors;
  final double totalCost;
  final DateTime date;
  final bool isRenovation;

  const SavedCalculation({
    required this.id,
    required this.name,
    required this.city,
    required this.quality,
    required this.floors,
    required this.totalCost,
    required this.date,
    this.isRenovation = false,
  });

  static List<SavedCalculation> mockList() => [
        SavedCalculation(
          id: 'c1',
          name: 'DHA 10 Marla House',
          city: 'Lahore',
          quality: 'Standard',
          floors: 2,
          totalCost: 4850000,
          date: DateTime(2026, 5, 12),
        ),
        SavedCalculation(
          id: 'c2',
          name: 'Iqbal Commercial — 4 Marla',
          city: 'Lahore',
          quality: 'Premium',
          floors: 3,
          totalCost: 7200000,
          date: DateTime(2026, 5, 4),
        ),
        SavedCalculation(
          id: 'c3',
          name: 'Khan Villa Renovation',
          city: 'Lahore',
          quality: 'Economy',
          floors: 1,
          totalCost: 1420000,
          date: DateTime(2026, 4, 28),
          isRenovation: true,
        ),
      ];
}

class CalculatorController extends GetxController {
  final savedCalculations = <SavedCalculation>[].obs;
  final currentStep = 0.obs;

  // Form values
  final plotSize = '10'.obs;
  final plotUnit = 'Marla'.obs;
  final selectedCity = 'Lahore'.obs;
  final floors = 2.obs;
  final quality = 'Standard'.obs;

  // Result
  final estimatedCost = 4850000.0.obs;
  final breakdown = <String, double>{
    'Structure (RCC + Brick)': 1840000,
    'Finishing & Tiling': 1070000,
    'Electrical & Plumbing': 580000,
    'Doors / Windows / Kitchen': 530000,
    'Labor': 530000,
    'Misc & Boundary': 300000,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    savedCalculations.value = SavedCalculation.mockList();
  }

  void nextStep() {
    if (currentStep.value < 4) currentStep.value++;
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  double get breakdownTotal =>
      breakdown.values.fold(0, (a, b) => a + b);
}
