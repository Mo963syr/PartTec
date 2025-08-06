import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyOrdersPage extends StatefulWidget {
  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  List<Map<String, dynamic>> allItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response = await http.get(Uri.parse(
        'https://parttec.onrender.com/order/viewuserorder/687ff5a6bf0de81878ed94f5'));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List orders = jsonBody['orders'];
      final List<Map<String, dynamic>> items = [];

      for (var order in orders) {
        final cartIds = order['cartIds'] as List;
        for (var cart in cartIds) {
          final part = cart['partId'];
          if (part != null) {
            items.add({
              'id': cart['_id'],
              'name': part['name'],
              'image': part['imageUrl'],
              'status': cart['status'],
              'price': part['price'],
              'canCancel': cart['status'] == 'قيد التجهيز',
            });
          }
        }
      }

      setState(() {
        allItems = items;
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> filterByStatus(String status) {
    return allItems.where((item) => item['status'] == status).toList();
  }

  Future<void> cancelOrder(String id) async {
    // TODO: نفذ عملية الإلغاء من السيرفر إذا توفر Endpoint لذلك
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ تم طلب إلغاء الطلب $id (تجريبي)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('طلباتي'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'قيد التجهيز'),
            Tab(text: 'على الطريق'),
            Tab(text: 'تم التوصيل'),
            Tab(text: 'ملغاة'),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                buildList(filterByStatus('قيد التجهيز')),
                buildList(filterByStatus('على الطريق')),
                buildList(filterByStatus('تم التوصيل')),
                buildList(filterByStatus('ملغاة')),
              ],
            ),
    );
  }

  Widget buildList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return Center(child: Text('لا توجد طلبات'));

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Card(
          margin: EdgeInsets.all(10),
          child: ListTile(
            leading: Image.network(item['image'], width: 50, fit: BoxFit.cover),
            title: Text(item['name']),
            subtitle: Text('${item['price']} \$'),
            trailing: item['canCancel']
                ? TextButton(
                    child: Text('إلغاء', style: TextStyle(color: Colors.red)),
                    onPressed: () => cancelOrder(item['id']),
                  )
                : Text(item['status'], style: TextStyle(color: Colors.grey)),
          ),
        );
      },
    );
  }
}
