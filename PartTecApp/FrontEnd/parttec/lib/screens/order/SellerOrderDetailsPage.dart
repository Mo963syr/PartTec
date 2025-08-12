import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/seller_orders_provider.dart';
import 'order_item_details_page.dart'; // <-- الصفحة الجديدة

class SellerOrderDetailsPage extends StatelessWidget {
  final String customerName;
  final List<Map<String, dynamic>> orders;

  const SellerOrderDetailsPage({
    Key? key,
    required this.customerName,
    required this.orders,
  }) : super(key: key);

  double _numToDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final order = orders.isNotEmpty ? orders.first : <String, dynamic>{};

    final orderId = (order['orderId'] ?? '').toString();
    final status = (order['status'] ?? '').toString();
    final createdAt = _fmtDate((order['createdAt'] ?? '').toString());

    final List<Map<String, dynamic>> items = ((order['items'] as List?) ?? [])
        .map<Map<String, dynamic>>((e) => (e as Map).cast<String, dynamic>())
        .toList();

    final totalAmount = (order['totalAmount'] != null)
        ? _numToDouble(order['totalAmount'])
        : items.fold<double>(0.0, (s, it) => s + _numToDouble(it['total']));

    // أخفي الأزرار إذا الطلب "على الطريق"
    final shouldShowActions = status != 'على الطريق';

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الطلب')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الزبون: $customerName',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  if (orderId.isNotEmpty) Text('رقم الطلب: $orderId'),
                  if (status.isNotEmpty) Text('الحالة الحالية: $status'),
                  if (createdAt.isNotEmpty) Text('التاريخ: $createdAt'),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Text('إجمالي المبلغ:',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(totalAmount.toStringAsFixed(2)),
                    ],
                  ),
                  if (shouldShowActions) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            await context
                                .read<SellerOrdersProvider>()
                                .updateStatus(orderId, 'على الطريق', context);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.local_shipping_outlined),
                          label: const Text('على الطريق'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await context
                                .read<SellerOrdersProvider>()
                                .updateStatus(orderId, 'ملغي', context);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('إلغاء'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.list_alt),
                const SizedBox(width: 6),
                Text('العناصر (${items.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          ...items.map((it) {
            final name = (it['name'] ?? 'بدون اسم').toString();
            final img = (it['imageUrl'] ?? '').toString();
            final qty = _numToDouble(it['quantity']).toInt();
            final price = _numToDouble(it['price']);
            final total = it['total'] != null
                ? _numToDouble(it['total'])
                : (price * qty);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: img.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    img,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
                  ),
                )
                    : const CircleAvatar(child: Icon(Icons.build)),
                title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (price > 0) Text('السعر: ${price.toStringAsFixed(2)}'),
                    Text('الكمية: $qty'),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('الإجمالي',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(total.toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderItemDetailsPage(item: it),
                    ),
                  );
                },
              ),
            );
          }).toList(),

          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('لا توجد عناصر في هذا الطلب')),
            ),
        ],
      ),
    );
  }
}
