import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_settings.dart';

class PurchasesProvider with ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<dynamic> purchases = [];

  Future<void> fetchPurchases() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final url = Uri.parse("${AppSettings.serverurl}/purchases");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        purchases = jsonDecode(res.body);
      } else {
        error = "فشل في جلب المشتريات";
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
