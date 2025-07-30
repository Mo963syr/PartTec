import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:parttec/providers/seller_orders_provider.dart';

class SellerOrderDetailsPage extends StatelessWidget {
  final String customerName;
  final List<Map<String, dynamic>> orders;

  const SellerOrderDetailsPage({
    required this.customerName,
    required this.orders,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerOrdersProvider>(context, listen: false);
    final total = orders.fold(0.0, (sum, item) => sum + (item['total'] ?? 0));

    return Scaffold(
      appBar: AppBar(title: Text('تفاصيل الطلب - $customerName')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ...orders.map((order) {
            final part = order['part'] ?? {};
            final quantity = order['quantity'] ?? 0;
            final total = order['total'] ?? 0;

            final orderData = order['order'] ?? {};
            final status = order['status'] ?? 'غير محددة';
            final createdAt = order['createdAt'];
            print('📦 بيانات الطلب: $orderData');


            String formattedDate = 'تاريخ غير معروف';
            if (createdAt != null) {
              try {
                final date = DateTime.parse(createdAt);
                formattedDate = DateFormat.yMd().add_jm().format(date);
              } catch (_) {}
            }

            return Card(
              child: ListTile(
                leading: (part['imageUrl'] != null && part['imageUrl'] != '')
                    ? Image.network(
                  part['imageUrl'],
                  width: 50,
                  errorBuilder: (_, __, ___) => Icon(Icons.image),
                )
                    : Icon(Icons.image),
                title: Text(part['name'] ?? 'اسم غير معروف'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الكمية: $quantity'),
                    Text('السعر الإجمالي: \$${total.toStringAsFixed(2)}'),
                    Text('الحالة: $status'),
                    Text('تاريخ الإنشاء: $formattedDate'),
                  ],
                ),
              ),
            );
          }),
          const Divider(),
          Text(
            'السعر الكلي للطلب: \$${total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              ElevatedButton(
                onPressed: () {
                  final orderId = orders.first['order']?['_id'];
                  if (orderId != null) {
                    provider.updateStatus(orderId, 'ملغي', context);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('معرف الطلب غير متوفر')),
                    );
                  }

                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  final orderId = orders.first['order']?['_id'];
                  if (orderId != null) {
                    provider.updateStatus(orderId, 'على الطريق', context);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('معرف الطلب غير متوفر')),
                    );
                  }

                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('على الطريق'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
