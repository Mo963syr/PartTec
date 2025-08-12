import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import 'package:parttec/widgets/parts_widgets.dart' as pw;

// مؤقتًا؛ بدّلها بـ AuthProvider().userId عندك
const String kDefaultUserId = "687ff5a6bf0de81878ed94f5";

class FavoritePartsPage extends StatefulWidget {
  const FavoritePartsPage({Key? key}) : super(key: key);

  @override
  State<FavoritePartsPage> createState() => _FavoritePartsPageState();
}

class _FavoritePartsPageState extends State<FavoritePartsPage> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture =
        context.read<FavoritesProvider>().fetchFavorites(kDefaultUserId);
  }

  Future<void> _refresh() {
    return context.read<FavoritesProvider>().fetchFavorites(kDefaultUserId);
  }

  @override
  Widget build(BuildContext context) {
    final favProv = context.watch<FavoritesProvider>(); // فيه .favorites

    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // أول تحميل
              return const Center(child: CircularProgressIndicator());
            }

            // بعد التحميل: اعرض القائمة
            if (favProv.favorites.isEmpty) {
              // لازم ListView/Scrollable ليشتغل السحب للتحديث
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('لا توجد عناصر مضافة إلى المفضلة بعد')),
                ],
              );
            }

            return pw.PartsGrid(parts: favProv.favorites);
          },
        ),
      ),
    );
  }
}
