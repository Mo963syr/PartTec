import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../providers/delivery_staff_provider.dart';

class DeliveryOrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const DeliveryOrderDetailsPage({Key? key, required this.order})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lat = order['lat'] is double ? order['lat'] : 0.0;
    final lng = order['lng'] is double ? order['lng'] : 0.0;
    final latLng = LatLng(lat, lng);
    final status = order['status']?.toString() ?? '';
    return Scaffold(
      appBar: AppBar(title: Text('تفاصيل الطلب ${order['id']}')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('العميل: ${order['customerName'] ?? ''}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('العنوان: ${order['address'] ?? ''}'),
                const SizedBox(height: 8),
                Text('الحالة الحالية: $status'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(
                      center: latLng,
                      zoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80,
                            height: 80,
                            point: latLng,
                            child: const Icon(Icons.location_on,
                                color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Consumer<DeliveryStaffProvider>(
            builder: (context, provider, _) {
              final isReady = status == 'تجهيز';
              final inTransit = status == 'قيد التوصيل';
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (isReady)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange),
                          onPressed: () async {
                            await provider
                                .confirmPickup(order['id'].toString());
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('تأكيد الاستلام'),
                        ),
                      ),
                    if (inTransit)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: () async {
                            await provider
                                .confirmDelivery(order['id'].toString());
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.done_all),
                          label: const Text('تأكيد التسليم'),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
