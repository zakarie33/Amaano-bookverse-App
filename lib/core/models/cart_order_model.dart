import '../utils/json_parsers.dart';

class CartOrderModel {
  const CartOrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.itemCount,
    this.paymentMethod,
    this.transactionId,
    this.adminNote,
    this.customerName,
    this.phone,
    this.email,
    this.fulfillmentType,
    this.deliveryAddress,
    this.deliveryCity,
    this.createdAt,
  });

  final int id;
  final String status;
  final double totalAmount;
  final int itemCount;
  final String? paymentMethod;
  final String? transactionId;
  final String? adminNote;
  final String? customerName;
  final String? phone;
  final String? email;
  final String? fulfillmentType;
  final String? deliveryAddress;
  final String? deliveryCity;
  final String? createdAt;

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  factory CartOrderModel.fromJson(Map<String, dynamic> json) {
    return CartOrderModel(
      id: parseIntSafe(json['id']),
      status: json['status']?.toString() ?? 'pending',
      totalAmount: parseDoubleSafe(json['total_amount']),
      itemCount: parseIntSafe(json['item_count']),
      paymentMethod: json['payment_method']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      adminNote: json['admin_note']?.toString(),
      customerName: json['customer_name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      fulfillmentType: json['fulfillment_type']?.toString(),
      deliveryAddress: json['delivery_address']?.toString(),
      deliveryCity: json['delivery_city']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
