import 'package:equatable/equatable.dart';

class ExpenseModel extends Equatable {
  final String id;
  final String name;
  final String category;
  final double amount;
  final String? vendorSupplier;
  final DateTime date;
  final String? note;
  final String? receiptUrl;
  final String projectId;
  final String? stageId;

  const ExpenseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    this.vendorSupplier,
    required this.date,
    this.note,
    this.receiptUrl,
    required this.projectId,
    this.stageId,
  });

  bool get hasReceipt => receiptUrl != null && receiptUrl!.isNotEmpty;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        amount: (json['amount'] as num).toDouble(),
        vendorSupplier: json['vendor_supplier'] as String?,
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String?,
        receiptUrl: json['receipt_url'] as String?,
        projectId: json['project_id'] as String,
        stageId: json['stage_id'] as String?,
      );

  static List<String> get categories =>
      ['Materials', 'Labor', 'Contractor', 'Equipment', 'Approvals', 'Misc'];

  @override
  List<Object?> get props => [id, amount, category];
}
