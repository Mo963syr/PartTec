import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_settings.dart';

class SellerReviewsPage extends StatefulWidget {
  final String sellerId;
  const SellerReviewsPage({super.key, required this.sellerId});

  @override
  State<SellerReviewsPage> createState() => _SellerReviewsPageState();
}

class _SellerReviewsPageState extends State<SellerReviewsPage> {
  bool loading = false;
  List<dynamic> items = [];

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final res = await http.get(Uri.parse(
          '${AppSettings.serverurl}/reviews/seller/${widget.sellerId}'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        items = data['reviews'] as List;
      } else {
        items = [];
      }
    } catch (_) {
      items = [];
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تقييمات البائع')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('لا توجد تقييمات بعد'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final r = items[i];
                    final rating = (r['rating'] ?? 0).toInt();
                    final part = r['part'] ?? {};
                    final user = r['user'] ?? {};
                    return Card(
                      child: ListTile(
                        leading: part['imageUrl'] != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(part['imageUrl']))
                            : const CircleAvatar(child: Icon(Icons.image)),
                        title: Text(part['name'] ?? 'قطعة'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(
                                  5,
                                  (k) => Icon(
                                        k < rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 16,
                                        color: Colors.amber,
                                      )),
                            ),
                            if ((r['comment'] ?? '').toString().isNotEmpty)
                              Text(r['comment']),
                            Text('بواسطة: ${user['name'] ?? 'مستخدم'}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
