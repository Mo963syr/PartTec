import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_settings.dart';

class OrderProvider with ChangeNotifier {
  String userId = "687ff5a6bf0de81878ed94f5";
  bool isLoading = false;
  String? error;
  Map<String, dynamic>? orderResponse;

  Future<void> sendOrder( List<double> coordinates) async {
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
}
