import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    // تحميل الطلبات من السيرفر عند أول دخول للصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (cart.fetchedCartItems.isEmpty && !cart.isLoading) {
        cart.fetchCartFromServer();
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('سلة المشتريات')),
        body: cart.isLoading
            ? Center(child: CircularProgressIndicator())
            : cart.fetchedCartItems.isEmpty
            ? Center(child: Text('السلة فارغة 🛒'))
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cart.fetchedCartItems.length,
                itemBuilder: (context, index) {
                  final item = cart.fetchedCartItems[index];
                  final part = item['partId']; // مفترض أنها populate من الخادم

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      leading: part['imageUrl'] != null
                          ? Image.network(part['imageUrl'], width: 60)
                          : Icon(Icons.image, size: 50),
                      title: Text(part['name'] ?? 'بدون اسم'),
                      subtitle: Text(
                        '${part['price']} \$',
                        style: TextStyle(color: Colors.green),
                      ),
                      trailing: Text('الكمية: ${item['quantity'] ?? 1}'),
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
                  // Text(
                  //   // 'الإجمالي: ${cart.totalAmount.toStringAsFixed(2)} \$',
                  //   // style: TextStyle(fontSize: 18),
                  // )
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
              // cart.removeFromCart(index);
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
