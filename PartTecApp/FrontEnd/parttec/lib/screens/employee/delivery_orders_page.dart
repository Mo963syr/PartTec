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

    final customer = (order['customer'] as Map?) ?? {};
    final seller = (order['seller'] as Map?) ?? {};
    final String customerName =
    (customer['name'] ?? order['customerName'] ?? 'غير محدد').toString();
    final String sellerName =
    (seller['name'] ?? order['sellerName'] ?? 'غير محدد').toString();

    String partName = '';
    if (order.containsKey('partName')) {
      partName = order['partName'].toString();
    } else if (order.containsKey('items')) {
      final items = order['items'] as List?;
      if (items != null && items.isNotEmpty) {
        final it = items.first;
        if (it is Map && it['name'] != null) {
          partName = it['name'].toString();
        }
      }
    }
    if (partName.isEmpty) partName = 'قطعة غير معروفة';

    String customerLocationStr = '';
    String sellerLocationStr = '';

    // الزبون
    final customerLocation =
        customer['location'] ?? order['customerLocation'] ?? order['location'];
    if (customerLocation is Map) {
      final lat = (customerLocation['lat'] as num?)?.toDouble();
      final lng = (customerLocation['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        customerLocationStr = '($lat, $lng)';
      } else if (customerLocation['address'] != null) {
        customerLocationStr = customerLocation['address'].toString();
      }
    } else if (customerLocation != null) {
      customerLocationStr = customerLocation.toString();
    }

    // البائع
    final sellerLocation =
        seller['location'] ?? order['sellerLocation'] ?? order['location'];
    if (sellerLocation is Map) {
      final lat = (sellerLocation['lat'] as num?)?.toDouble();
      final lng = (sellerLocation['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        sellerLocationStr = '($lat, $lng)';
      } else if (sellerLocation['address'] != null) {
        sellerLocationStr = sellerLocation['address'].toString();
      }
    } else if (sellerLocation != null) {
      sellerLocationStr = sellerLocation.toString();
    }

    // الهواتف
    final String customerPhone = (customer['phone'] ??
        customer['phoneNumber'] ??
        order['customerPhone'] ??
        '')
        .toString();
    final String sellerPhone =
    (seller['phone'] ?? seller['phoneNumber'] ?? order['sellerPhone'] ?? '')
        .toString();

    // إحداثيات للخريطة
    double? mapLat;
    double? mapLng;
    final locationForMap = customer['location'] ?? customerLocation;
    if (locationForMap is Map) {
      mapLat = (locationForMap['lat'] as num?)?.toDouble();
      mapLng = (locationForMap['lng'] as num?)?.toDouble();
    }

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              partName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('الزبون: $customerName'),
            Text('البائع: $sellerName'),
            if (customerLocationStr.isNotEmpty)
              Text('موقع الزبون: $customerLocationStr'),
            if (sellerLocationStr.isNotEmpty)
              Text('موقع البائع: $sellerLocationStr'),
            if (customerPhone.isNotEmpty) Text('هاتف الزبون: $customerPhone'),
            if (sellerPhone.isNotEmpty) Text('هاتف البائع: $sellerPhone'),
            const SizedBox(height: 8),
            Row(
              children: [
                if (mapLat != null && mapLng != null)
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeliveryMapPage(
                            lat: mapLat!,
                            lng: mapLng!,
                            customerName: customerName,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map_outlined, color: Colors.teal),
                  ),
                const Spacer(),

                // الإجراءات حسب حالة الطلب
                if (status == 'مؤكد') ...[
                  ElevatedButton(
                    onPressed: () {
                      // إدخال سعر التوصيل ثم قبول الطلب → مستلمة
                      showDialog(
                        context: context,
                        builder: (context) {
                          double? price;
                          return AlertDialog(
                            title: const Text('إدخال سعر التوصيل'),
                            content: TextField(
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'السعر بالوحدة المحلية',
                              ),
                              onChanged: (value) {
                                price = double.tryParse(value);
                              },
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
                          );
                        },
                      );
                    },
                    child: const Text('استلام الطلب'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      provider.updateStatus(
                        orderId,
                        'ملغي',
                        context: context,
                      );
                    },
                    child: const Text('إلغاء'),
                  ),
                ] else if (status == 'مستلمة') ...[
                  ElevatedButton(
                    onPressed: () {
                      // بدء التوصيل → على الطريق
                      provider.updateStatus(
                        orderId,
                        'على الطريق',
                        context: context,
                      );
                    },
                    child: const Text('بدء التوصيل'),
                  ),
                ] else if (status == 'على الطريق') ...[
                  ElevatedButton(
                    onPressed: () {
                      provider.updateStatus(
                        orderId,
                        'تم التوصيل',
                        context: context,
                      );
                    },
                    child: const Text('تم التوصيل'),
                  ),
                ] else ...[
                  Container(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
