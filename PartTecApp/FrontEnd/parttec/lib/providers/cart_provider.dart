import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  int get itemCount => _items.length;

  void addToCart(Map<String, dynamic> part) {
    _items.add(part);
    notifyListeners();
  }

  void removeFromCart(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void increaseQuantity(int index) {
    _items[index]['quantity'] = (_items[index]['quantity'] ?? 1) + 1;
    notifyListeners();
  }

  void decreaseQuantity(int index) {
    if ((_items[index]['quantity'] ?? 1) > 1) {
      _items[index]['quantity']--;
      notifyListeners();
    }
  }

  double get totalAmount {
    return _items.fold(0.0, (sum, item) {
      final price = item['price'] ?? 0.0;
      final qty = item['quantity'] ?? 1;
      return sum + (price * qty);
    });
  }
}
