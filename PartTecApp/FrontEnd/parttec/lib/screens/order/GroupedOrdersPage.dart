import 'package:flutter/material.dart';
import '../../providers/seller_orders_provider.dart';
import 'SellerOrderDetailsPage.dart';
import 'package:provider/provider.dart';

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
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statuses.length, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        Provider.of<SellerOrdersProvider>(context, listen: false).fetchOrders();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SellerOrdersProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerOrdersProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('طلبات الزبائن'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: statuses.map((status) => Tab(text: status)).toList(),
        ),
      ),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : TabBarView(
                  controller: _tabController,
                  children: statuses.map((status) {
                    final filteredEntries =
                        provider.groupedOrdersByCustomer.entries.where((entry) {
                      final orders = entry.value;
                      return orders.any((order) => order['status'] == status);
                    }).toList();

                    if (filteredEntries.isEmpty) {
                      return Center(
                          child: Text('لا توجد طلبات بحالة "$status"'));
                    }

                    return ListView(
                      children: filteredEntries.map((entry) {
                        final userOrders = entry.value
                            .where((order) => order['status'] == status)
                            .toList();

                        if (userOrders.isEmpty) return SizedBox.shrink();

                        final user = userOrders[0]['user'];
                        final total = userOrders.fold(
                            0.0, (sum, item) => sum + (item['total'] ?? 0));

                        return Card(
                          margin: EdgeInsets.all(12),
                          child: ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text(user['name'] ?? 'مستخدم غير معروف'),
                            subtitle: Text(user['email'] ?? ''),
                            trailing:
                                Text('المجموع: \$${total.toStringAsFixed(2)}'),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SellerOrderDetailsPage(
                                    customerName: user['name'],
                                    orders: userOrders,
                                  ),
                                ),
                              );

                              // تحديث بعد العودة
                              provider.fetchOrders();
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
    );
  }
}
