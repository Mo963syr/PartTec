import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/app_settings.dart';

class RecommendationsProvider extends ChangeNotifier {
  bool isLoading = false;
  String? lastError;

  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get orders => _orders;

  Future<bool> fetchMyRecommendationOrders({String? authToken}) async {
    isLoading = true;
    lastError = null;
    notifyListeners();

    final uri = Uri.parse('${AppSettings.serverurl}/order/my-specific-orders');

    try {
      final res = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      });

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final list = (decoded['orders'] as List?) ?? (decoded as List? ?? []);
        _orders = list.map((e) => Map<String, dynamic>.from(e)).toList();
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        lastError = 'فشل الجلب: ${res.statusCode} ${res.body}';
      }
    } catch (e) {
      lastError = 'خطأ اتصال: $e';
    }
    isLoading = false;
    notifyListeners();
    return false;
  }
}
