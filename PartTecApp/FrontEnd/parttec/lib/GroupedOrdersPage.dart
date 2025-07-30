import 'package:flutter/material.dart';
import 'package:parttec/providers/seller_orders_provider.dart';
import 'package:parttec/SellerOrderDetailsPage.dart';
import 'package:provider/provider.dart';

class GroupedOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerOrdersProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('طلبات الزبائن')),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(child: Text(provider.error!))
          : ListView(
        children: provider.groupedOrdersByCustomer.entries.map((entry) {
          final userOrders = entry.value;
          final user = userOrders[0]['user'];
          final total = userOrders.fold(0.0,
                  (sum, item) => sum + (item['total'] ?? 0));

          return Card(
            margin: EdgeInsets.all(12),
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text(user['name'] ?? 'مستخدم غير معروف'),
              subtitle: Text(user['email'] ?? ''),
              trailing: Text('المجموع: \$${total.toStringAsFixed(2)}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SellerOrderDetailsPage(
                      customerName: user['name'],
                      orders: userOrders,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
