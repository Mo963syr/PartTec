// providers/order_provider.dart
import 'dart:convert';
import 'dart:io'; // ← مهم
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_settings.dart';

class OrderProvider with ChangeNotifier {


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
          'userId': AppSettings.user,
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

  // ⬅︎ أضفنا imageFile وأرسلنا Multipart
  Future<bool> createSpecificOrder({
    required String brandCode,
    required String partName,
    required String carModel,
    required String carYear,
    required String serialNumber,
    File? image,            // ← جديد
    String? notes,
    String? authToken,
  }) async {
    _isSubmitting = true;
    _lastOrderId = null;
    _lastError = null;
    notifyListeners();

    final uri = Uri.parse('${AppSettings.serverurl}/order/addspicificorder');

    try {
      final req = http.MultipartRequest('POST', uri);

      // هيدرات (لا تضع Content-Type يدوياً مع Multipart)
      if (authToken != null && authToken.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $authToken';
      }

      // الحقول النصية
      req.fields.addAll({
        'manufacturer': brandCode.toLowerCase(),
        'name': partName,
        'user': AppSettings.user,
        'model': carModel,
        'year': carYear,
        'serialNumber': serialNumber,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      });

      // ملف الصورة تحت الإسم "image"
      if (image != null) {
        req.files.add(
          await http.MultipartFile.fromPath('image', image.path),
          // لو بدك تحدد نوع الملف:
          // contentType: MediaType('image', 'jpeg'),
        );
      }

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = json.decode(res.body);

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
