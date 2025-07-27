import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:provider/provider.dart';
import 'providers/home_provider.dart';
import 'supplier_dashboard.dart';
void main() {

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PartTec',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SupplierDashboard(),
    );
  }
}
