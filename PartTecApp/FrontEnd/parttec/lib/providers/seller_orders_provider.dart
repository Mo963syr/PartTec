// provider/seller_orders_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parttec/setting.dart';

class SellerOrdersProvider with ChangeNotifier {
   String sellerId="68761cf7f92107b8288158c2";
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

    final url = Uri.parse('${AppSettings.serverurl}/order/getOrderForSellrer/$sellerId');

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

  Future<void> updateStatus(String orderId, String newStatus, BuildContext context) async {
    final url = Uri.parse('${AppSettings.serverurl}/order/updateOrderStatus/$orderId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        fetchOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'فشل في التحديث')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء التحديث: $e')),
      );
    }
  }

  Map<String, List<Map<String, dynamic>>> get groupedOrdersByCustomer {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in _orders) {
      final user = item['user'];
      final userId = user['_id'];
      if (!grouped.containsKey(userId)) {
        grouped[userId] = [];
      }
      grouped[userId]!.add(item);
    }
    return grouped;
  }
}
