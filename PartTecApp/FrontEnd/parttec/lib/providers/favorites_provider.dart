import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/part.dart';
import '../utils/app_settings.dart'; // تأكد أن هذا يحتوي serverurl و userId

class FavoritesProvider extends ChangeNotifier {
  final List<Part> _favorites = [];

  List<Part> get favorites => List.unmodifiable(_favorites);

  Future<void> toggleFavorite(Part part, String userId) async {
    final exists = _favorites.any((p) => p.id == part.id);

    try {
      if (exists) {
        // 🗑 إزالة من المفضلة في الباك إند
        final response = await http.post(
          Uri.parse('${AppSettings.serverurl}/favorites/remove'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'partId': part.id,
          }),
        );

        if (response.statusCode == 200) {
          _favorites.removeWhere((p) => p.id == part.id);
          notifyListeners();
        } else {
          print('فشل حذف المفضلة: ${response.body}');
        }
      } else {
        // ➕ إضافة إلى المفضلة في الباك إند
        final response = await http.post(
          Uri.parse('${AppSettings.serverurl}/favorites/add'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'partId': part.id,
          }),
        );

        if (response.statusCode == 200) {
          _favorites.add(part);
          notifyListeners();
        } else {
          print('فشل إضافة المفضلة: ${response.body}');
        }
      }
    } catch (e) {
      print('خطأ أثناء تحديث المفضلة: $e');
    }
  }

  bool isFavorite(String id) {
    return _favorites.any((p) => p.id == id);
  }

  // 📌 تحميل المفضلة من الباك إند عند فتح التطبيق
  Future<void> fetchFavorites(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppSettings.serverurl}/favorites/view/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _favorites.clear();
        _favorites.addAll(
          (data['favorites'] as List)
              .map((item) => Part.fromJson(item))
              .toList(),
        );
        notifyListeners();
      } else {
        print('فشل تحميل المفضلة: ${response.body}');
      }
    } catch (e) {
      print('خطأ أثناء تحميل المفضلة: $e');
    }
  }
}
