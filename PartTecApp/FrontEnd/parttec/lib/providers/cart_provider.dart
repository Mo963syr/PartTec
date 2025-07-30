import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parttec/setting.dart';

class CartProvider extends ChangeNotifier {
  String userid = '687ff5a6bf0de81878ed94f5';

  List<Map<String, dynamic>> _fetchedCartItems = [];

  List<Map<String, dynamic>> get fetchedCartItems => _fetchedCartItems;

  bool isLoading = false;
  String? error;

  // ✅ تحميل السلة من السيرفر
  Future<void> fetchCartFromServer() async {
    final url =
        Uri.parse('https://parttec.onrender.com/cart/viewcartitem/$userid');

    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['cart'] != null) {
          _fetchedCartItems = List<Map<String, dynamic>>.from(data['cart']);
        } else {
          _fetchedCartItems = [];
        }
      } else {
        error = 'فشل التحميل: ${response.statusCode}';
        _fetchedCartItems = [];
      }
    } catch (e) {
      error = 'خطأ في تحميل السلة: $e';
      _fetchedCartItems = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void removeAt(int index) {
    _fetchedCartItems.removeAt(index);
    notifyListeners();
  }

  Future<bool> addToCartToServer(Map<String, dynamic> part) async {
    final url = Uri.parse('${AppSettings.serverurl}/cart/addToCart');
    print(part);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userid,
          'partId': part['id'],
          "coordinates": [44.1910, 15.3694]
        }),
      );

      if (response.statusCode == 201) {
        print(response.body);
        return false;
      } else {
        print('فشل في الإرسال: ${response.statusCode}, ${response.body}');
        return true;
      }
    } catch (e) {
      print('حدث خطأ أثناء الإرسال إلى السلة: $e');
      return false;
    }
  }
}
