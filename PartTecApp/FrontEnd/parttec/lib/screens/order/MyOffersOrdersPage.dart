import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_settings.dart';
import '../../utils/session_store.dart';

class MyOffersOrdersPage extends StatefulWidget {
  const MyOffersOrdersPage({super.key});

  @override
  State<MyOffersOrdersPage> createState() => _MyOffersOrdersPageState();
}

class _MyOffersOrdersPageState extends State<MyOffersOrdersPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> grouped = [];
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => isLoading = true);
    try {
      final uid = await SessionStore.userId();
      if (uid == null || uid.isEmpty) {
        setState(() {
          errorMsg = "⚠️ يرجى تسجيل الدخول أولاً.";
          isLoading = false;
        });
        return;
      }

      final url = Uri.parse("${AppSettings.serverurl}/order/viewuserspicificorder/$uid");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final rawOrders = decoded['orders'] as List?;
        if (rawOrders != null) {
          grouped = rawOrders.map<Map<String, dynamic>>((o) {
            final map = Map<String, dynamic>.from(o);
            return {
              "orderId": map['_id'] ?? "",
              "status": map['status'] ?? "غير معروف",
              "expanded": false,
              "items": [
                {
                  "name": map['name'] ?? "اسم غير معروف",
                  "image": map['imageUrl'],
                  "price": map['price'],
                  "status": map['status'],
                  "imageUrls": map['imageUrls'],
                  "canCancel": false,
                  "cartId": map['_id'] ?? "",
                  "manufacturer": map['manufacturer'] ?? "غير معروف",
                  "model": map['model'] ?? "غير معروف",
                  "year": map['year']?.toString() ?? "-",
                  "notes": map['notes'] ?? "لا يوجد",
                  "count": map['count']?.toString() ?? "0",
                }


            ],
            };
          }).toList();
        }
      } else {
        errorMsg = "فشل التحميل (${res.statusCode})";
      }
    } catch (e) {
      errorMsg = "خطأ: $e";
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white, // ✅ خلفية الصفحة كلها بيضاء
        appBar: AppBar(
          title: const Text("طلباتي"),
          backgroundColor: AppColors.primary,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMsg != null
            ? Center(child: Text(errorMsg!))
            : grouped.isEmpty
            ? const Center(child: Text("لا توجد طلبات"))
            : RefreshIndicator(
          onRefresh: _fetch,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: grouped.length,
            itemBuilder: (_, i) {
              final order = grouped[i];
              return _OrderCard(
                orderId: order['orderId'],
                index: i,
                status: order['status'],
                expanded: order['expanded'],
                items: order['items'],
                manufacturer: order['manufacturer'] ?? '-',
                model: order['model'] ?? '-',
                year: order['year']?.toString() ?? '-',
                notes: order['notes'] ?? '-',
                count: order['count']?.toString() ?? '0',
                onToggle: (v) => setState(() => order['expanded'] = v),
                onCancel: (_) {},
              );

            },
          ),
        ),
      ),
    );
  }
}
class _OrderCard extends StatelessWidget {
  final String orderId;
  final int index;
  final String status;
  final bool expanded;
  final List<Map<String, dynamic>> items;
  final String manufacturer;
  final String model;
  final String year;
  final String notes;
  final String count;
  final ValueChanged<bool> onToggle;
  final void Function(String cartId) onCancel;

  const _OrderCard({
    required this.orderId,
    required this.index,
    required this.status,
    required this.expanded,
    required this.items,
    required this.manufacturer,
    required this.model,
    required this.year,
    required this.notes,
    required this.count,
    required this.onToggle,
    required this.onCancel,
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        title: Text("الطلب رقم ${index + 1} - $status"),
        initiallyExpanded: expanded,
        onExpansionChanged: (open) {
          onToggle(open);
          if (open && orderId.isNotEmpty) {
            context.read<OrderProvider>().fetchOffersForOrder(orderId);
          }
        },
        children: [
          ...items.map((item) {
            final img = (item['image'] ??
                (item['imageUrls'] != null &&
                    item['imageUrls'] is List &&
                    item['imageUrls'].isNotEmpty
                    ? item['imageUrls'][0]
                    : null))
                ?.toString();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.grey, width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (img != null && img.isNotEmpty)
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        img,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported, size: 50),
                      ),
                    )
                        : const Icon(Icons.image_not_supported, size: 50),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("الاسم: ${item['name'] ?? 'غير معروف'}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("السعر: ${item['price'] ?? 'غير محدد'}"),
                          Text("الصانع: ${item['manufacturer'] ?? '-'}"),
                          Text("الموديل: ${item['model'] ?? '-'}"),
                          Text("السنة: ${item['year'] ?? '-'}"),
                          Text("الملاحظات: ${item['notes'] ?? '-'}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Consumer<OrderProvider>(
              builder: (_, prov, __) {
                final loading = prov.isLoadingOffers(orderId);
                final offers = prov.offersFor(orderId);

                if (loading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (offers.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(child: Text('لا توجد عروض حالياً لهذا الطلب')),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                      child: Text(
                        "العروض المتاحة:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    ...offers.map((offer) {
                      final offerId = (offer['_id'] ??
                          offer['id'] ??
                          offer['offerId'] ??
                          '')
                          .toString();
                      final desc = (offer['description'] ?? 'عرض').toString();
                      final price = (offer['price'] ?? 'غير محدد').toString();
                      final image = (offer['imageUrl'] ?? '').toString();
                      final supplier =
                      (offer['supplierName'] ?? 'مورد').toString();

                      return ListTile(
                        leading: image.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            image,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.local_offer,
                                color: AppColors.primary),
                          ),
                        )
                            : const Icon(Icons.local_offer,
                            color: AppColors.primary),
                        title: Text(desc),
                        subtitle: Text('السعر: $price — $supplier'),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            final ok = await context
                                .read<OrderProvider>()
                                .addOfferToCart(offerId, orderId);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(ok
                                  ? '✅ تمت إضافة العرض إلى السلة'
                                  : (context.read<OrderProvider>().offersError ??
                                  'فشل إضافة العرض')),
                            ));
                          },
                          child: const Text('إضافة للسلة'),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
