import 'package:equatable/equatable.dart';

class ExpenseModel extends Equatable {
  final String id;
  final String projectId;
  final String? scopeId;
  final String? stageId;
  final int? categoryId;

  final String title;
  final double amount;
  final String currencyCode;
  final double? quantity;
  final double? unitPrice;
  final String? unit;

  final String expenseType;     // material, labor, equipment, service, approval, other
  final String paymentMethod;   // cash, bank_transfer, cheque, online
  final String? vendorName;
  final String? invoiceNumber;
  final String? receiptUrl;
  final String? notes;

  final DateTime expenseDate;
  final String loggedBy;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String status;          // pending, approved, rejected

  final DateTime createdAt;

  // Backward-compat aliases used by existing screens
  String get name => title;
  String get category => expenseTypes.contains(expenseType) ? expenseType : 'material';
  DateTime get date => expenseDate;
  String? get note => notes;
  String? get vendorSupplier => vendorName;

  const ExpenseModel({
    required this.id,
    required this.projectId,
    this.scopeId,
    this.stageId,
    this.categoryId,
    required this.title,
    required this.amount,
    this.currencyCode = 'PKR',
    this.quantity,
    this.unitPrice,
    this.unit,
    this.expenseType = 'material',
    this.paymentMethod = 'cash',
    this.vendorName,
    this.invoiceNumber,
    this.receiptUrl,
    this.notes,
    required this.expenseDate,
    required this.loggedBy,
    this.approvedBy,
    this.approvedAt,
    this.status = 'approved',
    required this.createdAt,
  });

  bool get hasReceipt => receiptUrl != null && receiptUrl!.isNotEmpty;

  static const List<String> categoryLabels = [
    'Materials', 'Labor', 'Contractor', 'Equipment',
    'Approvals & Fees', 'Transport', 'Miscellaneous',
  ];

  static const List<String> expenseTypes = [
    'material', 'labor', 'equipment', 'service', 'approval', 'other',
  ];

  static List<String> get categories => categoryLabels;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        scopeId: json['scope_id'] as String?,
        stageId: json['stage_id'] as String?,
        categoryId: json['category_id'] as int?,
        title: json['title'] as String? ?? json['name'] as String? ?? '',
        amount: (json['amount'] as num).toDouble(),
        currencyCode: json['currency_code'] as String? ?? 'PKR',
        quantity: (json['quantity'] as num?)?.toDouble(),
        unitPrice: (json['unit_price'] as num?)?.toDouble(),
        unit: json['unit'] as String?,
        expenseType: json['expense_type'] as String? ?? 'material',
        paymentMethod: json['payment_method'] as String? ?? 'cash',
        vendorName: json['vendor_name'] as String? ?? json['vendor_supplier'] as String?,
        invoiceNumber: json['invoice_number'] as String?,
        receiptUrl: json['receipt_url'] as String?,
        notes: json['notes'] as String? ?? json['note'] as String?,
        expenseDate: DateTime.parse(
            json['expense_date'] as String? ?? json['date'] as String? ??
                DateTime.now().toIso8601String()),
        loggedBy: json['logged_by'] as String? ?? '',
        approvedBy: json['approved_by'] as String?,
        approvedAt: json['approved_at'] != null
            ? DateTime.parse(json['approved_at'] as String)
            : null,
        status: json['status'] as String? ?? 'approved',
        createdAt: DateTime.parse(
            json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'scope_id': scopeId,
        'stage_id': stageId,
        'category_id': categoryId,
        'title': title,
        'amount': amount,
        'currency_code': currencyCode,
        'quantity': quantity,
        'unit_price': unitPrice,
        'unit': unit,
        'expense_type': expenseType,
        'payment_method': paymentMethod,
        'vendor_name': vendorName,
        'invoice_number': invoiceNumber,
        'receipt_url': receiptUrl,
        'notes': notes,
        'expense_date': expenseDate.toIso8601String().substring(0, 10),
        'logged_by': loggedBy,
        'approved_by': approvedBy,
        'approved_at': approvedAt?.toIso8601String(),
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };

  static List<ExpenseModel> mockList(String projectId) => [
        ExpenseModel(
          id: 'e1', projectId: projectId,
          title: 'DG Khan Cement — 200 bags',
          amount: 256000, currencyCode: 'PKR',
          quantity: 200, unitPrice: 1280, unit: 'bag',
          expenseType: 'material',
          vendorName: 'Ali Building Materials',
          expenseDate: DateTime.now().subtract(const Duration(days: 3)),
          loggedBy: 'u1',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        ExpenseModel(
          id: 'e2', projectId: projectId,
          title: 'Amreli Steel — 2 tons',
          amount: 524000, currencyCode: 'PKR',
          quantity: 2000, unitPrice: 262, unit: 'kg',
          expenseType: 'material',
          vendorName: 'Punjab Steel Traders',
          expenseDate: DateTime.now().subtract(const Duration(days: 7)),
          loggedBy: 'u1',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        ExpenseModel(
          id: 'e3', projectId: projectId,
          title: 'Weekly Labor Payment',
          amount: 87500, currencyCode: 'PKR',
          expenseType: 'labor',
          expenseDate: DateTime.now().subtract(const Duration(days: 1)),
          loggedBy: 'u1',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ExpenseModel(
          id: 'e4', projectId: projectId,
          title: 'JCB Hire — Excavation',
          amount: 45000, currencyCode: 'PKR',
          expenseType: 'equipment',
          vendorName: 'Khan JCB Services',
          expenseDate: DateTime.now().subtract(const Duration(days: 14)),
          loggedBy: 'u1',
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
      ];

  @override
  List<Object?> get props => [id, amount, expenseDate];
}
