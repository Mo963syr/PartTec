// lib/screens/order/recommendation_orders_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recommendations_provider.dart';

class RecommendationOrdersPage extends StatefulWidget {
  const RecommendationOrdersPage({super.key});

  @override
  State<RecommendationOrdersPage> createState() =>
      _RecommendationOrdersPageState();
}

class _RecommendationOrdersPageState extends State<RecommendationOrdersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<RecommendationsProvider>().fetchMyRecommendationOrders());
  }

  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('طلبات التوصية')),
        body: Consumer<RecommendationsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.lastError != null) {
              return Center(child: Text(provider.lastError!));
            }

            final orders = provider.orders; // نتوقع List<Map<String,dynamic>>
            if (orders.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => provider.fetchMyRecommendationOrders(),
                child: ListView(
                  children: const [
                    SizedBox(height: 120),
                    Center(child: Text('لا توجد طلبات توصية بعد')),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.fetchMyRecommendationOrders(),
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, i) {
                  final o = Map<String, dynamic>.from(orders[i] as Map);

                  // الحقول حسب ردّك الجديد:
                  final id = (o['_id'] ?? '').toString();
                  final name = (o['name'] ?? '').toString();
                  final serial = (o['serialNumber'] ?? '').toString();
                  final brand =
                  (o['manufacturer'] ?? o['brand'] ?? o['brandCode'] ?? '')
                      .toString();
                  final model =
                  (o['model'] ?? o['carModel'] ?? '').toString();
                  final year =
                  (o['year'] ?? o['carYear'] ?? '').toString();
                  final status = (o['status'] ?? 'قيد البحث').toString();
                  final notes = (o['notes'] ?? '').toString();
                  final img = (o['imageUrl'] ?? '').toString();
                  final userName = (o['userName'] ?? '').toString();
                  final phone = (o['phoneNumber'] ?? '').toString();
                  final createdAt = _fmtDate((o['createdAt'] ?? '').toString());

                  // لدعم مستقبلي: مصفوفة عروض/توصيات إن وجدت
                  final recs = (o['recommendations'] as List?) ??
                      (o['offers'] as List?) ??
                      const [];

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ExpansionTile(
                      leading: img.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          img,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                        ),
                      )
                          : const CircleAvatar(child: Icon(Icons.directions_car)),
                      title: Text(
                        name.isNotEmpty ? name : 'طلب توصية',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        [
                          if (brand.isNotEmpty) ' $brand',
                          if (model.isNotEmpty) '$model',
                          if (year.isNotEmpty) ' $year',
                        ].join('  •  '),
                        maxLines: 2,
                      ),
                      children: [
                        // سطر الحالة/التاريخ/المعرف
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  Chip(
                                    label: Text('الحالة: $status'),
                                    materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  if (createdAt.isNotEmpty)
                                    Chip(
                                      label: Text('التاريخ: $createdAt'),
                                      materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                    ),

                                ],
                              ),
                              const SizedBox(height: 8),
                              if (userName.isNotEmpty || phone.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        [
                                          if (userName.isNotEmpty)
                                            'العميل: $userName',
                                          if (phone.isNotEmpty)
                                            '— هاتف: $phone',
                                        ].join(' '),
                                      ),
                                    ),
                                  ],
                                ),
                              if (serial.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.qr_code_2, size: 18),
                                    const SizedBox(width: 6),
                                    Text('الرقم التسلسلي: $serial'),
                                  ],
                                ),
                              ],
                              if (notes.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.note_alt_outlined, size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text('ملاحظات: $notes')),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // قسم العروض/التوصيات (إن وجد)
                        if (recs.isNotEmpty) ...[
                          const Divider(),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Row(
                              children: [
                                Icon(Icons.recommend_outlined, size: 18),
                                SizedBox(width: 6),
                                Text('التوصيات/العروض',
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          ...recs.map((r) {
                            final m = Map<String, dynamic>.from(r as Map);
                            final sellerName =
                            (m['sellerName'] ?? 'مورد').toString();
                            final price = (m['price'] ?? '').toString();
                            final currency =
                            (m['currency'] ?? 'USD').toString();
                            final pStatus = (m['status'] ?? 'متاح').toString();
                            final partName = (m['partName'] ?? '').toString();
                            final rNotes = (m['notes'] ?? '').toString();

                            return ListTile(
                              leading: const Icon(Icons.build),
                              title: Text(
                                  partName.isEmpty ? 'قطعة' : partName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('المورد: $sellerName'),
                                  if (price.isNotEmpty)
                                    Text('السعر: $price $currency'),
                                  Text('حالة القطعة: $pStatus'),
                                  if (rNotes.isNotEmpty)
                                    Text('ملاحظات: $rNotes'),
                                ],
                              ),
                            );
                          }).toList(),
                        ],

                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
