import 'package:flutter/material.dart';
import 'package:parttec/setting.dart';
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
  Map<String, List<dynamic>> categorizedParts = {
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
    try {
      final response = await http.get(

        Uri.parse('${AppSettings.serverurl}/part/viewsellerParts/68761cf7f92107b8288158c2'),


      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

final List<dynamic> parts=data['parts'] ??[];
        // تفريغ التصنيفات

        for (var key in categorizedParts.keys) {
          categorizedParts[key] = [];
        }

        for (var part in parts) {
          final category = part['category'] ?? '';
          if (categorizedParts.containsKey(category)) {
            categorizedParts[category]!.add(part);
          }
        }
      } else {
        print('فشل في تحميل القطع: ${response.body}');
      }
    } catch (e) {
      print('حدث خطأ: $e');
    } finally {
      setState(() => isLoading = false);
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
            : TabBarView(
                controller: _tabController,
                children: categorizedParts.keys.map((category) {
                  final parts = categorizedParts[category]!;
                  return parts.isEmpty
                      ? const Center(child: Text('لا توجد قطع في هذا التصنيف'))
                      : ListView.builder(
                          itemCount: parts.length,
                          itemBuilder: (context, index) {
                            final part = parts[index];
                            return Card(
                              margin: const EdgeInsets.all(12),
                              child: ListTile(
                                leading: part['imageUrl'] != null
                                    ? Image.network(part['imageUrl'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover)
                                    : const Icon(Icons.image, size: 50),
                                title: Text(part['name'] ?? 'بدون اسم'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('الموديل: ${part['model'] ?? ''}'),
                                    Text('السنة: ${part['year'] ?? ''}'),
                                    Text('الحالة: ${part['status'] ?? ''}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                }).toList(),
              ),
      ),
    );
  }
}
