import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:parttec/screens/location/ChooseDestinationPage.dart';
import 'package:parttec/screens/supplier/supplier_dashboard.dart';
import 'package:provider/provider.dart';
=======
>>>>>>> 42278ae668a851ae06fc44c93a95a4bbd2d7aab5

import 'providers/cart_provider.dart';
import 'providers/home_provider.dart';
import 'providers/parts_provider.dart';
import 'providers/add_part_provider.dart';
import 'package:provider/provider.dart';
import '/providers/seller_orders_provider.dart';

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
          create: (_) =>
              SellerOrdersProvider('68761cf7f92107b8288158c2')..fetchOrders(),
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
<<<<<<< HEAD
      title: 'PartTec',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
      ),
      home: ChooseDestinationPage(),
    );
=======
        title: 'PartTec',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ChooseDestinationPage());
>>>>>>> 42278ae668a851ae06fc44c93a95a4bbd2d7aab5
  }
}
