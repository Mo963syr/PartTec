import 'package:flutter/material.dart';
import '../../utils/app_settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/session_store.dart';
import '../../models/part.dart';

import '../supplier/SellerPartDetailsPage.dart';

class AddedPartsPage extends StatefulWidget {
  const AddedPartsPage({super.key});

  @override
  State<AddedPartsPage> createState() => _AddedPartsPageState();
}

class _AddedPartsPageState extends State<AddedPartsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
      final uid = await SessionStore.userId();
      final role = await SessionStore.role();
      debugPrint('🔑 User ID: $uid | 🎭 Role: $role');

      if (uid == null || uid.isEmpty) {
        debugPrint('❌ لا يوجد مستخدم مسجل');
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${AppSettings.serverurl}/part/viewsellerParts/$uid'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> parts = data['parts'] ?? [];


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
    return (part['_id'] ?? part['id'] ?? '').toString();
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
                                  onTap: () async {
                                    final refreshed = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SellerPartDetailsPage(
                                          part: Part.fromJson(part),
                                        ),
                                      ),
                                    );

                                    if (refreshed == true) {
                                      fetchParts();
                                    }
                                  },
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
