import 'package:flutter/material.dart';
import 'package:parttec/providers/seller_orders_provider.dart';
import 'package:provider/provider.dart';
import 'package:parttec/seller_orders_page.dart';
import 'package:intl/intl.dart';

class SellerOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerOrdersProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('طلبات القطع المؤكدة')),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(child: Text(provider.error!))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: provider.orders.length,
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                final part = order['part'];
                final user = order['user'];

                return Card(
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Image.network(
                            part['imageUrl'] ?? '',
                            width: 50,
                            errorBuilder: (_, __, ___) => Icon(Icons.image),
                          ),
                          title: Text(part['name'] ?? 'بدون اسم'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الكمية: ${order['quantity']}'),
                              Text('السعر الإجمالي: \$${order['total']}'),
                              Text('العميل: ${user['name']}'),
                              Text('تاريخ الطلب: ${DateFormat.yMd().add_jm().format(DateTime.parse(order['createdAt']))}'),
                              Text('الحالة الحالية: ${order['status']}'),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: [

                            ElevatedButton(
                              onPressed: () => provider.updateStatus(order['_id'], 'ملغي', context),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: Text('إلغاء'),
                            ),
                            ElevatedButton(
                              onPressed: () => provider.updateStatus(order['_id'], 'على الطريق', context),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: Text('على الطريق'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'الإجمالي الكلي لجميع الطلبات: \$${provider.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
