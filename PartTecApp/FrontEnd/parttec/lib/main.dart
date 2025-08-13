import 'package:flutter/material.dart';
import 'package:parttec/providers/recommendations_provider.dart';
import 'package:parttec/screens/location/ChooseDestinationPage.dart';
import 'package:parttec/screens/order/recommendation_orders_page.dart';
import 'package:provider/provider.dart';
import 'providers/home_provider.dart';
import 'providers/parts_provider.dart';
import 'providers/add_part_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/seller_orders_provider.dart';
import 'providers/order_provider.dart';
import 'providers/reviews_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PartsProvider()),
        ChangeNotifierProvider(create: (_) => AddPartProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(
          create: (_) => RecommendationsProvider('6891009147d76ee5e1b22647'),
          child: RecommendationOrdersPage(),
        ),
        ChangeNotifierProvider(create: (_) => ReviewsProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              SellerOrdersProvider('68761cf7f92107b8288158c2')..fetchOrders(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PartTec',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
      ),
      home: ChooseDestinationPage(),
    );
  }
}
