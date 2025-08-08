import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            builder: (_) => PartDetailsPage(part: part),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: part.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              part.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
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
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          part.model,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        part.year != 0 ? part.year.toString() : '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
                  color: isFav ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  favProvider.toggleFavorite(part);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav
                            ? 'تمت الإزالة من المفضلة'
                            : 'تمت الإضافة إلى المفضلة',
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

/// A grid view for displaying a list of [Part] instances.
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: parts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        return PartCard(part: parts[index]);
      },
    );
  }
}

/// A tab view that filters the available parts by category and displays them
/// using [PartsGrid].
class CategoryTabView extends StatelessWidget {
  final String category;

  const CategoryTabView({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    final filtered = provider.availableParts
        .where((part) => part.category.toLowerCase() == category.toLowerCase())
        .toList();
    return RefreshIndicator(
      displacement: 200.0,
      strokeWidth: 3.0,
      onRefresh: () => provider.fetchAvailableParts(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: PartsGrid(parts: filtered),
      ),
    );
  }
}
