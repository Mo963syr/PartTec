import 'package:flutter/material.dart';

import 'package:parttec/models/part.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Part> _favorites = [];

  List<Part> get favorites => List.unmodifiable(_favorites);

  void toggleFavorite(Part part) {
    final exists = _favorites.any((p) => p.id == part.id);
    if (exists) {
      _favorites.removeWhere((p) => p.id == part.id);
    } else {
      _favorites.add(part);
    }
    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favorites.any((p) => p.id == id);
  }
}
