import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/purchases_provider.dart';
import '../../utils/session_store.dart';

class UserDeliveredOrdersPage extends StatefulWidget {
  const UserDeliveredOrdersPage({super.key});

  @override
  State<UserDeliveredOrdersPage> createState() =>
      _UserDeliveredOrdersPageState();
}

class _UserDeliveredOrdersPageState extends State<UserDeliveredOrdersPage> {
  String _filter = 'الكل';

  final List<String> _filters = [
    'الكل',
    'اليومي',
    'الأسبوعي',
    'الشهري',
    'السنوي',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final userId = await SessionStore.userId();
      if (userId != null) {
        context.read<PurchasesProvider>().fetchPurchases(userId);
      }
    });
  }

  List<Map<String, dynamic>> _filterOrders(
      List<Map<String, dynamic>> orders, String filter) {
    DateTime now = DateTime.now().toUtc();
    return orders.where((order) {
      final status = order['status'] ?? '';
      if (status != 'تم التوصيل') return false;

      final createdAt = order['createdAt']?.toString();
      if (createdAt == null || createdAt.isEmpty) return false;

      final date = DateTime.tryParse(createdAt);
      if (date == null) return false;

      switch (filter) {
        case 'اليومي':
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        case 'الأسبوعي':
          final weekday = now.weekday % 7;
          final startOfWeek = DateTime.utc(now.year, now.month, now.day)
              .subtract(Duration(days: weekday));
          final endOfWeek = startOfWeek.add(
              const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
          return !date.isBefore(startOfWeek) && !date.isAfter(endOfWeek);
        case 'الشهري':
          return date.year == now.year && date.month == now.month;
        case 'السنوي':
          return date.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PurchasesProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('سجل الطلبات')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : _buildPurchases(provider),
    );
  }

  Widget _buildPurchases(PurchasesProvider provider) {
    final filtered = _filterOrders(
        List<Map<String, dynamic>>.from(provider.purchases), _filter);

    double total = filtered.fold(
        0.0, (sum, o) => sum + ((o['totalAmount'] ?? 0).toDouble()));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: _filter,
            items: _filters
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (val) => setState(() => _filter = val!),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('لا توجد طلبات مكتملة'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    final items = (order['items'] as List?) ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(items.length.toString()),
                        ),
                        title: Text(
                            'طلب #${(order['orderId'] ?? '').toString().substring(0, 6)}'),
                        subtitle: Text(order['supplier']?['name'] ?? 'مورد'),
                        trailing: Text('\$${order['totalAmount']}'),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إجمالي الطلبات:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ),
      ],
    );
  }
}
