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
    String? year,
    required String fuelType,
    required String category,
    required String status,
    required String price,
    File? image,
    String? serialNumber,
    String? description,
    int quantity = 1,
  })
  async {
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


    request.fields['name'] = name;
    request.fields['manufacturer'] = manufacturer;
    request.fields['model'] = model;
    if (year != null && year.isNotEmpty) {
      request.fields['year'] = year;
    }
    request.fields['fuelType'] = fuelType;
    request.fields['category'] = category;
    request.fields['status'] = status;
    request.fields['price'] = price;
    request.fields['quantity'] = quantity.toString();


    request.fields['user'] = uid;

    if (serialNumber != null && serialNumber.isNotEmpty) {
      request.fields['serialNumber'] = serialNumber;
    }
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }


    if (image != null) {
      final subtype = image.path.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', subtype),
        ),
      );
    }

    try {
      final response = await request.send();
      final responseStr = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        errorMessage = 'فشل الإضافة (${response.statusCode}): $responseStr';
        return false;
      }
    } catch (e) {
      errorMessage = 'خطأ أثناء الإرسال: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
