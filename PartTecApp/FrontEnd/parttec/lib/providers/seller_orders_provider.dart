import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parttec/setting.dart';
class SellerOrdersProvider with ChangeNotifier {
  final String sellerId;
  SellerOrdersProvider(this.sellerId);

  List<Map<String, dynamic>> _orders = [];
  double totalAmount = 0;
  bool isLoading = false;
  String? error;

  List<Map<String, dynamic>> get orders => _orders;

  Future<void> fetchOrders() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final url = Uri.parse('${AppSettings.serverurl}/cart/getCartItemsForSeller/$sellerId');

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['success']) {
        _orders = List<Map<String, dynamic>>.from(data['items']);
        totalAmount = data['totalAmount']?.toDouble() ?? 0;
      } else {
        error = data['message'];
        _orders = [];
      }
    } catch (e) {
      error = 'حدث خطأ في تحميل الطلبات: $e';
      _orders = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
