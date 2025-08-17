import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/app_settings.dart';

class DeliveryStaffProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, List<Map<String, dynamic>>> _ordersByStatus = {
    'تجهيز': [],
    'قيد التوصيل': [],
    'تم التسليم': [],
  };
  Map<String, List<Map<String, dynamic>>> get ordersByStatus => _ordersByStatus;

  Future<void> fetchDeliveryOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse('${AppSettings.serverurl}/delivery/orders');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data is List) {
          _ordersByStatus = {
            'تجهيز': [],
            'قيد التوصيل': [],
            'تم التسليم': [],
          };
          for (final item in data) {
            final map = Map<String, dynamic>.from(item);
            final status = map['status']?.toString() ?? 'تجهيز';
            _ordersByStatus.putIfAbsent(status, () => []).add(map);
          }
        }
      }
    } catch (_) {
      _ordersByStatus = {
        'تجهيز': [
          {
            'id': 'DO-100',
            'customerName': 'خالد الأحمد',
            'status': 'تجهيز',
            'address': 'دمشق، المرجة',
            'lat': 33.5150,
            'lng': 36.2920,
          },
        ],
        'قيد التوصيل': [
          {
            'id': 'DO-101',
            'customerName': 'عمر سعيد',
            'status': 'قيد التوصيل',
            'address': 'دمشق، المزة',
            'lat': 33.5010,
            'lng': 36.2840,
          },
        ],
        'تم التسليم': [
          {
            'id': 'DO-102',
            'customerName': 'سارة نصوح',
            'status': 'تم التسليم',
            'address': 'دمشق، برزة',
            'lat': 33.5400,
            'lng': 36.2790,
          },
        ],
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmPickup(String orderId) async {
    try {
      final uri =
          Uri.parse('${AppSettings.serverurl}/delivery/orders/$orderId/pickup');
      final res = await http.post(uri);
      if (res.statusCode == 200) {
        _moveOrderToStatus(orderId, 'قيد التوصيل');
        return true;
      }
    } catch (_) {}

    _moveOrderToStatus(orderId, 'قيد التوصيل');
    return true;
  }

  Future<bool> confirmDelivery(String orderId) async {
    try {
      final uri = Uri.parse(
          '${AppSettings.serverurl}/delivery/orders/$orderId/deliver');
      final res = await http.post(uri);
      if (res.statusCode == 200) {
        _moveOrderToStatus(orderId, 'تم التسليم');
        return true;
      }
    } catch (_) {}
    _moveOrderToStatus(orderId, 'تم التسليم');
    return true;
  }

  void _moveOrderToStatus(String orderId, String newStatus) {
    String? oldStatus;
    Map<String, dynamic>? order;
    _ordersByStatus.forEach((status, list) {
      for (final item in list) {
        if (item['id'] == orderId) {
          oldStatus = status;
          order = item;
          break;
        }
      }
    });
    if (oldStatus != null && order != null) {
      _ordersByStatus[oldStatus!]!.remove(order);
      order!['status'] = newStatus;
      _ordersByStatus.putIfAbsent(newStatus, () => []).add(order!);
      notifyListeners();
    }
  }
}
