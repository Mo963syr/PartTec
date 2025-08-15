import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_settings.dart';

class SellerOrdersProvider with ChangeNotifier {
  String sellerId;
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
      final raw = response.body;
      final data = jsonDecode(raw);

      if (response.statusCode == 200 && data is Map && data['success'] == true) {
        final items = (data['orders'] as List?) ?? [];
        _orders = items
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      } else {
        error = (data is Map ? data['message']?.toString() : null) ?? 'فشل تحميل الطلبات';
        _orders.clear();
        totalAmount = 0.0;
      }
    } catch (e) {
      error = 'حدث خطأ في تحميل الطلبات: $e';
      _orders.clear();
      totalAmount = 0.0;
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
      if (response.statusCode == 200 && data is Map && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'تم التحديث بنجاح')),
        );
        await fetchOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text((data is Map ? data['message'] : null) ?? 'فشل في التحديث')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء التحديث: $e')),
      );
    }
  }

  Map<String, List<Map<String, dynamic>>> get groupedOrdersByCustomer {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var order in _orders) {
      final customer = order['customer'] as Map?;
      final customerId = (customer?['_id'] ?? 'unknown').toString();
      grouped.putIfAbsent(customerId, () => []).add(order);
    }
    return grouped;
  }
}
