import 'package:flutter/material.dart';
import 'DeliveryMapPage.dart';

class DeliveryOrdersPage extends StatelessWidget {
  final List<Map<String, dynamic>> confirmedOrders = [
    {
      'id': '1',
      'customerName': 'أحمد محمد',
      'status': 'مؤكد',
      'location': {'lat': 33.5138, 'lng': 36.2765}
    },
    {
      'id': '2',
      'customerName': 'ليلى خالد',
      'status': 'مؤكد',
      'location': {'lat': 33.5120, 'lng': 36.2900}
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الطلبات المؤكدة')),
      body: ListView.builder(
        itemCount: confirmedOrders.length,
        itemBuilder: (context, index) {
          final order = confirmedOrders[index];
          return Card(
            margin: EdgeInsets.all(12),
            child: ListTile(
              leading: Icon(Icons.location_on, color: Colors.teal),
              title: Text(order['customerName']),
              subtitle: Text('طلب رقم: ${order['id']}'),
              trailing: Icon(Icons.map),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeliveryMapPage(
                      lat: order['location']['lat'],
                      lng: order['location']['lng'],
                      customerName: order['customerName'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
