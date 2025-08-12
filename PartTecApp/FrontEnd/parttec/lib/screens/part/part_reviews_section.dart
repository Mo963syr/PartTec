import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reviews_provider.dart';
import '../../widgets/star_selector.dart';

class PartReviewsSection extends StatefulWidget {
  final String partId;
  final String userId; // المستخدِم الحالي
  const PartReviewsSection(
      {super.key, required this.partId, required this.userId});

  @override
  State<PartReviewsSection> createState() => _PartReviewsSectionState();
}

class _PartReviewsSectionState extends State<PartReviewsSection> {
  int _rating = 0;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final p = Provider.of<ReviewsProvider>(context, listen: false);
      p.fetchPartReviews(widget.partId);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<ReviewsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ملخص
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 6),
            Text('${p.averageRating.toStringAsFixed(1)} / 5'),
            const SizedBox(width: 8),
            Text('(${p.reviewsCount} تقييم)'),
          ],
        ),
        const SizedBox(height: 8),

        // إدخال تقييم
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أضف تقييمك:'),
                StarSelector(
                    value: _rating,
                    onChanged: (v) => setState(() => _rating = v)),
                TextField(
                  controller: _ctrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'اكتب تعليقًا (اختياري)...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: p.isLoading
                      ? null
                      : () async {
                          if (_rating == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('اختر عدد النجوم')),
                            );
                            return;
                          }
                          final ok = await p.upsertReview(
                            partId: widget.partId,
                            userId: widget.userId,
                            rating: _rating,
                            comment: _ctrl.text.trim(),
                          );
                          if (ok) {
                            _ctrl.clear();
                            setState(() => _rating = 0);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم حفظ تقييمك ✅')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('فشل حفظ التقييم ❌')),
                            );
                          }
                        },
                  icon: const Icon(Icons.send),
                  label: const Text('إرسال'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // قائمة التقييمات
        if (p.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (p.reviews.isEmpty)
          const Text('لا توجد تقييمات بعد.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: p.reviews.length,
            separatorBuilder: (_, __) => const Divider(height: 8),
            itemBuilder: (_, i) {
              final r = p.reviews[i];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Row(
                  children: [
                    Text(r.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(
                          5,
                          (k) => Icon(
                                k < r.rating ? Icons.star : Icons.star_border,
                                size: 16,
                                color: Colors.amber,
                              )),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (r.comment.isNotEmpty) Text(r.comment),
                    Text(
                      '${r.createdAt}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
