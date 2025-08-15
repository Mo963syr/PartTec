import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../models/part.dart';
import 'part_reviews_section.dart';
import '../../utils/session_store.dart';

class PartDetailsPage extends StatelessWidget {
  final Part part;

  const PartDetailsPage({Key? key, required this.part}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = part.imageUrl;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                    ),
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                  )
                      : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 100, color: Colors.grey),
                  ),
                ),
                // زر رجوع
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Material(
                      color: Colors.black45,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3)),
                  ],
                ),
                child: ListView(
                  children: [
                    _buildDetailRow('اسم القطعة', part.name),
                    _buildDetailRow('الموديل', part.model),
                    _buildDetailRow('الماركة', part.manufacturer),
                    _buildDetailRow('سنة الصنع', part.year != 0 ? part.year.toString() : null),
                    _buildDetailRow('الرقم التسلسلي', part.serialNumber),
                    _buildDetailRow('نوع الوقود', part.fuelType),
                    _buildDetailRow('الحالة', part.status),
                    _buildDetailRow('السعر', '${part.price} \$'),
                    const SizedBox(height: 16),
                    const Text('الوصف:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(part.description ?? 'لا يوجد وصف', style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 20),
                    const Divider(),
                    const Text('تقييمات الزبائن',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // ↓↓↓ نجلب userId من SessionStore
                    FutureBuilder<String?>(
                      future: SessionStore.userId(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ));
                        }
                        final uid = snapshot.data;
                        if (uid == null || uid.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('⚠️ الرجاء تسجيل الدخول لعرض/إضافة التقييمات.'),
                          );
                        }
                        return PartReviewsSection(
                          partId: part.id,
                          userId: uid,
                        );
                      },
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -1))],
          ),
          child: ElevatedButton(
            onPressed: () async {
              final success = await context.read<CartProvider>().addToCartToServer(part);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'أُضيفت القطعة إلى السلة' : 'فشلت الإضافة إلى السلة'),
                  backgroundColor: success ? Colors.green : Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('إضافة إلى السلة', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value?.toString() ?? 'غير متوفر')),
        ],
      ),
    );
  }
}
