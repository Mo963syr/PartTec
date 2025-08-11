import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_settings.dart';

class OrderProvider with ChangeNotifier {
  String userId = "687ff5a6bf0de81878ed94f5";

  bool isLoading = false;
  String? error;
  Map<String, dynamic>? orderResponse;

  bool _isSubmitting = false;
  String? _lastOrderId;
  String? _lastError;

  bool get isSubmitting => _isSubmitting;
  String? get lastOrderId => _lastOrderId;
  String? get lastError => _lastError;

  Future<void> sendOrder(List<double> coordinates) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final url = Uri.parse('${AppSettings.serverurl}/order/create');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'coordinates': coordinates,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        orderResponse = data;
      } else {
        error = data['message'] ?? 'حدث خطأ أثناء إرسال الطلب';
      }
    } catch (e) {
      error = 'حدث خطأ: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> createSpecificOrder({
    required String brandCode,
    required String partName,
    required String carModel,
    required String carYear,
    String? notes,
    String? authToken,
  }) async {
    _isSubmitting = true;
    _lastOrderId = null;
    _lastError = null;
    notifyListeners();

    final uri = Uri.parse('${AppSettings.serverurl}/order/addspicificorder');

    final payload = {
      'brand': brandCode,
      'partName': partName,
      'model': carModel,
      'year': carYear,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (authToken != null && authToken.isNotEmpty)
        'Authorization': 'Bearer $authToken',
    };

    try {
      final res =
          await http.post(uri, headers: headers, body: json.encode(payload));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = json.decode(res.body);

        // حاول استخراج الـ id بأكثر من احتمال
        _lastOrderId = decoded['order']?['_id']?.toString() ??
            decoded['orderId']?.toString() ??
            decoded['_id']?.toString() ??
            decoded['id']?.toString();

        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        _lastError = 'فشل الإرسال: ${res.statusCode} ${res.body}';
      }
    } catch (e) {
      _lastError = 'خطأ اتصال: $e';
    }

    _isSubmitting = false;
    notifyListeners();
    return false;
  }
}
