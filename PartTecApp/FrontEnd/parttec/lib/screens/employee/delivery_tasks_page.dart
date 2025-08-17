import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/delivery_staff_provider.dart';
import 'delivery_order_details_page.dart';

class DeliveryTasksPage extends StatelessWidget {
  const DeliveryTasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeliveryStaffProvider()..fetchDeliveryOrders(),
      child: Scaffold(
        appBar: AppBar(title: const Text('طلبات التوصيل')),
        body: Consumer<DeliveryStaffProvider>(
          builder: (context, provider, _) {
            final statuses = provider.ordersByStatus.keys.toList();
            return provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : DefaultTabController(
                    length: statuses.length,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey,
                          tabs: statuses
                              .map((status) => Tab(text: status))
                              .toList(),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: statuses.map((status) {
                              final orders =
                                  provider.ordersByStatus[status] ?? [];
                              return RefreshIndicator(
                                onRefresh: () => provider.fetchDeliveryOrders(),
                                child: orders.isEmpty
                                    ? ListView(
                                        children: const [
                                          SizedBox(height: 80),
                                          Center(
                                              child: Text(
                                                  'لا توجد طلبات في هذه الحالة')),
                                        ],
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: orders.length,
                                        itemBuilder: (context, index) {
                                          final order = orders[index];
                                          return Card(
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: ListTile(
                                              leading: const Icon(
                                                  Icons.local_shipping,
                                                  color: Colors.teal),
                                              title: Text(
                                                  'طلب رقم: ${order['id']}'),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'العميل: ${order['customerName'] ?? ''}'),
                                                  Text(
                                                      'العنوان: ${order['address'] ?? ''}'),
                                                ],
                                              ),
                                              trailing: const Icon(
                                                  Icons.arrow_forward_ios),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        DeliveryOrderDetailsPage(
                                                      order: order,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }
}
