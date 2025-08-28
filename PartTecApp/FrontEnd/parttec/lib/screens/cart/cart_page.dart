import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/app_theme.dart';
import '../../widgets/ui_kit.dart';

import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/cart_item.dart';
import '../location/add_location.dart';
import '../order/order_summary_page.dart';
import '../../utils/session_store.dart'; // 🆕 لجلب userId

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _fetchedOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final cart = context.read<CartProvider>();
      if (!_fetchedOnce && cart.cartItems.isEmpty) {
        _fetchedOnce = true;
        await cart.fetchCartFromServer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    final double total = cart.cartItems.fold<double>(
      0.0,
          (sum, CartItem item) => sum + (item.part.price * item.quantity),
    );

    final auth = context.watch<AuthProvider>();
    final String role = auth.role ?? '';
    final double discountRate = role == 'mechanic' ? 0.15 : 0.0;
    final double discountAmount = total * discountRate;
    final double finalTotal = total - discountAmount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: GradientBackground(
          child: RefreshIndicator(
            displacement: 140,
            strokeWidth: 2.4,
            onRefresh: () => context.read<CartProvider>().fetchCartFromServer(),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  stretch: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  expandedHeight: 120,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text(
                    'سلة المشتريات',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                if (cart.isLoading && cart.cartItems.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (cart.cartItems.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('السلة فارغة 🛒')),
                  )
                else ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final item = cart.cartItems[index];
                            final part = item.part;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      part.imageUrl,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 64,
                                        height: 64,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.broken_image),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          part.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '${part.price} \$',
                                              style: TextStyle(
                                                color: AppColors.success,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'الكمية: ${item.quantity}',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'حذف',
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmDelete(context, cart, index),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: cart.cartItems.length,
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpaces.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      discountRate > 0 ? 'الإجمالي قبل الخصم:' : 'الإجمالي:',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '\$${total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                if (discountRate > 0) ...[
                                  const SizedBox(height: AppSpaces.xs),
                                  Row(
                                    children: [
                                      const Text(
                                        'الخصم:',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '-\$${discountAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpaces.xs),
                                  Row(
                                    children: [
                                      const Text(
                                        'المجموع بعد الخصم:',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '\$${finalTotal.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: AppSpaces.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final uid = await SessionStore.userId();
                                          if (uid == null || uid.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('⚠️ الرجاء تسجيل الدخول أولاً'),
                                              ),
                                            );
                                            return;
                                          }

                                          final LatLng? location =
                                          await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => LocationPickerPage(
                                                userId: uid, // نمرره عند الحاجة
                                              ),
                                            ),
                                          );

                                          if (location != null) {
                                            _confirmOrderWithLocation(
                                              context,
                                              location,
                                              'الدفع عند الاستلام',
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.delivery_dining),
                                        label: const Text('الدفع عند الاستلام'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpaces.md),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _confirmOrder(
                                          context,
                                          'الدفع الإلكتروني',
                                        ),
                                        icon: const Icon(Icons.credit_card),
                                        label: const Text('الدفع بالبطاقة'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CartProvider cart, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف القطعة'),
        content: const Text('هل أنت متأكد من حذف هذه القطعة من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              cart.removeAt(index);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف القطعة من السلة 🗑️')),
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _confirmOrder(BuildContext context, String method) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الطلب'),
        content: Text('هل تريد تأكيد الطلب باستخدام "$method"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تأكيد الطلب ✅')),
              );
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _confirmOrderWithLocation(
      BuildContext context,
      LatLng location,
      String method,
      ) {
    final cart = context.read<CartProvider>();
    final total = cart.cartItems.fold<double>(
      0.0,
          (sum, CartItem item) => sum + (item.part.price * item.quantity),
    );

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
