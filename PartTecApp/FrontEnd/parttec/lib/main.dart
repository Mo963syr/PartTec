import 'package:flutter/material.dart';
import 'package:parttec/providers/purchases_provider.dart';
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
import 'screens/home/home_page.dart';
import 'screens/supplier/supplier_dashboard.dart';
// import 'screens/delivery/delivery_orders_page.dart';
// import 'screens/admin/admin_dashboard.dart';
import 'utils/session_store.dart';

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
        ChangeNotifierProvider(create: (_) => DeliveryOrdersProvider()),
        ChangeNotifierProvider(create: (_) => SellerOrdersProvider()),
        ChangeNotifierProvider(create: (_) => PartRatingProvider()),
        ChangeNotifierProvider(
          create: (_) => RecommendationsProvider(auth.userId ?? ''),
        ),
        ChangeNotifierProvider(create: (_) => PurchasesProvider()),
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
      theme: buildAppTheme(),
      home: const SplashPage(), // ✅ بدلنا AuthPage بـ SplashPage
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final userId = await SessionStore.userId();
    final role = await SessionStore.role();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (userId == null || role == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
      );
    } else {
      Widget next;
      switch (role) {
        case 'seller':
          next = const SupplierDashboard();
          break;
        case 'delevery': // نفس الاسم المكتوب بالباك
          next = const DeliveryDashboard();
          break;
        // case 'admin':
        //   next = const AdminDashboard();
        //   break;
        default:
          next = const HomePage();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => next),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
