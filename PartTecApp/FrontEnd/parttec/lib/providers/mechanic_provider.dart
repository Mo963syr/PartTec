import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/app_settings.dart';

class MechanicProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double? _discountPercentage;
  double? get discountPercentage => _discountPercentage;

  List<Map<String, dynamic>> _currentOrders = [];
  List<Map<String, dynamic>> get currentOrders => _currentOrders;

  List<Map<String, dynamic>> _orderHistory = [];
  List<Map<String, dynamic>> get orderHistory => _orderHistory;

  Future<void> fetchDiscount() async {
    _isLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse('${AppSettings.serverurl}/mechanic/discount');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data is Map && data['discount'] != null) {
          _discountPercentage = double.tryParse(data['discount'].toString()) ??
              _discountPercentage;
        }
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCurrentOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse('${AppSettings.serverurl}/mechanic/orders');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data is List) {
          _currentOrders = data.cast<Map<String, dynamic>>();
        }
      }
    } catch (_) {
      _currentOrders = [
        {
          'id': 'MO-001',
          'status': 'قيد المعالجة',
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'MO-002',
          'status': 'مكتمل',
          'createdAt': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
        },
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse('${AppSettings.serverurl}/mechanic/orders/history');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data is List) {
          _orderHistory = data.cast<Map<String, dynamic>>();
        }
      }
    } catch (_) {
      _orderHistory = [
        {
          'id': 'HO-001',
          'total': 200.0,
          'discount': 0.15,
          'createdAt': DateTime.now()
              .subtract(const Duration(days: 10))
              .toIso8601String(),
        },
        {
          'id': 'HO-002',
          'total': 350.0,
          'discount': 0.10,
          'createdAt': DateTime.now()
              .subtract(const Duration(days: 20))
              .toIso8601String(),
        },
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
