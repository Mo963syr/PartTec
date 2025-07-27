import 'package:flutter/material.dart';
import 'package:parttec/supplier_dashboard.dart';
import 'home_page.dart';
import 'providers/home_provider.dart';
import 'providers/parts_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PartsProvider()),
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
