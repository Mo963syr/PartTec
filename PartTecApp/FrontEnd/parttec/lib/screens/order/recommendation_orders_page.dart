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

  Color _statusColor(String s) {
    final t = s.trim();
    if (t.contains('موجود')) return Colors.green;
    if (t.contains('غير موجود')) return Colors.red;
    if (t.contains('قيد') || t.contains('بحث')) return Colors.amber;
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('طلبات التوصية'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Consumer<RecommendationsProvider>(
                builder: (_, prov, __) {
                  final all = prov.orders;
                  final pendingCount =
                      all.where((o) => prov.isPending(o)).length;
                  final availableCount =
                      all.where((o) => prov.isAvailable(o)).length;
                  final unavailableCount =
                      all.where((o) => prov.isUnavailable(o)).length;

                  return TabBar(
                    labelColor: const Color.fromARGB(255, 0, 0, 0),
                    unselectedLabelColor: const Color.fromARGB(179, 0, 0, 0),
                    indicatorColor: Colors.amber,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'الطلبات ($pendingCount)'),
                      Tab(text: 'موجودة ($availableCount)'),
                      Tab(text: 'غير موجودة ($unavailableCount)'),
                    ],
                  );
                },
              ),
            ),
          ),
          body: Consumer<RecommendationsProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.lastError != null) {
                return Center(child: Text(provider.lastError!));
              }

              final all = provider.orders;

              final pending = all.where((o) => provider.isPending(o)).toList();
              final available =
                  all.where((o) => provider.isAvailable(o)).toList();
              final unavailable =
                  all.where((o) => provider.isUnavailable(o)).toList();

              Widget buildList(
                List<Map<String, dynamic>> orders, {
                bool showActions = true,
              }) {
                if (orders.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => provider.fetchMyRecommendationOrders(),
                    child: ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('لا توجد عناصر هنا')),
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

                      final id = (o['_id'] ?? '').toString();
                      final name = (o['name'] ?? '').toString();
                      final serial = (o['serialNumber'] ?? '').toString();
                      final brand = (o['manufacturer'] ??
                              o['brand'] ??
                              o['brandCode'] ??
                              '')
                          .toString();
                      final model =
                          (o['model'] ?? o['carModel'] ?? '').toString();
                      final year = (o['year'] ?? o['carYear'] ?? '').toString();
                      final status = (o['status'] ?? 'قيد البحث').toString();
                      final notes = (o['notes'] ?? '').toString();
                      final img = (o['imageUrl'] ?? '').toString();
                      final userName = (o['userName'] ?? '').toString();
                      final phone = (o['phoneNumber'] ?? '').toString();
                      final createdAt =
                          _fmtDate((o['createdAt'] ?? '').toString());

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
                              : const CircleAvatar(
                                  child: Icon(Icons.directions_car),
                                ),
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
                                        backgroundColor: _statusColor(status)
                                            .withOpacity(.12),
                                        labelStyle: TextStyle(
                                            color: _statusColor(status)),
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
                                          child: Text([
                                            if (userName.isNotEmpty)
                                              'العميل: $userName',
                                            if (phone.isNotEmpty)
                                              '— هاتف: $phone',
                                          ].join(' ')),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.note_alt_outlined,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                            child: Text('ملاحظات: $notes')),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (recs.isNotEmpty) ...[
                              const Divider(),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.recommend_outlined, size: 18),
                                    SizedBox(width: 6),
                                    Text('التوصيات/العروض',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
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
                                final pStatus =
                                    (m['status'] ?? 'متاح').toString();
                                final partName =
                                    (m['partName'] ?? '').toString();
                                final rNotes = (m['notes'] ?? '').toString();

                                return ListTile(
                                  leading: const Icon(Icons.build),
                                  title: Text(
                                      partName.isEmpty ? 'قطعة' : partName),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                            const Divider(),
                            if (showActions)
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 4, 16, 12),
                                child: Consumer<RecommendationsProvider>(
                                  builder: (context, prov, _) {
                                    final busy = prov.isBusy(id);
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: busy
                                                ? null
                                                : () async {
                                                    final ok = await prov
                                                        .markAvailable(id);
                                                    if (!context.mounted) {
                                                      return;
                                                    }
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(ok
                                                            ? 'تم نقل الطلب إلى: موجودة'
                                                            : (prov.lastError ??
                                                                'فشل التحديث')),
                                                      ),
                                                    );
                                                  },
                                            icon: const Icon(
                                                Icons.check_circle_outline),
                                            label: Text(busy
                                                ? 'جارٍ التحديث...'
                                                : 'موجودة'),
                                            style: ElevatedButton.styleFrom(
                                              minimumSize:
                                                  const Size.fromHeight(44),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: busy
                                                ? null
                                                : () async {
                                                    final ok = await prov
                                                        .markUnavailable(id);
                                                    if (!context.mounted) {
                                                      return;
                                                    }
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(ok
                                                            ? 'تم نقل الطلب إلى: غير موجودة'
                                                            : (prov.lastError ??
                                                                'فشل التحديث')),
                                                      ),
                                                    );
                                                  },
                                            icon:
                                                const Icon(Icons.highlight_off),
                                            label: Text(busy
                                                ? 'جارٍ التحديث...'
                                                : 'غير موجودة'),
                                            style: OutlinedButton.styleFrom(
                                              minimumSize:
                                                  const Size.fromHeight(44),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }

              return TabBarView(
                children: [
                  buildList(pending, showActions: true),
                  buildList(available, showActions: false),
                  buildList(unavailable, showActions: false),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
