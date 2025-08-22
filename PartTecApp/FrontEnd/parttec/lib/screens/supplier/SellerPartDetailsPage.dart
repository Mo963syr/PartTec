import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/part.dart';
import '../../utils/app_settings.dart';
import '../part/part_reviews_section.dart';

class SellerPartDetailsPage extends StatelessWidget {
  final Part part;
  const SellerPartDetailsPage({super.key, required this.part});

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
    final imageUrl = part.imageUrl;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(part.name),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            imageUrl.isNotEmpty
                ? Image.network(imageUrl, height: 220, fit: BoxFit.cover)
                : Container(
              height: 220,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 100),
            ),
            const SizedBox(height: 16),
            Text(part.name,
                style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("السعر: \$${part.price}",
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                    fontWeight: FontWeight.bold)),
            const Divider(),
            Text("الموديل: ${part.model ?? ''}"),
            Text("الماركة: ${part.manufacturer ?? ''}"),
            Text("السنة: ${part.year}"),
            Text("الفئة: ${part.category ?? ''}"),
            Text("الحالة: ${part.status ?? ''}"),
            const SizedBox(height: 12),
            const Text("الوصف:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(part.description ?? "لا يوجد وصف"),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text("التعليقات",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            PartReviewsSection(partId: part.id),
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
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("تأكيد الحذف"),
                        content: const Text(
                            "هل أنت متأكد أنك تريد حذف هذه القطعة؟"),
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
