import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../utils/app_settings.dart';
import '../utils/session_store.dart';

class AddPartProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<bool> addPart({
    required String name,
    required String manufacturer,
    required String model,
    required String year,
    required String category,
    required String status,
    required String price,
    File? image,
    String? serialNumber,
    String? description,
    int count = 1, // 👈 مطابق مع schema
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final uid = await SessionStore.userId();
    if (uid == null || uid.isEmpty) {
      errorMessage = 'لم يتم العثور على userId. الرجاء تسجيل الدخول أولاً.';
      isLoading = false;
      notifyListeners();
      return false;
    }

    final uri = Uri.parse('${AppSettings.serverurl}/part/add');
    final request = http.MultipartRequest('POST', uri);

    // 📝 الحقول الأساسية
    request.fields['name'] = name;
    request.fields['manufacturer'] = manufacturer;
    request.fields['model'] = model;
    request.fields['year'] = year; // 👈 لازم يوصله كـ String بس السيرفر يحوله Number
    request.fields['category'] = category;
    request.fields['status'] = status;
    request.fields['price'] = price;
    request.fields['count'] = count.toString(); // 👈 مطابق للـ schema
    request.fields['user'] = uid; // 👈 ObjectId

    // 📝 الحقول الاختيارية
    if (serialNumber != null && serialNumber.isNotEmpty) {
      request.fields['serialNumber'] = serialNumber;
    }
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }

    // 🖼️ رفع الصورة إذا موجودة
    if (image != null) {
      final subtype =
      image.path.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // 👈 لازم يطابق اسم الحقل بالسيرفر (multer/cloudinary)
          image.path,
          contentType: MediaType('image', subtype),
        ),
      );
    }

    try {
      final response = await request.send();
      final responseStr = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ تم الإرسال بنجاح: $responseStr');
        return true;
      } else {
        errorMessage = 'فشل الإضافة (${response.statusCode}): $responseStr';
        debugPrint('❌ $errorMessage');
        return false;
      }
    } catch (e) {
      errorMessage = 'خطأ أثناء الإرسال: $e';
      debugPrint(errorMessage);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
