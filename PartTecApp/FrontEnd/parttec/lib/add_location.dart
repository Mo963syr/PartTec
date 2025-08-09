import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'providers/order_provider.dart'; // تأكد من المسار الصحيح

class LocationPickerPage extends StatefulWidget {
  final String userId;

  const LocationPickerPage({required this.userId, Key? key}) : super(key: key);

  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? selectedLocation;

  final mapController = MapController();
  final initialCenter = LatLng(33.5138, 36.2765);

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('تحديد الموقع')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: initialCenter,
              zoom: 13.0,
              onTap: (tapPosition, latlng) {
                setState(() {
                  selectedLocation = latlng;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80,
                      height: 80,
                      point: selectedLocation!,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (selectedLocation != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () async {
                  final coords = [
                    selectedLocation!.longitude,
                    selectedLocation!.latitude,
                  ];

                  await orderProvider.sendOrder(coords);

                  if (orderProvider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(orderProvider.error!)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ تم إرسال الطلب بنجاح')),
                    );
                    Navigator.of(context).pop(); // العودة بعد الإرسال
                  }
                },
                child: orderProvider.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('تأكيد وإرسال الطلب'),
              ),
            ),
        ],
      ),
    );
  }
}
