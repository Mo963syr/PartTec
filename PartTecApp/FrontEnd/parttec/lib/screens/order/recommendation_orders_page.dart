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
            final orders = provider.orders;
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
                  final o = orders[i];
                  final brand = (o['brand'] ?? o['brandCode'] ?? '').toString();
                  final model = (o['model'] ?? o['carModel'] ?? '').toString();
                  final year = (o['year'] ?? o['carYear'] ?? '').toString();
                  final status = (o['status'] ?? 'pending').toString();
                  final createdAt = (o['createdAt'] ?? '').toString();

                  // قائمة التوصيات/العروض القادمة من المورّدين
                  final recs = (o['recommendations'] as List?) ??
                      (o['offers'] as List?) ??
                      [];

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ExpansionTile(
                      title: Text(
                          'ماركة: $brand  •  موديل: $model  •  سنة: $year'),
                      subtitle: Text('الحالة: $status  •  التاريخ: $createdAt'),
                      children: [
                        if (recs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('لا توجد توصيات حتى الآن'),
                          )
                        else
                          ...recs.map((r) {
                            final m = Map<String, dynamic>.from(r as Map);
                            final sellerName =
                                (m['sellerName'] ?? 'مورد').toString();
                            final price = (m['price'] ?? '').toString();
                            final currency =
                                (m['currency'] ?? 'USD').toString();
                            final pStatus = (m['status'] ?? 'متاح').toString();
                            final partName = (m['partName'] ?? '').toString();
                            final notes = (m['notes'] ?? '').toString();

                            return ListTile(
                              leading: const Icon(Icons.build),
                              title: Text(partName.isEmpty ? 'قطعة' : partName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('المورد: $sellerName'),
                                  if (price.isNotEmpty)
                                    Text('السعر: $price $currency'),
                                  Text('حالة القطعة: $pStatus'),
                                  if (notes.isNotEmpty) Text('ملاحظات: $notes'),
                                ],
                              ),
                            );
                          }),
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
