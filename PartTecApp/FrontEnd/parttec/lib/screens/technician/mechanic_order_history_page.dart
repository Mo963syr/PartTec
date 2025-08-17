import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/mechanic_provider.dart';

class MechanicOrderHistoryPage extends StatelessWidget {
  const MechanicOrderHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل الطلبات')),
      body: Consumer<MechanicProvider>(
        builder: (context, provider, _) {
          final history = provider.orderHistory;
          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchOrderHistory();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = history[index];
                final discount = order['discount'] ?? 0.0;
                final total = order['total'] ?? 0.0;
                final createdAt = DateTime.tryParse(order['createdAt'] ?? '') ??
                    DateTime.now();
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: Colors.teal),
                    title: Text('رقم الطلب: ${order['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المجموع: ${total.toStringAsFixed(2)} ليرة'),
                        Text(
                            'نسبة الخصم: ${(discount * 100).toStringAsFixed(1)}%'),
                        Text(
                            'التاريخ: ${createdAt.toLocal().toString().split(" ")[0]}'),
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
