import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/app_settings.dart';
import '../utils/session_store.dart';

class UserProvider with ChangeNotifier {
  bool isSaving = false;
  String? error;

  Future<bool> updateUserLocation({
    required double lat,
    required double lng,
  }) async {
    isSaving = true;
    error = null;
    notifyListeners();

    try {
      final uid = await SessionStore.userId();
      if (uid == null || uid.isEmpty) {
        error = 'لم يتم العثور على userId. الرجاء تسجيل الدخول أولاً.';
        isSaving = false;
        notifyListeners();
        return false;
      }

      final _lat = double.parse(lat.toStringAsFixed(6));
      final _lng = double.parse(lng.toStringAsFixed(6));

      final url =
          Uri.parse('${AppSettings.serverurl}/user/updateUserLocation/$uid');

      final res = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lng': _lng,
          'lat': _lat,
        }),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        isSaving = false;
        notifyListeners();
        return true;
      } else {
        error = 'فشل حفظ الموقع: ${res.statusCode} ${res.body}';
      }
    } catch (e) {
      error = 'خطأ اتصال: $e';
    }

    isSaving = false;
    notifyListeners();
    return false;
  }
}
