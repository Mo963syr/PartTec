import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/parts_provider.dart';
import '../models/part.dart';
import '../providers/home_provider.dart';
import '../providers/favorites_provider.dart';
import '../screens/part/part_details_page.dart';

class PartCard extends StatelessWidget {
  final Part part;

  const PartCard({Key? key, required this.part}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoritesProvider>(context);
    final bool isFav = favProvider.isFavorite(part.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => PartRatingProvider()..fetchRating(part.id),
              child: PartDetailsPage(part: part),
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        (part.imageUrl != null && part.imageUrl.isNotEmpty)
                            ? part.imageUrl
                            : AppImages
                                .defaultPart, // 🔥 صورة افتراضية من AppTheme
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Image.network(
                          AppImages.defaultPart,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    part.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          part.manufacturer ?? '',
                          style: const TextStyle(
                              color: AppColors.textWeak, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          part.model,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.text),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        part.year != 0 ? part.year.toString() : '',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textWeak),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.error : AppColors.textWeak,
                ),
                onPressed: () async {
                  await favProvider.toggleFavorite(part);
                  final nowFav = favProvider.isFavorite(part.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        nowFav
                            ? 'تمت الإضافة إلى المفضلة'
                            : 'تمت الإزالة من المفضلة',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PartsGrid extends StatelessWidget {
  final List<Part> parts;

  const PartsGrid({Key? key, required this.parts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (parts.isEmpty) {
      return const Center(child: Text('لا توجد قطع في هذا القسم'));
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: parts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (ctx, index) => PartCard(part: parts[index]),
    );
  }
}

class CategoryTabView extends StatelessWidget {
  final String category;

  const CategoryTabView({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    final filtered = provider.availableParts
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();

    return RefreshIndicator(
      displacement: 200.0,
      strokeWidth: 3.0,
      onRefresh: () => provider.fetchAvailableParts(),
      child: PartsGrid(parts: filtered),
    );
  }
}
