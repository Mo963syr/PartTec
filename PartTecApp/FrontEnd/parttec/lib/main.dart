import 'package:flutter/material.dart';
import 'package:parttec/screens/employee/DeliveryDashboard.dart';
import 'package:provider/provider.dart';

import 'package:parttec/providers/recommendations_provider.dart';

import 'providers/home_provider.dart';
import 'providers/parts_provider.dart';
import 'providers/add_part_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/seller_orders_provider.dart';
import 'providers/order_provider.dart';
import 'providers/reviews_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/delivery_orders_provider.dart';

import 'theme/app_theme.dart';
import 'screens/auth/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthProvider();
  await auth.loadSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => AddPartProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PartsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ReviewsProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final uid = auth.userId ?? '';
            return RecommendationsProvider(uid);
          },
        ),
        ChangeNotifierProvider(
          create: (_) => SellerOrdersProvider()..fetchOrders(),
        ),
        ChangeNotifierProvider(
          create: (_) => DeliveryOrdersProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

//
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PartTec',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AuthPage(),
    );
  }
}
