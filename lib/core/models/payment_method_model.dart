import '../utils/json_parsers.dart';

class PaymentMethodModel {
  const PaymentMethodModel({
    required this.id,
    required this.methodName,
    required this.accountName,
    required this.accountNumber,
    this.instructions,
  });

  final int id;
  final String methodName;
  final String accountName;
  final String accountNumber;
  final String? instructions;

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: parseIntSafe(json['id']),
      methodName: json['method_name']?.toString() ?? 'Method',
      accountName: json['account_name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      instructions: json['instructions']?.toString(),
    );
  }
}
