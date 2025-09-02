import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../home/home_page.dart';
import 'my_order_page.dart';

/// صفحة تعرض ملخص الطلب قبل تأكيده. يتم عرض الفاتورة بشكل مرتب
/// مع جدول يوضح القطع والكمية والسعر والإجمالي لكل قطعة. كما يتم
/// عرض طريقة الدفع والموقع المختار. عند الضغط على "تأكيد"، يتم إرسال
/// الطلب إلى الخادم وبعد النجاح يتم الانتقال إلى صفحة "طلباتي".
class OrderSummaryPage extends StatefulWidget {
  final List<CartItem> items;
  final double total;
  final LatLng location;
  final String paymentMethod;

  const OrderSummaryPage({
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
  }

  /// يجلب اسم المنطقة من إحداثيات موقع المستخدم باستخدام خدمة Nominatim.
  Future<void> _fetchAddress() async {
    final lat = widget.location.latitude;
    final lon = widget.location.longitude;
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=jsonv2');
      final response = await http.get(uri, headers: {
        // إضافة User-Agent لتجنب حظر الطلب
        'User-Agent': 'parttec-app/1.0 (https://example.com)'
      });
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

  /// إرسال الطلب إلى الخادم مع إحداثيات الموقع. في حال النجاح يتم تفريغ السلة
  /// والانتقال إلى صفحة الطلبات الخاصة بالمستخدم.
  Future<void> _confirmOrder() async {
    setState(() {
      _isSending = true;
    });
    final orderProvider = context.read<OrderProvider>();
    final coords = [widget.location.longitude, widget.location.latitude];
    await orderProvider.sendOrder(coords);

    if (!mounted) return;
    if (orderProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orderProvider.error!)),
      );
      setState(() {
        _isSending = false;
      });
      return;
    }

    // تحديث السلة بعد إرسال الطلب
    await context.read<CartProvider>().fetchCartFromServer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم إرسال الطلب بنجاح')),
    );

    // الانتقال إلى الصفحة الرئيسية وإزالة كل الصفحات السابقة
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              // جدول الفاتورة
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
                                    DataCell(Text(
                                        item.part.name,
                                        overflow: TextOverflow.ellipsis)),
                                    DataCell(Text(item.quantity.toString())),
                                    DataCell(Text(item.part.price
                                        .toStringAsFixed(2))),
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
                      Row(
                        children: [
                          const Spacer(),
                          const Text(
                            'المجموع الكلي:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.total.toStringAsFixed(2),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSending ? null : () => Navigator.pop(context),
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