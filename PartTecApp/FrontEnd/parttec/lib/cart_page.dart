import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'package:latlong2/latlong.dart';
import 'add_location.dart';
import 'order_summary_page.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    String userId = "687ff5a6bf0de81878ed94f5";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (cart.fetchedCartItems.isEmpty && !cart.isLoading) {
        cart.fetchCartFromServer();
      }
    });

    double total = cart.fetchedCartItems.fold(0, (sum, item) {
      final part = item['partId'];
      final quantity = item['quantity'] ?? 1;
      final price = part?['price'] ?? 0;
      return sum + (price * quantity);
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('سلة المشتريات')),
        body: cart.isLoading
            ? Center(child: CircularProgressIndicator())
            : cart.fetchedCartItems.isEmpty
                ? Center(child: Text('السلة فارغة 🛒'))
                : RefreshIndicator(
                    onRefresh: () => cart.fetchCartFromServer(),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: cart.fetchedCartItems.length,
                            itemBuilder: (context, index) {
                              final item = cart.fetchedCartItems[index];
                              final part = item['partId'];

                              if (part == null) {
                                return ListTile(
                                  title: Text('⚠️ لا توجد معلومات عن القطعة'),
                                );
                              }

                              return Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        part['imageUrl'] ?? '',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Icon(Icons.broken_image),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            part['name'] ?? 'بدون اسم',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '${part['price']} \$',
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                          Text(
                                              'الكمية: ${item['quantity'] ?? 1}')
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () =>
                                          _confirmDelete(context, cart, index),
                                    )
                                  ],
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
                              Text(
                                'الإجمالي: \$${total.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final LatLng? location =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => LocationPickerPage(
                                                userId: userId)),
                                      );

                                      if (location != null) {
                                        _confirmOrderWithLocation(context,
                                            location, 'الدفع عند الاستلام');
                                      }
                                    },
                                    icon: Icon(Icons.delivery_dining),
                                    label: Text('الدفع عند الاستلام'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _confirmOrder(
                                        context, 'الدفع الإلكتروني'),
                                    icon: Icon(Icons.credit_card),
                                    label: Text('الدفع بالبطاقة'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
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
              cart.removeAt(index);
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

  void _confirmOrderWithLocation(
      BuildContext context, LatLng location, String method) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final total = cart.fetchedCartItems.fold(0.0, (sum, item) {
      final part = item['partId'];
      final quantity = item['quantity'] ?? 1;
      final price = part?['price'] ?? 0;
      return sum + (price * quantity);
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderSummaryPage(
          items: cart.fetchedCartItems,
          total: total,
          location: location,
          paymentMethod: method,
        ),
      ),
    );
  }
}
