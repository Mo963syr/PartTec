import 'package:flutter/material.dart';
import 'package:parttec/supplier_dashboard.dart';
import 'home_page.dart';
import 'package:parttec/seller_orders_page.dart';
import 'package:parttec/GroupedOrdersPage.dart';
import 'providers/cart_provider.dart';
import 'providers/home_provider.dart';
import 'providers/parts_provider.dart';
import 'providers/add_part_provider.dart';
import 'package:provider/provider.dart';
import 'package:parttec/providers/seller_orders_provider.dart';
import 'package:parttec/ChooseDestinationPage.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PartsProvider()),
        ChangeNotifierProvider(create: (_) => AddPartProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => SellerOrdersProvider('68761cf7f92107b8288158c2') // ← غيّر الـ ID حسب البائع
            ..fetchOrders(),
        ),
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
      home: ChooseDestinationPage(),
    );
  }
}
