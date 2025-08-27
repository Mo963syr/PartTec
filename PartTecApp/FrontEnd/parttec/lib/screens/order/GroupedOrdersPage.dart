import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/seller_orders_provider.dart';
import 'SellerOrderDetailsPage.dart';

class GroupedOrdersPage extends StatefulWidget {
  @override
  _GroupedOrdersPageState createState() => _GroupedOrdersPageState();
}

class _GroupedOrdersPageState extends State<GroupedOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> statuses = [
    'مؤكد',
    'على الطريق',
    'تم التوصيل',
    'ملغي',
    'مستلمة'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statuses.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<SellerOrdersProvider>().fetchOrders();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerOrdersProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SellerOrdersProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات الزبائن'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: statuses.map((s) => Tab(text: s)).toList(),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(child: Text(provider.error!))
          : TabBarView(
        controller: _tabController,
        children: statuses.map((status) {
          final allOrders = provider.orders;
          final filtered =
          allOrders.where((o) => (o['status'] ?? '') == status).toList();

          if (filtered.isEmpty) {
            return Center(child: Text('لا توجد طلبات بحالة "$status"'));
          }

          final Map<String, List<Map<String, dynamic>>> grouped = {};
          for (final o in filtered) {
            final c = (o['customer'] as Map?) ?? {};
            final id = (c['_id'] ?? 'unknown').toString();
            grouped.putIfAbsent(id, () => []).add(o);
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: grouped.entries.map((entry) {
              final customerOrders = entry.value;
              final customer =
              ((customerOrders.first['customer'] as Map?) ?? {});
              final name =
              (customer['name'] ?? 'مستخدم غير معروف').toString();
              final email = (customer['email'] ?? '').toString();

              final totalForCustomer = customerOrders.fold<double>(
                0.0,
                    (sum, o) =>
                sum +
                    ((o['totalAmount'] as num?)?.toDouble() ??
                        ((o['items'] as List?)
                            ?.fold<num>(
                            0,
                                (s, it) =>
                            s +
                                (((it as Map?)?['total']
                                as num?) ??
                                    0)) ??
                            0)
                            .toDouble()),
              );

              final itemsCount = customerOrders.fold<int>(
                0,
                    (count, o) => count + (((o['items'] as List?)?.length) ?? 0),
              );

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                elevation: 1.5,
                child: ExpansionTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(name),
                  subtitle: Text(email),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('طلبات: ${customerOrders.length}'),
                      Text('المجموع: ${totalForCustomer.toStringAsFixed(2)}'),
                    ],
                  ),
                  children: [
                    ...customerOrders.map((o) {
                      final createdAtStr = (o['createdAt'] ?? '').toString();
                      final items = (o['items'] as List?) ?? [];
                      final orderTotal =
                          (o['totalAmount'] as num?)?.toDouble() ??
                              items.fold<num>(
                                  0,
                                      (s, it) =>
                                  s +
                                      (((it as Map?)?['total'] as num?) ??
                                          0)).toDouble();

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: Chip(label: Text('${items.length} عنصر')),
                        title: Text(
                            'طلب #${(o['orderId'] ?? '').toString().substring(0, 6)}'),
                        subtitle: Text(
                          createdAtStr.isEmpty
                              ? ''
                              : DateTime.tryParse(createdAtStr) != null
                              ? _fmtDate(DateTime.parse(createdAtStr))
                              : createdAtStr,
                        ),
                        trailing: Text(orderTotal.toStringAsFixed(2)),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SellerOrderDetailsPage(
                                customerName: name,
                                orders: [o],
                              ),
                            ),
                          );
                          context
                              .read<SellerOrdersProvider>()
                              .fetchOrders();
                        },
                      );
                    }).toList(),
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 18),
                          const SizedBox(width: 6),
                          Text('إجمالي العناصر: $itemsCount'),
                          const Spacer(),
                          Text('إجمالي المبالغ: ${totalForCustomer.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}
