import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_settings.dart';
import '../utils/session_store.dart';

class SellerOrdersProvider with ChangeNotifier {
  String? _sellerId;

  List<Map<String, dynamic>> _orders = [];
  double totalAmount = 0;
  bool isLoading = false;
  String? error;

  List<Map<String, dynamic>> get orders => _orders;

  Future<void> fetchOrders() async {
    _sellerId ??= await SessionStore.userId();
    print('Seller ID: $_sellerId');
    if (_sellerId == null || _sellerId!.isEmpty) {
      error = 'لم يتم العثور على معرف البائع';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    final url = Uri.parse(
        '${AppSettings.serverurl}/order/getOrderForSellrer/$_sellerId');

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data is Map &&
          data['success'] == true) {
        final items = (data['orders'] as List?) ?? [];
        _orders = items
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      } else {
        error = (data is Map ? data['message']?.toString() : null) ??
            'فشل تحميل الطلبات';
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

  Future<bool> updateStatus(String orderId, String newStatus) async {
    final url =
        Uri.parse('${AppSettings.serverurl}/order/updateOrderStatus/$orderId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          data is Map &&
          data['success'] == true) {
        await fetchOrders(); // إعادة جلب الطلبات
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
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
