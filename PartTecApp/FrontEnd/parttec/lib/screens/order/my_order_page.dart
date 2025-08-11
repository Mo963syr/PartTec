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

  List<Map<String, dynamic>> _parseAndMapOrders(String responseBody, {bool isSpecific = false}) {
    final dynamic decodedData = json.decode(responseBody);
    List<dynamic> rawOrdersList = [];

    if (decodedData == null) {
      print('MyOrdersPage: Decoded data is null. Response body: $responseBody');
      return [];
    }

    if (isSpecific) {

      if (decodedData is Map<String, dynamic> && decodedData.containsKey('orders')) {
        final orders = decodedData['orders'];
        if (orders is List) {
          rawOrdersList = orders;
        } else {
          print('MyOrdersPage: "orders" key found but its value is not a List in specific orders response. Value: $orders');
        }
      } else {
        print('MyOrdersPage: "orders" key not found or decodedData is not a Map in specific orders response. Data: $decodedData');
      }
    } else {

      if (decodedData is Map<String, dynamic> && decodedData.containsKey('orders')) {
         final orders = decodedData['orders'];
        if (orders is List) {
          rawOrdersList = orders;
        } else {
            print('MyOrdersPage: "orders" key found but value is not a List in regular orders response. Value: $orders');
        }
      } else if (decodedData is List) {
        rawOrdersList = decodedData;
      } else {
         print('MyOrdersPage: "orders" key not found or decodedData is not Map/List in regular orders response. Data: $decodedData');
      }
    }

    if (rawOrdersList.isEmpty) {
      return [];
    }

    return rawOrdersList
        .map<Map<String, dynamic>?>((orderData) {
          if (orderData is! Map<String, dynamic>) {
            print('MyOrdersPage: Skipping non-map orderData: $orderData');
            return null;
          }

          if (isSpecific) {

            String itemConditionStatus = orderData['status'] as String? ?? 'غير محدد';
            String orderProcessingStatus = 'طلب خاص';

            List<Map<String, dynamic>> items = [
              {
                'name': orderData['name'] as String? ?? 'اسم غير معروف',
                'image': orderData['imageUrl'] as String?,
                'price': orderData['price'],
                'status': itemConditionStatus,
                'canCancel': false,
                'cartId': orderData['_id'] as String? ?? '',
              }
            ];

            return {
              'orderId': orderData['_id'] as String? ?? 'معرف غير متوفر',
              'status': orderData['status'],
              'items': items,
              'expanded': false,
            };
          } else {

            final List<dynamic> itemSourceListRaw = orderData['cartIds'] ?? orderData['items'] ?? [];
            List<Map<String, dynamic>> mappedItems = [];

            if (itemSourceListRaw is List) {
              mappedItems = itemSourceListRaw
                  .map<Map<String, dynamic>?>((itemJson) {
                    if (itemJson is! Map<String, dynamic>) return null;

                    final dynamic partDataSource = itemJson['partId'] ?? itemJson;
                    if (partDataSource is! Map<String, dynamic>) return null;

                    return {
                      'name': partDataSource['name'] as String? ?? 'اسم غير معروف',
                      'image': partDataSource['imageUrl'] as String?,
                      'price': partDataSource['price'],
                      'status': itemJson['status'] as String? ?? orderData['status'] as String? ?? 'غير متوفر',
                      'canCancel': (orderData['status'] == 'قيد التجهيز'),
                      'cartId': itemJson['_id'] as String? ?? '',
                    };
                  })
                  .where((item) => item != null)
                  .cast<Map<String, dynamic>>()
                  .toList();
            }

            return {
              'orderId': orderData['_id'] as String? ?? 'معرف غير متوفر',
              'status': orderData['status'] as String? ?? 'حالة غير معروفة',
              'items': mappedItems,
              'expanded': false,
            };
          }
        })
        .where((order) => order != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  Future<void> fetchOrders() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    List<Map<String, dynamic>> combinedOrders = [];
    String? errorMessage;

    try {

      final response1 = await http.get(Uri.parse(
          'https://parttec.onrender.com/order/viewuserorder/687ff5a6bf0de81878ed94f5'));
      if (response1.statusCode == 200) {
        combinedOrders.addAll(_parseAndMapOrders(response1.body, isSpecific: false));
      } else {
        print('MyOrdersPage: Failed to load regular orders: ${response1.statusCode}');
        errorMessage = 'فشل تحميل الطلبات العادية: ${response1.statusCode}';
      }


      final response2 = await http.get(Uri.parse(
          'https://parttec.onrender.com/order/viewuserspicificorder/687ff5a6bf0de81878ed94f5'));
      if (response2.statusCode == 200) {
        combinedOrders.addAll(_parseAndMapOrders(response2.body, isSpecific: true));
      } else {
        print('MyOrdersPage: Failed to load specific orders: ${response2.statusCode}');
        errorMessage = (errorMessage == null ? '' : '$errorMessage\n') +
                       'فشل تحميل الطلبات المخصصة: ${response2.statusCode}';
      }
    } catch (e) {
      print('MyOrdersPage: Error fetching orders: $e');
      errorMessage = 'حدث خطأ أثناء جلب الطلبات: $e';
    }

    if (mounted) {
      if (errorMessage != null && combinedOrders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      setState(() {
        groupedOrders = combinedOrders;
        isLoading = false;
      });
    }
  }

  Future<void> cancelOrder(String cartId) async {

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
          : groupedOrders.isEmpty
              ? Center(child: Text('لا توجد طلبات لعرضها حاليًا.'))
              : ListView.builder(
                  itemCount: groupedOrders.length,
                  itemBuilder: (context, index) {
                    final order = groupedOrders[index];
                    final isExpanded = order['expanded'] as bool;

                    final status = order['status'] as String? ?? 'غير معروف';
                    final items = order['items'] as List<Map<String,dynamic>>;

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
                            title: Text('طلب رقم: ${index + 1}'), // Using local index as per previous request
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

                                  final itemDisplayStatus = item['status'] as String? ?? 'غير متوفر';
                                  final canCancelItem = item['canCancel'] as bool? ?? false;

                                  return ListTile(
                                    leading: item['image'] != null
                                        ? Image.network(
                                            item['image'] as String,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Icon(Icons.broken_image, color: Colors.grey[300]),
                                          )
                                        : Icon(Icons.image_not_supported, color: Colors.grey[300]),
                                    title: Text(item['name'] as String? ?? 'اسم غير معروف'),
                                    subtitle: Text('السعر: ${item['price'] != null ? '\$${item['price']}' : 'غير متوفر'}'),
                                    trailing: canCancelItem
                                        ? TextButton(
                                            onPressed: () =>
                                                cancelOrder(item['cartId'] as String? ?? ''),
                                            child: Text('إلغاء',
                                                style:
                                                TextStyle(color: Colors.red)),
                                          )
                                        : Text(itemDisplayStatus,
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
