import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_settings.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class AddPartProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<bool> addPart(
      {required String name,
      required String manufacturer,
      required String model,
      required String year,
      required String fuelType,
      required String category,
      required String status,
      required String price,
      File? image,
      String? serialNumber,
      String? description,
      int quantity = 1}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final uri = Uri.parse('${AppSettings.serverurl}/part/add');
    final request = http.MultipartRequest('POST', uri);

    request.fields['name'] = name;
    request.fields['manufacturer'] = manufacturer;
    request.fields['model'] = model;
    if (year != null && year.isNotEmpty) {
      request.fields['year'] = year;
    }
    request.fields['fuelType'] = fuelType;
    request.fields['user'] = '68761cf7f92107b8288158c2';
    request.fields['category'] = category;

    request.fields['status'] = status;
    request.fields['price'] = price;
    request.fields['quantity'] = quantity.toString();
    if (serialNumber != null && serialNumber.isNotEmpty) {
      request.fields['serialNumber'] = serialNumber;
    }

    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path,
            contentType: MediaType('image', 'jpeg')),
      );
    }

    try {
      final response = await request.send();
      final responseStr = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        errorMessage = 'فشل الإضافة: $responseStr';
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
