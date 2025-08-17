import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/mechanic_provider.dart';

/// Displays a list of the mechanic's current orders along with
/// their statuses.  This screen listens to [MechanicProvider]
/// for updates and shows a refresh button to re-fetch data.
class MechanicCurrentOrdersPage extends StatelessWidget {
  const MechanicCurrentOrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي الحالية')),
      body: Consumer<MechanicProvider>(
        builder: (context, provider, _) {
          final orders = provider.currentOrders;
          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchCurrentOrders();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                final status = order['status']?.toString() ?? '';
                final createdAt = DateTime.tryParse(order['createdAt'] ?? '') ??
                    DateTime.now();
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(
                      status == 'مكتمل'
                          ? Icons.check_circle
                          : Icons.pending_actions,
                      color: status == 'مكتمل' ? Colors.green : Colors.orange,
                    ),
                    title: Text('رقم الطلب: ${order['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الحالة: $status'),
                        Text('التاريخ: ${createdAt.toLocal().toString().split(" ")[0]}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}