import 'package:flutter/material.dart';
import '../../utils/app_settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddedPartsPage extends StatefulWidget {
  const AddedPartsPage({super.key});

  @override
  State<AddedPartsPage> createState() => _AddedPartsPageState();
}

class _AddedPartsPageState extends State<AddedPartsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // تصنيفات ثابتة (لا نعيد إنشاء TabController لذلك لن يظهر خطأ الـ Ticker)
  final Map<String, List<dynamic>> categorizedParts = {
    'محرك': [],
    'فرامل': [],
    'هيكل': [],
    'كهرباء': [],
    'إطارات': [],
    'نظام التعليق': [],
  };

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: categorizedParts.length, vsync: this);
    fetchParts();
  }

  Future<void> fetchParts() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          '${AppSettings.serverurl}/part/viewsellerParts/68761cf7f92107b8288158c2',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> parts = data['parts'] ?? [];

        // تفريغ وإعادة التصنيف
        for (var key in categorizedParts.keys) {
          categorizedParts[key] = [];
        }
        for (var part in parts) {
          final category = (part['category'] ?? '').toString();
          if (categorizedParts.containsKey(category)) {
            categorizedParts[category]!.add(part);
          }
        }
      } else {
        debugPrint('فشل في تحميل القطع: ${response.body}');
      }
    } catch (e) {
      debugPrint('حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _extractId(Map<String, dynamic> part) {
    // وفقًا لهيكلة الـ API: جرّب '_id' ثم 'id'
    return (part['_id'] ?? part['id'] ?? '').toString();
  }

  Future<bool> _deletePart(String id) async {
    try {
      final uri = Uri.parse('${AppSettings.serverurl}/part/delete/$id');
      final res = await http.delete(uri);
      if (res.statusCode == 200) return true;
      debugPrint('فشل الحذف: ${res.statusCode} ${res.body}');
      return false;
    } catch (e) {
      debugPrint('❌ خطأ أثناء الحذف: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> _updatePart({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final uri = Uri.parse('${AppSettings.serverurl}/part/update/$id');
      final res = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        // بعض الـ APIs ترجع {'part': {...}}
        return (decoded is Map && decoded['part'] is Map)
            ? Map<String, dynamic>.from(decoded['part'])
            : (decoded is Map ? Map<String, dynamic>.from(decoded) : null);
      }
      debugPrint('فشل التعديل: ${res.statusCode} ${res.body}');
      return null;
    } catch (e) {
      debugPrint('❌ خطأ أثناء التعديل: $e');
      return null;
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> part) async {
    final nameC = TextEditingController(text: (part['name'] ?? '').toString());
    final modelC =
        TextEditingController(text: (part['model'] ?? '').toString());
    final yearC = TextEditingController(text: (part['year'] ?? '').toString());
    final statusC =
        TextEditingController(text: (part['status'] ?? '').toString());
    final priceC =
        TextEditingController(text: (part['price'] ?? '').toString());
    final categoryC =
        TextEditingController(text: (part['category'] ?? '').toString());
    final descriptionC =
        TextEditingController(text: (part['description'] ?? '').toString());

    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showDialog(
      context: context,
      barrierDismissible: !saving,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
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
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'أدخل الاسم'
                            : null,
                      ),
                      TextFormField(
                        controller: modelC,
                        decoration: const InputDecoration(labelText: 'الموديل'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'أدخل الموديل'
                            : null,
                      ),
                      TextFormField(
                        controller: yearC,
                        decoration: const InputDecoration(labelText: 'السنة'),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'أدخل السنة'
                            : null,
                      ),
                      TextFormField(
                        controller: statusC,
                        decoration: const InputDecoration(labelText: 'الحالة'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'أدخل الحالة'
                            : null,
                      ),
                      TextFormField(
                        controller: priceC,
                        decoration: const InputDecoration(labelText: 'السعر'),
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        controller: categoryC,
                        decoration: const InputDecoration(labelText: 'التصنيف'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'أدخل التصنيف'
                            : null,
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
                  label:
                      saving ? const Text('جارٍ الحفظ...') : const Text('حفظ'),
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setSt(() => saving = true);

                          final id = _extractId(part);
                          final payload = {
                            'name': nameC.text.trim(),
                            'model': modelC.text.trim(),
                            'year': yearC.text.trim(),
                            'status': statusC.text.trim(),
                            'price': priceC.text.trim(),
                            'category': categoryC.text.trim(),
                            if (descriptionC.text.trim().isNotEmpty)
                              'description': descriptionC.text.trim(),
                          };

                          final updated =
                              await _updatePart(id: id, data: payload);
                          setSt(() => saving = false);

                          if (updated != null) {
                            // حدّث العنصر داخل التصنيف الحالي
                            final cat = (updated['category'] ?? categoryC.text)
                                .toString();
                            // احذف من جميع التصنيفات ثم أضِف للتصنيف المناسب (في حال تغيّر التصنيف)
                            for (final key in categorizedParts.keys) {
                              categorizedParts[key]!.removeWhere(
                                (x) =>
                                    _extractId(Map<String, dynamic>.from(x)) ==
                                    id,
                              );
                            }
                            if (categorizedParts.containsKey(cat)) {
                              categorizedParts[cat]!.insert(0, updated);
                            }
                            if (mounted) {
                              setState(() {});
                              Navigator.pop(ctx); // أغلق نافذة التعديل
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('تم حفظ التعديلات')),
                              );
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('فشل التعديل')),
                              );
                            }
                          }
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> part) async {
    final id = _extractId(part);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل تريد حذف هذه القطعة؟'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(_, false),
                child: const Text('إلغاء')),
            TextButton(
                onPressed: () => Navigator.pop(_, true),
                child: const Text('حذف')),
          ],
        ),
      ),
    );

    if (ok == true) {
      final done = await _deletePart(id);
      if (done) {
        // احذف من جميع التصنيفات
        for (final key in categorizedParts.keys) {
          categorizedParts[key]!.removeWhere(
            (x) => _extractId(Map<String, dynamic>.from(x)) == id,
          );
        }
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف القطعة')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل الحذف')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('القطع المضافة'),
          bottom: TabBar(
            isScrollable: true,
            controller: _tabController,
            tabs: categorizedParts.keys.map((e) => Tab(text: e)).toList(),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: fetchParts,
                child: TabBarView(
                  controller: _tabController,
                  children: categorizedParts.keys.map((category) {
                    final parts = categorizedParts[category]!;
                    return parts.isEmpty
                        ? const ListTile(
                            title: Center(
                                child: Text('لا توجد قطع في هذا التصنيف')),
                          )
                        : ListView.builder(
                            itemCount: parts.length,
                            itemBuilder: (context, index) {
                              final Map<String, dynamic> part =
                                  Map<String, dynamic>.from(parts[index]);

                              return Card(
                                margin: const EdgeInsets.all(12),
                                child: ListTile(
                                  leading: (part['imageUrl'] != null &&
                                          part['imageUrl']
                                              .toString()
                                              .isNotEmpty)
                                      ? Image.network(
                                          part['imageUrl'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image, size: 50),
                                  title: Text(
                                      part['name']?.toString() ?? 'بدون اسم'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('الموديل: ${part['model'] ?? ''}'),
                                      Text('السنة: ${part['year'] ?? ''}'),
                                      Text('الحالة: ${part['status'] ?? ''}'),
                                    ],
                                  ),
                                  trailing: Wrap(
                                    spacing: 4,
                                    children: [
                                      IconButton(
                                        tooltip: 'تعديل',
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blueGrey),
                                        onPressed: () => _showEditDialog(part),
                                      ),
                                      IconButton(
                                        tooltip: 'حذف',
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => _confirmDelete(part),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}
