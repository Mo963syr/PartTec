import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/app_settings.dart';
import '../utils/session_store.dart';

class DeliveryOrdersProvider with ChangeNotifier {
  String? _driverId;

  bool isLoading = false;

  String? error;

  final List<Map<String, dynamic>> _orders = [];

  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);

  Future<String?> _getDriverId() async {
    _driverId ??= await SessionStore.userId();
    return _driverId;
  }

  Future<void> fetchOrders() async {
    final did = await _getDriverId();
    if (did == null || did.isEmpty) {
      error = 'لم يتم العثور على معرف الموظف';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    final uri =
        Uri.parse('${AppSettings.serverurl}/order/getOrderForDriver/$did');

    try {
      final res = await http.get(uri);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        final data = (body['orders'] as List?) ?? [];
        _orders
          ..clear()
          ..addAll(
              data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)));
      } else {
        error =
            (body is Map ? body['message'] : null) ?? 'فشل تحميل طلبات التوصيل';
        _orders.clear();
      }
    } catch (e) {
      error = 'حدث خطأ أثناء تحميل الطلبات: $e';
      _orders.clear();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateStatus(
    String orderId,
    String newStatus, {
    double? deliveryPrice,
    String? customerId,
    String? sellerId,
    BuildContext? context,
  }) async {
    final uri =
        Uri.parse('${AppSettings.serverurl}/order/updateOrderStatus/$orderId');

    final Map<String, dynamic> body = {'status': newStatus};
    if (deliveryPrice != null && customerId != null && sellerId != null) {
      body['deliveryPrice'] = deliveryPrice;
      body['customerId'] = customerId;
      body['sellerId'] = sellerId;
    }

    try {
      final res = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data is Map && data['success'] == true) {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'تم تحديث حالة الطلب')),
          );
        }
        await fetchOrders();
      } else {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text((data is Map ? data['message'] : null) ??
                    'فشل تحديث الطلب')),
          );
        }
      }
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تحديث الطلب: $e')),
        );
      }
    }
  }
}
