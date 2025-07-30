import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class OrderSummaryPage extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double total;
  final LatLng location;
  final String paymentMethod;

  const OrderSummaryPage({
    required this.items,
    required this.total,
    required this.location,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('فاتورة الطلب')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('طريقة الدفع: $paymentMethod'),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  final part = item['partId'];
                  final quantity = item['quantity'] ?? 1;
                  final price = part?['price'] ?? 0;
                  final name = part?['name'] ?? 'بدون اسم';

                  return ListTile(
                    title: Text(name),
                    subtitle: Text('الكمية: $quantity'),
                    trailing: Text('\$${price * quantity}'),
                  );
                },
              ),
            ),
            Divider(),
            Text('الإجمالي: \$${total.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('الموقع المحدد:'),
            Text('خط العرض: ${location.latitude}'),
            Text('خط الطول: ${location.longitude}'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // إلغاء
                  },
                  child: Text('إلغاء'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 👇 هنا ترسل الطلب إلى السيرفر أو تنفذه فعليًا
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم تأكيد الطلب ✅')),
                    );
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text('تأكيد الطلب'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
