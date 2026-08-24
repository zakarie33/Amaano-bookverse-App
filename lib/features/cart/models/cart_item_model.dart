import '../../../core/utils/json_parsers.dart';
import '../../books/models/content_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.content,
    this.quantity = 1,
  });

  final ContentModel content;
  final int quantity;

  double get lineTotal => parseDoubleSafe(content.price) * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      content: content,
      quantity: quantity ?? this.quantity,
    );
  }
}
