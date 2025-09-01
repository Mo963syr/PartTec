import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:latlong2/latlong.dart';
import '../../models/cart_item.dart';

class OrderSummaryPage extends StatelessWidget {
  final List<CartItem> items;

  final double total;

  final LatLng location;

  final String paymentMethod;

  const OrderSummaryPage({
    required this.items,
    required this.total,
    required this.location,
    required this.paymentMethod,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فاتورة الطلب'),
        // استخدم اللون الأساسي للتطبيق
        backgroundColor: AppColors.primary,
      ),
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
                  final CartItem item = items[index];
                  final part = item.part;
                  final int quantity = item.quantity;

                  return ListTile(
                    title: Text(part.name),
                    subtitle: Text('الكمية: $quantity'),
                    trailing:
                        Text('\$${(part.price * quantity).toStringAsFixed(2)}'),
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
                    Navigator.of(context).pop();
                  },
                  child: const Text('إلغاء'),
                  // استخدم لون الخطأ للبوتون
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تأكيد الطلب ✅')),
                    );
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('تأكيد الطلب'),
                  // استخدم لون النجاح للبوتون
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
