import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  final List<String> _statuses = const ['مؤكد', 'على الطريق', 'مستلمة'];
  final Map<String, String> _addressCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialStatus = _statuses[_tabController.index];
      context.read<DeliveryOrdersProvider>().fetchOrders(initialStatus);
    });
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

  List<double>? _extractCoordinates(Map order) {
    List? coords = order['coordinates'] as List?;
    coords ??= order['location'] as List?;
    if (coords != null && coords.length >= 2) {
      final lon = double.tryParse(coords[0].toString());
      final lat = double.tryParse(coords[1].toString());
      if (lat != null && lon != null) return [lon, lat];
    }
    return null;
  }

  String _formatCoords(Map order) {
    final c = _extractCoordinates(order);
    if (c == null) return 'الموقع غير متاح';
    return 'إحداثيات: ${c[1].toStringAsFixed(5)}, ${c[0].toStringAsFixed(5)}';
  }

  Future<String?> _fetchAddress(Map order) async {
    final coords = _extractCoordinates(order);
    if (coords == null) return null;
    final lon = coords[0], lat = coords[1];
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=jsonv2',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'parttec-app/1.0 (https://example.com)'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map?;
        return data?['display_name']?.toString();
      }
    } catch (_) {}
    return null;
  }

  Future<String> _fetchAndCacheAddress(Map order) async {
    final String key = (order['orderId'] ?? order['_id'] ?? '').toString();
    if (_addressCache.containsKey(key)) return _addressCache[key]!;
    final addr = await _fetchAddress(order);
    final fallback = _formatCoords(order);
    final value = (addr != null && addr.isNotEmpty) ? addr : fallback;
    _addressCache[key] = value;
    return value;
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
                    final filtered = provider.orders
                        .where((o) => (o['status'] ?? '') == status)
                        .toList();

                    if (filtered.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => provider.fetchOrders(status),
                        child: ListView(
                          children: [
                            const SizedBox(height: 120),
                            Center(
                              child: Text('لا توجد طلبات بحالة "$status"'),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => provider.fetchOrders(status),
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final order = filtered[index] as Map<String, dynamic>;
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
    final part =
        order['part'] is Map<String, dynamic> ? order['part'] as Map : {};
    final hasPart = part.isNotEmpty;
    final customer = order['customer'] as Map? ?? {};
    final customerName = customer['name']?.toString() ?? '';
    final customerPhone = customer['phoneNumber']?.toString() ??
        customer['phone']?.toString() ??
        '';
    final coords = _extractCoordinates(order);
    final province = (order['delivery']?['province'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasPart)
              Text(
                part['name']?.toString() ?? '',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            if (customerName.isNotEmpty) Text('الزبون: $customerName'),
            if (customerPhone.isNotEmpty) Text('هاتف: $customerPhone'),
            if (province.isNotEmpty) Text('المحافظة: $province'),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: FutureBuilder<String>(
                future: _fetchAndCacheAddress(order),
                initialData: _formatCoords(order),
                builder: (context, snap) {
                  final text = (snap.data == null || snap.data!.isEmpty)
                      ? _formatCoords(order)
                      : snap.data!;
                  return Text('الموقع: $text',
                      style: const TextStyle(fontSize: 13));
                },
              ),
            ),
            const SizedBox(height: 8),
            if (coords != null)
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeliveryMapPage(
                          lat: coords[1],
                          lng: coords[0],
                          customerName: customerName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text("عرض على الخريطة"),
                ),
              ),
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
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration:
                                const InputDecoration(labelText: 'السعر'),
                            onChanged: (value) =>
                                price = double.tryParse(value),
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
                    onPressed: () => provider.updateStatus(orderId, 'ملغي',
                        context: context),
                    child: const Text('إلغاء'),
                  ),
                ] else if (status == 'مستلمة') ...[
                  ElevatedButton(
                    onPressed: () => provider
                        .updateStatus(orderId, 'على الطريق', context: context),
                    child: const Text('بدء التوصيل'),
                  ),
                ] else if (status == 'على الطريق') ...[
                  ElevatedButton(
                    onPressed: () => provider
                        .updateStatus(orderId, 'تم التوصيل', context: context),
                    child: const Text('تم التوصيل'),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
