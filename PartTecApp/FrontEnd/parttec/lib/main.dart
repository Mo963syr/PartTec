import 'package:flutter/material.dart';
import 'package:parttec/supplier_dashboard.dart';
import 'home_page.dart';
<<<<<<< HEAD
=======
import 'providers/home_provider.dart';
import 'providers/parts_provider.dart';
import 'providers/add_part_provider.dart';
>>>>>>> ffb5cc40757eb2566b68f9316a4cc8a9373758de
import 'package:provider/provider.dart';
import 'providers/home_provider.dart';
import 'supplier_dashboard.dart';
void main() {

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PartsProvider()),
        ChangeNotifierProvider(create: (_) => AddPartProvider()),
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
