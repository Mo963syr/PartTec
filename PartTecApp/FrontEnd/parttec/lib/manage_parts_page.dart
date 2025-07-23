import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parttec/setting.dart';

class ManagePartsPage extends StatefulWidget {
  const ManagePartsPage({super.key});

  @override
  State<ManagePartsPage> createState() => _ManagePartsPageState();
}

class _ManagePartsPageState extends State<ManagePartsPage> {
  List<dynamic> parts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParts();
  }

  Future<void> fetchParts() async {
    final uri = Uri.parse('${AppSettings.serverurl}/part/viewPrivateParts');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);

        print(' الاستجابة من السيرفر: $decoded');

        final List<dynamic> data = decoded['parts'];

        print(' تم جلب القطع: $data');

        setState(() {
          parts = data;
          isLoading = false;
        });
      } else {
        throw Exception('فشل تحميل البيانات');
      }
    } catch (e) {
      print('❌ خطأ أثناء تحميل القطع: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل القطع: $e')),
      );
    }
  }

  Future<void> deletePart(String id) async {
    final uri = Uri.parse('${AppSettings.serverurl}/part/delete/$id');

    print('🗑️ سيتم حذف القطعة ذات المعرف: $id');

    try {
      final response = await http.delete(uri);
      if (response.statusCode == 200) {
        print('✅ تم حذف القطعة بنجاح');

        setState(() {
          parts.removeWhere((p) => p['_id'] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف القطعة')),
        );
      } else {
        throw Exception('فشل الحذف');
      }
    } catch (e) {
      print('❌ خطأ أثناء حذف القطعة: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء الحذف: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة القطع'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : parts.isEmpty
              ? const Center(child: Text('لا توجد قطع مضافة حالياً'))
              : ListView.builder(
                  itemCount: parts.length,
                  itemBuilder: (context, index) {
                    final part = parts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: part['imageUrl'] != null
                            ? Image.network(
                                part['imageUrl'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(part['name'] ?? 'بدون اسم'),
                        subtitle: Text(
                            '${part['manufacturer'] ?? ''} - ${part['model'] ?? ''} - ${part['year'] ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () {
                                print(
                                    '✏️ تعديل القطعة: ${part['_id']} - ${part['name']}');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deletePart(part['_id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
