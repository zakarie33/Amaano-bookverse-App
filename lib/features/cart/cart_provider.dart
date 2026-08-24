import 'package:flutter/foundation.dart';

import 'models/cart_item_model.dart';
import '../books/models/content_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal =>
      _items.fold(0, (sum, i) => sum + i.lineTotal);

  bool contains(int contentId) =>
      _items.any((i) => i.content.id == contentId);

  void addItem(ContentModel content) {
    final index =
        _items.indexWhere((i) => i.content.id == content.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
    } else {
      _items.add(CartItemModel(content: content));
    }
    notifyListeners();
  }

  void removeItem(int contentId) {
    _items.removeWhere((i) => i.content.id == contentId);
    notifyListeners();
  }

  void updateQuantity(int contentId, int quantity) {
    final index = _items.indexWhere((i) => i.content.id == contentId);
    if (index < 0) return;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
