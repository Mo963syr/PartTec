import 'package:flutter/material.dart';
import 'package:parttec/providers/home_provider.dart';
import 'package:parttec/providers/favorites_provider.dart';
import 'package:provider/provider.dart';
import '../part_details_page.dart';

class PartsGrid extends StatelessWidget {
  final List<dynamic> parts;

  const PartsGrid({Key? key, required this.parts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (parts.isEmpty) {
      return Center(child: Text('لا توجد قطع في هذا القسم'));
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 10),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: parts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (ctx, i) {
        final p = parts[i];
        final favProvider = Provider.of<FavoritesProvider>(context);
        final isFav =
            p['_id'] != null ? favProvider.isFavorite(p['_id']) : false;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PartDetailsPage(part: p),
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: p['imageUrl'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  p['imageUrl'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : const Icon(Icons.image,
                                size: 50, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p['name'] ?? 'بدون اسم',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 15),
                          Text(
                            p['manufacturer'] ?? 'بدون ماركة',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            p['model'] ?? 'بدون موديل',
                            style:
                                TextStyle(fontSize: 13, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            p['year']?.toString() ?? 'بدون سنة',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// ✅ أيقونة المفضلة في الزاوية
                Positioned(
                  top: 6,
                  right: 6,
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      favProvider.toggleFavorite(p);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isFav
                              ? 'تمت الإزالة من المفضلة'
                              : 'تمت الإضافة إلى المفضلة'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CategoryTabView extends StatelessWidget {
  final String category;

  const CategoryTabView({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    final filtered = provider.availableParts.where((part) {
      final c = (part['category'] ?? '').toString().toLowerCase();
      return c == category.toLowerCase();
    }).toList();

    return RefreshIndicator(
      displacement: 200.0,
      strokeWidth: 3.0,
      onRefresh: () => provider.fetchAvailableParts(),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: PartsGrid(parts: filtered),
      ),
    );
  }
}
