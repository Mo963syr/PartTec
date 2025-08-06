import 'package:flutter/material.dart';
import 'package:parttec/supplier_dashboard.dart';
import 'home_page.dart';
import 'package:parttec/groupedorderspage.dart'; // تأكد من وجود هذا الملف

class ChooseDestinationPage extends StatelessWidget {
  const ChooseDestinationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختر الصفحة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.home),
              label: Text('الذهاب إلى الصفحة الرئيسية'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.list_alt),
              label: Text('صفحة البائع'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SupplierDashboard()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
