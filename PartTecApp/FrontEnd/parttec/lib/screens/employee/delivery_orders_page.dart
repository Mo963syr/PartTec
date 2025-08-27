import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/delivery_orders_provider.dart';
import 'DeliveryMapPage.dart';

class DeliveryOrdersPage extends StatefulWidget {
  const DeliveryOrdersPage({Key? key}) : super(key: key);

  @override
  State<DeliveryOrdersPage> createState() => _DeliveryOrdersPageState();
}

class _DeliveryOrdersPageState extends State<DeliveryOrdersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // ترتيب الحالات حسب تبويباتك
  final List<String> _statuses = const ['مؤكد', 'على الطريق', 'مستلمة'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);

    // تحميل تبويب البداية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialStatus = _statuses[_tabController.index];
      context.read<DeliveryOrdersProvider>().fetchOrders(initialStatus);
    });

    // إعادة الجلب عند تغيير التبويب
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final s = _statuses[_tabController.index];
        context.read<DeliveryOrdersProvider>().fetchOrders(s);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryOrdersProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات التوصيل'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _statuses.map((s) => Tab(text: s)).toList(),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(child: Text(provider.error!))
          : TabBarView(
        controller: _tabController,
        children: _statuses.map((status) {
          // ملاحظة: provider.orders يحوي آخر نتيجة للحالة الحالية فقط
          // لذا عند فتح تبويب جديد سيتم الجلب عبر المستمع أعلاه
          final filtered = provider.orders
              .where((o) => (o['status'] ?? '') == status)
              .toList();

          if (filtered.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchOrders(status),
              child: ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text('لا توجد طلبات بحالة "$status"')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchOrders(status),
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final order = filtered[index];
                return _buildOrderCard(context, order, provider);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
  Widget _buildOrderCard(
      BuildContext context,
      Map<String, dynamic> order,
      DeliveryOrdersProvider provider,
      ) {
    final status = (order['status'] ?? '').toString();
    final String orderId = (order['orderId'] ?? order['_id'] ?? '').toString();

    // القطعة الأولى
    final part = order['part'] is Map<String, dynamic> ? order['part'] as Map : {};
    final hasPart = part.isNotEmpty;

    // القطعة الثانية
    final part1 = order['part1'] is Map<String, dynamic> ? order['part1'] as Map : {};
    final hasPart1 = part1.isNotEmpty;

    // الزبون
    final customer = order['customer'] as Map? ?? {};
    final customerName = customer['name']?.toString() ?? '';
    final customerPhone = customer['phoneNumber']?.toString() ?? customer['phone']?.toString() ?? '';

    // البائع
    final seller = order['seller'] as Map? ?? {};
    final sellerName = seller['name']?.toString() ?? '';
    final sellerPhone = seller['phoneNumber']?.toString() ?? seller['phone']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // القطعة الأولى
            if (hasPart) ...[
              Text(
                part['name']?.toString() ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (part['manufacturer'] != null) Text('المصنّع: ${part['manufacturer']}'),
              if (part['price'] != null) Text('السعر: ${part['price']}'),
              const Divider(),
            ],

            // القطعة الثانية
            if (hasPart1) ...[
              Text(
                part1['name']?.toString() ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (part1['manufacturer'] != null) Text('المصنّع: ${part1['manufacturer']}'),
              if (part1['price'] != null) Text('السعر: ${part1['price']}'),
              const Divider(),
            ],

            if (customerName.isNotEmpty) Text('الزبون: $customerName'),
            if (customerPhone.isNotEmpty) Text('هاتف الزبون: $customerPhone'),
            if (sellerName.isNotEmpty) Text('البائع: $sellerName'),
            if (sellerPhone.isNotEmpty) Text('هاتف البائع: $sellerPhone'),

            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                if (status == 'مؤكد') ...[
                  ElevatedButton(
                    onPressed: () {
                      double? price;
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('إدخال سعر التوصيل'),
                          content: TextField(
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'السعر بالوحدة المحلية'),
                            onChanged: (value) => price = double.tryParse(value),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('إلغاء'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (price != null && price! > 0) {
                                  provider.updateStatus(
                                    orderId,
                                    'مستلمة',
                                    deliveryPrice: price,
                                    context: context,
                                  );
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text('حفظ'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('استلام الطلب'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => provider.updateStatus(orderId, 'ملغي', context: context),
                    child: const Text('إلغاء'),
                  ),
                ] else if (status == 'مستلمة') ...[
                  ElevatedButton(
                    onPressed: () => provider.updateStatus(orderId, 'على الطريق', context: context),
                    child: const Text('بدء التوصيل'),
                  ),
                ] else if (status == 'على الطريق') ...[
                  ElevatedButton(
                    onPressed: () => provider.updateStatus(orderId, 'تم التوصيل', context: context),
                    child: const Text('تم التوصيل'),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }}
