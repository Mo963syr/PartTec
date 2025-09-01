import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_settings.dart';

class PurchasesProvider with ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<Map<String, dynamic>> purchases = []; // ✅ نوع مضبوط

  Future<void> fetchPurchases(String userId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await http.get(
        Uri.parse(
            '${AppSettings.serverurl}/order/viewspicificordercompleted/$userId'),
      );

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final decoded = json.decode(res.body);

        if (decoded is List) {
          purchases = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (decoded is Map && decoded['orders'] is List) {
          purchases = (decoded['orders'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        } else {
          purchases = [];
        }
      } else {
        error = "فشل تحميل المشتريات (${res.statusCode})";
      }
    } catch (e) {
      error = "خطأ أثناء الجلب: $e";
    }

    isLoading = false;
    notifyListeners();
  }
}
