import 'package:flutter/material.dart';
import '../providers/home_provider.dart';
import 'package:provider/provider.dart';

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
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: p['imageUrl'] != null
                      ? Image.network(p['imageUrl'],
                      fit: BoxFit.cover, width: double.infinity)
                      : Icon(Icons.image, size: 50, color: Colors.grey),
                ),
                SizedBox(height: 6),
                Text(p['name'] ?? 'بدون اسم',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis),
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