import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../setting.dart';

class PartsProvider extends ChangeNotifier {
  List<dynamic> _parts = [];
  bool _isLoading = false;

  List<dynamic> get parts => _parts;
  bool get isLoading => _isLoading;

  Future<void> fetchParts() async {
    _isLoading = true;
    notifyListeners();

    final uri = Uri.parse('${AppSettings.serverurl}/part/viewPrivateParts');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        _parts = decoded['parts'] ?? [];
      } else {
        throw Exception('فشل تحميل البيانات');
      }
    } catch (e) {
      print('❌ خطأ أثناء تحميل القطع: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deletePart(String id) async {
    final uri = Uri.parse('${AppSettings.serverurl}/part/delete/$id');
    try {
      final response = await http.delete(uri);
      if (response.statusCode == 200) {
        _parts.removeWhere((part) => part['_id'] == id);
        notifyListeners();
      } else {
        throw Exception('فشل الحذف');
      }
    } catch (e) {
      print('❌ خطأ أثناء حذف القطعة: $e');
    }
  }
}
