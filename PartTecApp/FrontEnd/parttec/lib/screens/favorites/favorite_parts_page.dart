import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/parts_widgets.dart';

class FavoritePartsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      appBar: AppBar(title: Text('المفضلة')),
      body: PartsGrid(parts: favorites),
    );
  }
}
