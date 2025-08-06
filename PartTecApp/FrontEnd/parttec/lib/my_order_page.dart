import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyOrdersPage extends StatefulWidget {
  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> groupedOrders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response = await http.get(Uri.parse(
        'https://parttec.onrender.com/order/viewuserorder/687ff5a6bf0de81878ed94f5'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List orders = data['orders'];
      groupedOrders = orders.map<Map<String, dynamic>>((order) {
        final List cartItems = order['cartIds'];
        return {
          'orderId': order['_id'],
          'status': order['status'],
          'items': cartItems.map<Map<String, dynamic>>((cart) {
            final part = cart['partId'];
            return {
              'name': part['name'] ?? 'اسم غير معروف',
              'image': part['imageUrl'],
              'price': part['price'],
              'status': cart['status'],
              'canCancel': order['status'] == 'قيد التجهيز',
              'cartId': cart['_id'],
            };
          }).toList(),
          'expanded': false,
        };
      }).toList();

      setState(() => isLoading = false);
    }
  }

  Future<void> cancelOrder(String cartId) async {
    // TODO: تنفيذ عملية الإلغاء من السيرفر إذا توفر endpoint
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ تم طلب إلغاء الطلب $cartId (تجريبي)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلباتي')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: groupedOrders.length,
        itemBuilder: (context, index) {
          final order = groupedOrders[index];
          final isExpanded = order['expanded'] as bool;
          final status = order['status'];
          final items = order['items'] as List;

          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.receipt, color: Colors.blue),
                  title: Text('طلب رقم: ${order['orderId']}'),
                  subtitle: Text('الحالة: $status'),
                  trailing: IconButton(
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onPressed: () {
                      setState(() {
                        order['expanded'] = !isExpanded;
                      });
                    },
                  ),
                ),
                if (isExpanded)
                  AnimatedSize(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];
                        return ListTile(
                          leading: Image.network(
                            item['image'] ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.image_not_supported),
                          ),
                          title: Text(item['name']),
                          subtitle:
                          Text('السعر: \$${item['price'].toString()}'),
                          trailing: item['canCancel']
                              ? TextButton(
                            onPressed: () =>
                                cancelOrder(item['cartId']),
                            child: Text('إلغاء',
                                style:
                                TextStyle(color: Colors.red)),
                          )
                              : Text(item['status'],
                              style: TextStyle(color: Colors.grey)),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
