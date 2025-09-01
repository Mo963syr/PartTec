import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parttec/screens/part/part_reviews_section.dart';
import 'package:provider/provider.dart';

import '../../models/part.dart';
import '../../providers/parts_provider.dart';
import '../../utils/app_settings.dart';
import '../../utils/session_store.dart';
import '../../theme/app_theme.dart';

class SellerPartDetailsPage extends StatefulWidget {
  final Part part;
  const SellerPartDetailsPage({super.key, required this.part});

  @override
  State<SellerPartDetailsPage> createState() => _SellerPartDetailsPageState();
}

class _SellerPartDetailsPageState extends State<SellerPartDetailsPage> {
  Future<bool> _deletePart(BuildContext context, String id) async {
    try {
      final uri = Uri.parse('${AppSettings.serverurl}/part/delete/$id');
      final res = await http.delete(uri);
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم حذف القطعة ✅")),
        );
        Navigator.pop(context, true);
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل الحذف: ${res.body}")),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ أثناء الحذف: $e")),
      );
      return false;
    }
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final part = widget.part;
    final nameC = TextEditingController(text: part.name);
    final modelC = TextEditingController(text: part.model ?? '');
    final yearC = TextEditingController(text: part.year.toString());
    final statusC = TextEditingController(text: part.status ?? '');
    final priceC = TextEditingController(text: part.price.toString());
    final categoryC = TextEditingController(text: part.category ?? '');
    final descriptionC = TextEditingController(text: part.description ?? '');

    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) => AlertDialog(
            title: const Text('تعديل القطعة'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameC,
                      decoration: const InputDecoration(labelText: 'الاسم'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'أدخل الاسم' : null,
                    ),
                    TextFormField(
                      controller: modelC,
                      decoration: const InputDecoration(labelText: 'الموديل'),
                    ),
                    TextFormField(
                      controller: yearC,
                      decoration: const InputDecoration(labelText: 'السنة'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: statusC,
                      decoration: const InputDecoration(labelText: 'الحالة'),
                    ),
                    TextFormField(
                      controller: priceC,
                      decoration: const InputDecoration(labelText: 'السعر'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: categoryC,
                      decoration: const InputDecoration(labelText: 'التصنيف'),
                    ),
                    TextFormField(
                      controller: descriptionC,
                      decoration:
                          const InputDecoration(labelText: 'الوصف (اختياري)'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: saving
                    ? const Text("جارٍ الحفظ...")
                    : const Text("حفظ التعديلات"),
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setSt(() => saving = true);

                        final uri = Uri.parse(
                            '${AppSettings.serverurl}/part/update/${part.id}');
                        final payload = {
                          'name': nameC.text.trim(),
                          'model': modelC.text.trim(),
                          'year': yearC.text.trim(),
                          'status': statusC.text.trim(),
                          'price': priceC.text.trim(),
                          'category': categoryC.text.trim(),
                          'description': descriptionC.text.trim(),
                        };

                        final res = await http.put(
                          uri,
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode(payload),
                        );

                        setSt(() => saving = false);

                        if (res.statusCode == 200) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("تم تعديل القطعة ✅")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("فشل التعديل: ${res.body}")),
                          );
                        }
                      },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final part = widget.part;
    final imageUrl = part.imageUrl;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(part.name),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpaces.md),
          children: [
            // صورة المنتج داخل Card بحواف دائرية
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.chipBorder,
                        child: const Center(
                          child:
                              Icon(Icons.image, size: 64, color: Colors.white),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSpaces.md),

            // الاسم والسعر
            Card(
              elevation: 0,
              color: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.chipBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpaces.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "السعر: \$${part.price}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.success,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpaces.md),

            // معلومات أساسية
            Card(
              elevation: 0,
              color: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.chipBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpaces.md),
                child: Column(
                  children: [
                    _InfoRow(label: "الموديل", value: part.model ?? ''),
                    _InfoRow(label: "الماركة", value: part.manufacturer ?? ''),
                    _InfoRow(label: "السنة", value: part.year.toString()),
                    _InfoRow(label: "الفئة", value: part.category ?? ''),
                    _InfoRow(label: "الحالة", value: part.status ?? ''),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpaces.md),

            // الوصف
            Card(
              elevation: 0,
              color: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.chipBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpaces.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("الوصف",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                )),
                    const SizedBox(height: 6),
                    Text(
                      part.description ?? "لا يوجد وصف",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textWeak),
                    ),
                  ],
                ),
              ),
            ),

            // ⭐ التقييمات
            const SizedBox(height: AppSpaces.lg),
            Text("التقييمات",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    )),
            const SizedBox(height: 10),
            _RatingsSection(partId: part.id),
            const SizedBox(height: AppSpaces.md),
            _PartStarRating(partId: part.id),
            const SizedBox(height: AppSpaces.md),
            Text("تقييمات الزبائن",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    )),
            const SizedBox(height: 8),
            _ReviewsGate(partId: part.id),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("تعديل"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _showEditDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text("حذف"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("تأكيد الحذف"),
                        content:
                            const Text("هل أنت متأكد أنك تريد حذف هذه القطعة؟"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("إلغاء")),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("حذف")),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _deletePart(context, part.id);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// صف معلومة موحّد
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpaces.xs),
      child: Row(
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.start,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textWeak),
            ),
          ),
        ],
      ),
    );
  }
}

/// ⭐ قسم تحميل وعرض متوسط التقييمات
class _RatingsSection extends StatefulWidget {
  final String partId;
  const _RatingsSection({Key? key, required this.partId}) : super(key: key);

  @override
  State<_RatingsSection> createState() => _RatingsSectionState();
}

class _RatingsSectionState extends State<_RatingsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartRatingProvider>().fetchRating(widget.partId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PartRatingProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (prov.ratingsCount == 0) {
          return const Text("لا توجد تقييمات بعد",
              style: TextStyle(fontWeight: FontWeight.w600));
        }
        return Row(
          children: [
            Row(
              children: List.generate(5, (i) {
                final filled = i < prov.averageRating.round();
                return Icon(
                  filled ? Icons.star : Icons.star_border,
                  size: 20,
                  color: Colors.amber, // نُبقي لون النجمة ذهبيًا
                );
              }),
            ),
            const SizedBox(width: 6),
            Text(
              prov.averageRating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(width: 6),
            Text("(${prov.ratingsCount} تقييم)",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textWeak)),
          ],
        );
      },
    );
  }
}

class _ReviewsGate extends StatefulWidget {
  final String partId;
  const _ReviewsGate({Key? key, required this.partId}) : super(key: key);

  @override
  State<_ReviewsGate> createState() => _ReviewsGateState();
}

class _ReviewsGateState extends State<_ReviewsGate>
    with AutomaticKeepAliveClientMixin {
  late final Future<String?> _uidFuture;

  @override
  void initState() {
    super.initState();
    _uidFuture = SessionStore.userId();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<String?>(
      future: _uidFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final uid = snapshot.data;
        if (uid == null || uid.isEmpty) {
          return const Text("⚠️ الرجاء تسجيل الدخول لعرض/إضافة التقييمات.");
        }
        return PartReviewsSection(partId: widget.partId);
      },
    );
  }
}

class _PartStarRating extends StatefulWidget {
  final String partId;
  const _PartStarRating({Key? key, required this.partId}) : super(key: key);

  @override
  State<_PartStarRating> createState() => _PartStarRatingState();
}

class _PartStarRatingState extends State<_PartStarRating> {
  int _rating = 0;
  bool _submitting = false;
  String? _uid;

  @override
  void initState() {
    super.initState();
    SessionStore.userId().then((id) {
      if (mounted) setState(() => _uid = id);
    });
  }

  Future<void> _submit() async {
    if (_uid == null || _uid!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تسجيل الدخول لإرسال التقييم')),
      );
      return;
    }
    if (_rating < 1 || _rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر تقييمًا من 1 إلى 5')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final url =
          Uri.parse('${AppSettings.serverurl}/part/ratePart/${widget.partId}');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': _uid, 'rating': _rating}),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال تقييمك بنجاح')),
        );
      } else {
        final msg = _extractError(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg ?? 'فشل إرسال التقييم')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر الاتصال بالخادم')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _extractError(String body) {
    try {
      final obj = jsonDecode(body);
      if (obj is Map && obj['message'] is String) return obj['message'];
      if (obj is Map && obj['error'] is String) return obj['error'];
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}
