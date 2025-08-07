import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  void toggleFavorite(Map<String, dynamic> part) {
    final exists = _favorites.any((p) => p['_id'] == part['_id']);
    if (exists) {
      _favorites.removeWhere((p) => p['_id'] == part['_id']);
    } else {
      _favorites.add(part);
    }
    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favorites.any((p) => p['_id'] == id);
  }
}
