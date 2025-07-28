import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parttec/setting.dart';

class CartProvider extends ChangeNotifier {
  String userid = '687ff5a6bf0de81878ed94f5';
  // فقط إرسال القطعة إلى السيرفر
  Future<bool> addToCartToServer(Map<String, dynamic> part) async {
    final url = Uri.parse(
        '${AppSettings.serverurl}/cart/addToCart'); // غيّر إلى رابط السيرفر الفعلي
    print(part);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userid,
          'partId': part['id'], // فقط إرسال id إذا كان هذا ما يتطلبه السيرفر
        }),
      );

      if (response.statusCode == 201) {
        print(response.body);
        return false;
      } else {
        print('فشل في الإرسال: ${response.statusCode}, ${response.body}');
        return true;
      }
    } catch (e) {
      print('حدث خطأ أثناء الإرسال إلى السلة: $e');
      return false;
    }
  }
}
