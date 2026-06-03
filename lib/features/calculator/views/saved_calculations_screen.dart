import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/calculator_controller.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_card.dart';
import '../../../presentation/routes/app_routes.dart';

class SavedCalculationsScreen extends GetView<CalculatorController> {
  const SavedCalculationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('calculation_history'.tr)),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePaddingH,
              AppDimensions.md,
              AppDimensions.pagePaddingH,
              0,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search_past_calculations'.tr,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Expanded(
            child: Obx(
              () => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePaddingH),
                itemCount: controller.savedCalculations.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.md),
                itemBuilder: (_, i) => _CalcCard(calc: controller.savedCalculations[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalcCard extends StatelessWidget {
  final SavedCalculation calc;
  const _CalcCard({required this.calc});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                calc.isRenovation ? '🛋' : (calc.floors > 2 ? '🏢' : '🏠'),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(calc.name, style: AppTextStyles.h4(context)),
                    Text(
                      CurrencyFormatter.formatLakh(calc.totalCost),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(calc.date),
                style: AppTextStyles.caption(context),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Wrap(
            spacing: AppDimensions.sm,
            children: [
              _Tag(calc.city),
              _Tag(calc.quality),
              _Tag('${calc.floors} ${calc.floors == 1 ? 'Floor' : 'Floors'}'),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.calculatorForm),
                child: Text('view_details'.tr),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  minimumSize: Size.zero,
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: Text('use_as_budget'.tr),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
    );
  }
}
