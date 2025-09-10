import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:parttec/screens/order/my_order_page.dart';
import 'package:parttec/providers/purchases_provider.dart';
import 'package:parttec/screens/employee/DeliveryDashboard.dart';
import 'package:parttec/providers/partprivate_provider.dart';
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
import 'providers/user_provider.dart';
import 'screens/home/home_page.dart';
import 'screens/supplier/supplier_dashboard.dart';
import 'utils/session_store.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("📩 رسالة بالخلفية: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  const AndroidInitializationSettings initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: initSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
        ChangeNotifierProvider(create: (_) => RecommendationsProvider()),
        ChangeNotifierProvider(create: (_) => PurchasesProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _showNotification(notification.title, notification.body);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final role = await SessionStore.role();
      if (!mounted) return;

      if (role == 'seller') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SupplierDashboard()),
        );
      } else if (role == 'user') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyOrdersPage()),
        );
      }
    });
  }

  void _showNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'orders_channel',
      'Orders Notifications',
      channelDescription: 'تنبيهات الطلبات',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title ?? 'إشعار جديد',
      body ?? 'تم استلام طلب جديد 🚀',
      platformDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PartTec',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashPage(),
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
        case 'delevery':
          next = const DeliveryDashboard();
          break;
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
