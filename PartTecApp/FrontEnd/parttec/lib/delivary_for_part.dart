import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'واجهة سائق التوصيل',
      debugShowCheckedModeBanner: false,
      home: const DriverHomePage(),
    );
  }
}

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});
  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  List<Map<String, dynamic>> orders = [
    {
      'id': '١',
      'customerId': 'C123',
      'partName': 'موتور سيارة',
      'image': null,
      'price': 150,
      'payment': 'كاش',
      'address': 'شارع ١، مدينتك',
      'status': 'وارد',
      'cancelReason': null,
    },
    {
      'id': '٢',
      'customerId': 'C456',
      'partName': 'بطارية',
      'image': null,
      'price': 200,
      'payment': 'الكتروني',
      'address': 'شارع ٢، مدينتك',
      'status': 'وارد',
      'cancelReason': null,
    },
    // المزيد من الطلبات حسب الحاجة...
  ];

  void _updateStatus(int index, String newStatus, {String? reason}) {
    setState(() {
      orders[index]['status'] = newStatus;
      if (reason != null) orders[index]['cancelReason'] = reason;
    });
  }

  Future<String?> _askCancelReason(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('سبب الإلغاء'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'أدخل سبب الإلغاء...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات التوصيل'),
        backgroundColor: const Color(0xFFD8C5AD),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final o = orders[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'رقم العملية: ${o['id']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'رقم الزبون: ${o['customerId']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'اسم القطعة: ${o['partName']}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: o['image'] != null
                        ? Image.network(o['image'], fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'السعر: ${o['price']} ل.س • الدفع: ${o['payment']}',
                  style: const TextStyle(fontSize: 13, color: Colors.green),
                ),
                const SizedBox(height: 8),
                Text(
                  'عنوان التوصيل: ${o['address']}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: o['status'] == 'وارد'
                          ? () async {
                              final reason = await _askCancelReason(context);
                              if (reason != null && reason.isNotEmpty) {
                                _updateStatus(index, 'ملغي', reason: reason);
                              }
                            }
                          : null,
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: o['status'] == 'وارد'
                            ? Colors.orange
                            : o['status'] == 'تم الاستلام'
                                ? Colors.blue
                                : Colors.grey,
                      ),
                      onPressed: (o['status'] == 'وارد' || o['status'] == 'تم الاستلام')
                          ? () {
                              if (o['status'] == 'وارد') {
                                _updateStatus(index, 'تم الاستلام');
                              } else {
                                _updateStatus(index, 'تم التوصيل');
                              }
                            }
                          : null,
                      child: Text(
                        o['status'] == 'وارد'
                            ? 'موافقة'
                            : o['status'] == 'تم الاستلام'
                                ? 'توصيل'
                                : 'تم التوصيل',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'الحالة: ${o['status']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: o['status'] == 'وارد'
                        ? Colors.blueAccent
                        : o['status'] == 'تم الاستلام'
                            ? Colors.orange
                            : o['status'] == 'تم التوصيل'
                                ? Colors.green
                                : Colors.red,
                  ),
                ),
                if (o['cancelReason'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'سبب الإلغاء: ${o['cancelReason']}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
