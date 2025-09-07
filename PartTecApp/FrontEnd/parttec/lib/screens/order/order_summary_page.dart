import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/session_store.dart';
import '../home/home_page.dart';
import '../supplier/supplier_dashboard.dart';
import '../order/PaymentPage.dart';

class OrderSummaryPage extends StatefulWidget {
  final List<CartItem> items;
  final double total;
  final LatLng location;

  final String paymentMethod;

  OrderSummaryPage({
    Key? key,
    required this.items,
    required this.total,
    required this.location,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  bool _isSending = false;
  String? _address;
  bool _loadingAddress = true;

  @override
  void initState() {
    super.initState();
    _fetchAddress();

    if (widget.items.isNotEmpty) {
      final firstPartId = widget.items.first.part.id; // 🆕 partId من أول عنصر
      Future.microtask(() {
        context.read<OrderProvider>().fetchDeliveryPricing(
              partId: firstPartId,
              toLat: widget.location.latitude,
              toLon: widget.location.longitude,
            );
      });
    }
  }

  Future<void> _fetchAddress() async {
    final lat = widget.location.latitude;
    final lon = widget.location.longitude;
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=jsonv2');
      final response = await http.get(uri,
          headers: {'User-Agent': 'parttec-app/1.0 (https://example.com)'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _address = data['display_name']?.toString();
          _loadingAddress = false;
        });
      } else {
        setState(() {
          _address = null;
          _loadingAddress = false;
        });
      }
    } catch (_) {
      setState(() {
        _address = null;
        _loadingAddress = false;
      });
    }
  }

  Future<void> _confirmOrder() async {
    final orderProvider = context.read<OrderProvider>();

    if (orderProvider.loadingDelivery) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⏳ يرجى انتظار حساب تكلفة التوصيل...')),
      );
      return;
    }

    final deliveryFee = orderProvider.deliveryPrice;
    if (deliveryFee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ فشل في جلب تكلفة التوصيل')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    final coords = [widget.location.longitude, widget.location.latitude];

    final orderId = await orderProvider.sendOrder(coords, deliveryFee);
    if (!mounted) return;

    if (orderProvider.error != null || orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orderProvider.error ?? "فشل إنشاء الطلب")),
      );
      setState(() {
        _isSending = false;
      });
      return;
    }

    await context.read<CartProvider>().fetchCartFromServer();

    final totalWithDelivery = (widget.total + deliveryFee).toInt();

    if (widget.paymentMethod == "الدفع بالبطاقة") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentTestPage(
            orderId: orderId,
            amount: (widget.total + deliveryFee).toInt(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم إرسال الطلب بنجاح')),
      );

      final role = await SessionStore.role();
      if (!mounted) return;

      if (role == 'seller') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SupplierDashboard()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ملخص الطلب'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🗺️ كرت الموقع
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طريقة الدفع: ${widget.paymentMethod}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (_loadingAddress)
                        const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('جاري جلب الموقع...'),
                          ],
                        )
                      else if (_address != null)
                        Text(
                          'الموقع: $_address',
                          style: const TextStyle(fontSize: 15),
                        )
                      else
                        Text(
                          'إحداثيات الموقع: ${widget.location.latitude.toStringAsFixed(5)}, ${widget.location.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(fontSize: 15),
                        ),
                    ],
                  ),
                ),
              ),

              // 💰 كرت الفاتورة
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تفاصيل الفاتورة',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('القطعة')),
                            DataColumn(label: Text('الكمية')),
                            DataColumn(label: Text('السعر')),
                            DataColumn(label: Text('الإجمالي')),
                          ],
                          rows: widget.items
                              .map(
                                (item) => DataRow(
                                  cells: [
                                    DataCell(Text(item.part.name,
                                        overflow: TextOverflow.ellipsis)),
                                    DataCell(Text(item.quantity.toString())),
                                    DataCell(Text(
                                        item.part.price.toStringAsFixed(2))),
                                    DataCell(Text(
                                        (item.part.price * item.quantity)
                                            .toStringAsFixed(2))),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (orderProv.loadingDelivery) ...[
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('جاري حساب تكلفة التوصيل...'),
                          ],
                        ),
                      ] else if (orderProv.deliveryPrice != null) ...[
                        const SizedBox(height: 8),
                        Text(
                            'المسافة: ${orderProv.distanceKm!.toStringAsFixed(2)} كم'),
                        const SizedBox(height: 4),
                        Text(
                            'الوقت المقدر: ${orderProv.durationMin!.toStringAsFixed(1)} دقيقة'),
                        const SizedBox(height: 4),
                        Text(
                          'تكلفة التوصيل: ${orderProv.deliveryPrice!.toStringAsFixed(2)} USD',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Row(
                          children: [
                            const Spacer(),
                            const Text(
                              'المجموع مع التوصيل:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              (widget.total + orderProv.deliveryPrice!)
                                  .toStringAsFixed(2),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ] else if (orderProv.deliveryError != null) ...[
                        Text('⚠️ ${orderProv.deliveryError}'),
                      ] else ...[
                        const Text('لا يوجد بيانات للتوصيل'),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSending ? null : () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _confirmOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('تأكيد الطلب'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
