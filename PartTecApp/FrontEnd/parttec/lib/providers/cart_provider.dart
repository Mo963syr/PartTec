import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_settings.dart';
import '../models/part.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  String userid = '687ff5a6bf0de81878ed94f5';

  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  bool isLoading = false;
  String? error;

  Future<void> fetchCartFromServer() async {
    final url = Uri.parse('${AppSettings.serverurl}/cart/viewcartitem/$userid');

    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['cart'] != null) {
          final List<dynamic> list = data['cart'];
          _cartItems = list
              .where((e) => e is Map<String, dynamic>)
              .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          _cartItems = [];
        }
      } else {
        error = 'فشل التحميل: ${response.statusCode}';
        _cartItems = [];
      }
    } catch (e) {
      error = 'خطأ في تحميل السلة: $e';
      _cartItems = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void removeAt(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }

  Future<bool> addToCartToServer(Part part) async {
    final url = Uri.parse('${AppSettings.serverurl}/cart/addToCart');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userid,
          'partId': part.id,
          'coordinates': [44.1910, 15.3694],
        }),
      );

      if (response.statusCode == 201) {
        return false;
      } else {
        print('فشل في الإرسال: ${response.statusCode}, ${response.body}');
        return true;
      }
    } catch (e) {
      print('حدث خطأ أثناء الإرسال إلى السلة: $e');
      return true;
    }
  }
}
