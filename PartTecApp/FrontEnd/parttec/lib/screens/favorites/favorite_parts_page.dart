import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Widgets/parts_widgets.dart';
import '../../providers/favorites_provider.dart';

// استخدم alias
import 'package:parttec/widgets/parts_widgets.dart' as pw;

class FavoritePartsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites; // List<Part>

    return Scaffold(
      appBar: AppBar(title: Text('المفضلة')),
      body: pw.PartsGrid(parts: favorites), // لا تحتاج cast إذا هي List<Part>
    );
  }
}
