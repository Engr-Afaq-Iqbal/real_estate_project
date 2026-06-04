import 'package:equatable/equatable.dart';

class SavedCalculationModel extends Equatable {
  final String id;
  final String? userId;
  final String? projectId;
  final String calcType;    // material_single, what_if, full_house, multi_material
  final String title;
  final int? cityId;
  final String cityName;
  final String currencyCode;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> results;
  final String priceBasisDate;
  final double totalAmount;
  final DateTime createdAt;

  const SavedCalculationModel({
    required this.id,
    this.userId,
    this.projectId,
    required this.calcType,
    required this.title,
    this.cityId,
    this.cityName = 'Lahore',
    this.currencyCode = 'PKR',
    required this.inputs,
    required this.results,
    required this.priceBasisDate,
    required this.totalAmount,
    required this.createdAt,
  });

  static List<SavedCalculationModel> mockList() => [
        SavedCalculationModel(
          id: 'sc1',
          calcType: 'full_house',
          title: 'DHA 10 Marla House',
          cityName: 'Lahore',
          currencyCode: 'PKR',
          inputs: {
            'plot_size_value': 10,
            'plot_size_unit': 'marla',
            'floors': 2,
            'quality_tier': 'standard',
          },
          results: {
            'total': 8500000,
            'rate_per_sqft': 2380,
          },
          priceBasisDate: '2026-05-12',
          totalAmount: 8500000,
          createdAt: DateTime(2026, 5, 12),
        ),
        SavedCalculationModel(
          id: 'sc2',
          calcType: 'full_house',
          title: 'Iqbal Commercial — 4 Marla',
          cityName: 'Lahore',
          currencyCode: 'PKR',
          inputs: {
            'plot_size_value': 4,
            'plot_size_unit': 'marla',
            'floors': 3,
            'quality_tier': 'premium',
          },
          results: {'total': 7200000, 'rate_per_sqft': 3200},
          priceBasisDate: '2026-05-04',
          totalAmount: 7200000,
          createdAt: DateTime(2026, 5, 4),
        ),
        SavedCalculationModel(
          id: 'sc3',
          calcType: 'full_house',
          title: 'Khan Villa Renovation',
          cityName: 'Lahore',
          currencyCode: 'PKR',
          inputs: {
            'plot_size_value': 1,
            'plot_size_unit': 'kanal',
            'floors': 1,
            'quality_tier': 'economy',
            'is_renovation': true,
          },
          results: {'total': 1420000, 'rate_per_sqft': 800},
          priceBasisDate: '2026-04-28',
          totalAmount: 1420000,
          createdAt: DateTime(2026, 4, 28),
        ),
      ];

  factory SavedCalculationModel.fromJson(Map<String, dynamic> json) =>
      SavedCalculationModel(
        id: json['id'] as String,
        userId: json['user_id'] as String?,
        projectId: json['project_id'] as String?,
        calcType: json['calc_type'] as String,
        title: json['title'] as String,
        cityId: json['city_id'] as int?,
        cityName: json['city_name'] as String? ?? '',
        currencyCode: json['currency_code'] as String? ?? 'PKR',
        inputs: json['inputs'] as Map<String, dynamic>? ?? {},
        results: json['results'] as Map<String, dynamic>? ?? {},
        priceBasisDate: json['price_basis_date'] as String? ?? '',
        totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'project_id': projectId,
        'calc_type': calcType,
        'title': title,
        'city_id': cityId,
        'city_name': cityName,
        'currency_code': currencyCode,
        'inputs': inputs,
        'results': results,
        'price_basis_date': priceBasisDate,
        'total_amount': totalAmount,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, totalAmount, createdAt];
}
