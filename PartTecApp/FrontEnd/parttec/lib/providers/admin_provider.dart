import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/app_settings.dart';

class AdminProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, List<Map<String, dynamic>>> _usersByRole = {
    'mechanic': [],
    'delivery': [],
    'supplier': [],
  };
  Map<String, List<Map<String, dynamic>>> get usersByRole => _usersByRole;

  Map<String, dynamic> _analytics = {
    'totalSales': 0.0,
    'totalOrders': 0,
    'discountUsage': 0.0,
  };
  Map<String, dynamic> get analytics => _analytics;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse('${AppSettings.serverurl}/admin/users');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data is Map<String, dynamic>) {
          _usersByRole = {};
          data.forEach((role, users) {
            _usersByRole[role] = List<Map<String, dynamic>>.from(users);
          });
        }
      }
    } catch (_) {
      _usersByRole = {
        'mechanic': [
          {
            'id': 'M-01',
            'name': 'فني أحمد',
            'email': 'ahmed@example.com',
            'phone': '0955000000',
            'discount': 0.10,
            'active': true,
          },
        ],
        'delivery': [
          {
            'id': 'D-01',
            'name': 'موصل علي',
            'email': 'ali@example.com',
            'phone': '0955111111',
            'active': true,
          },
        ],
        'supplier': [
          {
            'id': 'S-01',
            'name': 'تاجر يوسف',
            'email': 'youssef@example.com',
            'phone': '0955222222',
            'active': true,
          },
        ],
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    double? discount,
  }) async {
    try {
      final uri = Uri.parse('${AppSettings.serverurl}/admin/users');
      final Map<String, dynamic> body = {
        'name': name,
        'email': email,
        'phoneNumber': phone,
        'password': password,
        'role': role,
      };
      if (discount != null) {
        body['discount'] = discount;
      }
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (res.statusCode == 201) {
        await fetchUsers();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> updateUser(
    String userId, {
    required String role,
    String? name,
    String? email,
    String? phone,
    double? discount,
    bool? active,
  }) async {
    try {
      final uri = Uri.parse('${AppSettings.serverurl}/admin/users/$userId');
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phoneNumber'] = phone;
      if (discount != null) body['discount'] = discount;
      if (active != null) body['active'] = active;
      final res = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        await fetchUsers();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final uri = Uri.parse('${AppSettings.serverurl}/admin/users/$userId');
      final res = await http.delete(uri);
      if (res.statusCode == 200) {
        await fetchUsers();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> fetchAnalytics() async {
    _isLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse('${AppSettings.serverurl}/admin/analytics');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data is Map<String, dynamic>) {
          _analytics = data;
        }
      }
    } catch (_) {
      _analytics = {
        'totalSales': 45000.0,
        'totalOrders': 320,
        'discountUsage': 0.18,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
