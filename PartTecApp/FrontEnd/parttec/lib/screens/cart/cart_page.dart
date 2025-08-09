import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart';
import 'package:latlong2/latlong.dart';
import '../location/add_location.dart';
import '../order/order_summary_page.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    String userId = "687ff5a6bf0de81878ed94f5";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (cart.cartItems.isEmpty && !cart.isLoading) {
        cart.fetchCartFromServer();
      }
    });

    double total = cart.cartItems.fold(0.0, (sum, CartItem item) {
      final part = item.part;
      final quantity = item.quantity;
      final price = part.price;
      return sum + (price * quantity);
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('سلة المشتريات')),
        body: cart.isLoading
            ? const Center(child: CircularProgressIndicator())
            : cart.cartItems.isEmpty
                ? const Center(child: Text('السلة فارغة 🛒'))
                : RefreshIndicator(
                    onRefresh: () => cart.fetchCartFromServer(),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: cart.cartItems.length,
                            itemBuilder: (context, index) {
                              final CartItem item = cart.cartItems[index];
                              final part = item.part;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
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
                                        part.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            part.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${part.price} \$',
                                            style: const TextStyle(
                                                color: Colors.green),
                                          ),
                                          Text('الكمية: ${item.quantity}')
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _confirmDelete(context, cart, index),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Text(
                                'الإجمالي: \$${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
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
                                    icon: const Icon(Icons.delivery_dining),
                                    label: const Text('الدفع عند الاستلام'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _confirmOrder(
                                        context, 'الدفع الإلكتروني'),
                                    icon: const Icon(Icons.credit_card),
                                    label: const Text('الدفع بالبطاقة'),
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
    // Compute the total cost using the typed cart items
    final total = cart.cartItems.fold<double>(0.0, (sum, CartItem item) {
      return sum + (item.part.price * item.quantity);
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderSummaryPage(
          items: cart.cartItems,
          total: total,
          location: location,
          paymentMethod: method,
        ),
      ),
    );
  }
}
