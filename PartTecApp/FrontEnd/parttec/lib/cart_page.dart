import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('سلة المشتريات')),
        body: cart.items.isEmpty
            ? Center(child: Text('السلة فارغة 🛒'))
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return Card(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            leading: item['imageUrl'] != null
                                ? Image.network(item['imageUrl'], width: 60)
                                : Icon(Icons.image, size: 50),
                            title: Text(item['name'] ?? 'بدون اسم'),
                            subtitle: Text(
                              '${item['price']} \$',
                              style: TextStyle(color: Colors.green),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if ((item['quantity'] ?? 1) > 1)
                                  IconButton(
                                    icon: Icon(Icons.remove_circle),
                                    onPressed: () =>
                                        cart.decreaseQuantity(index),
                                  )
                                else
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () =>
                                        _confirmDelete(context, cart, index),
                                  ),
                                Text('${item['quantity'] ?? 1}'),
                                IconButton(
                                  icon: Icon(Icons.add_circle),
                                  onPressed: () => cart.increaseQuantity(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _confirmOrder(context, 'الدفع عند الاستلام'),
                              icon: Icon(Icons.delivery_dining),
                              label: Text('الدفع عند الاستلام'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange),
                            ),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _confirmOrder(context, 'الدفع الإلكتروني'),
                              icon: Icon(Icons.credit_card),
                              label: Text('الدفع بالبطاقة'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'الإجمالي: ${cart.totalAmount.toStringAsFixed(2)} \$',
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CartProvider cart, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('حذف القطعة'),
        content: Text('هل أنت متأكد من حذف هذه القطعة من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              cart.removeFromCart(index);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم حذف القطعة من السلة 🗑️')),
              );
            },
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _confirmOrder(BuildContext context, String method) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تأكيد الطلب'),
        content: Text('هل تريد تأكيد الطلب باستخدام "$method"؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم تأكيد الطلب ✅')),
              );
            },
            child: Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
