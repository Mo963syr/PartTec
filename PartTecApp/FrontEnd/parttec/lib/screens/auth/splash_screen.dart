import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../home/home_page.dart';
import '../technician/mechanic_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../employee/DeliveryDashboard.dart';
import '../supplier/supplier_dashboard.dart';
import 'auth_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.userId == null && auth.role == null) {
      await auth.loadSession();
    }
    final role = auth.role;
    final uid = auth.userId;
    Widget target;
    if (role == null || uid == null || role == 'guest' || uid == 'guest') {
      target = const AuthPage();
    } else {
      switch (role) {
        case 'user':
          target = const HomePage();
          break;
        case 'mechanic':
          target = const MechanicDashboard();
          break;
        case 'delivery':
          target = const DeliveryDashboard();
          break;
        case 'supplier':
          target = const SupplierDashboard();
          break;
        case 'admin':
          target = const AdminDashboard();
          break;
        default:
          target = const AuthPage();
          break;
      }
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.car_repair,
                size: 64,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'PartTec',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
