import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/home/home_page.dart';
import '../screens/technician/mechanic_dashboard.dart';
import '../screens/employee/DeliveryDashboard.dart';
import '../screens/supplier/supplier_dashboard.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/auth/auth_page.dart';

class DevDrawer extends StatelessWidget {
  const DevDrawer({super.key});

  void _go(BuildContext context, Widget page) {
    Navigator.of(context).pop(); // أغلق الدرج أولاً
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    // لو التطبيق في الإصدار (release)، لا تظهر الدرج.
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    final auth = context.read<AuthProvider>();

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            const DrawerHeader(
              child: Text('🔧 Dev Drawer (للـ Debug فقط)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            // أدوار التنقل السريع
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('User (Home)'),
              onTap: () async {
                await auth.debugSetRole('user');
                _go(context, const HomePage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.handyman),
              title: const Text('Mechanic Dashboard'),
              onTap: () async {
                await auth.debugSetRole('mechanic', userId: 'dev-mech');
                _go(context, const MechanicDashboard());
              },
            ),
            ListTile(
              leading: const Icon(Icons.delivery_dining),
              title: const Text('Delivery Dashboard'),
              onTap: () async {
                await auth.debugSetRole('delivery', userId: 'dev-delivery');
                _go(context, const DeliveryDashboard());
              },
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Supplier Dashboard'),
              onTap: () async {
                await auth.debugSetRole('supplier', userId: 'dev-supplier');
                _go(context, const SupplierDashboard());
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Dashboard'),
              onTap: () async {
                await auth.debugSetRole('admin', userId: 'dev-admin');
                _go(context, const AdminDashboard());
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Guest (Home)'),
              onTap: () async {
                await auth.debugSetRole('guest', userId: 'guest');
                _go(context, const HomePage());
              },
            ),
            const Divider(),

            // تسجيل الخروج
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('تسجيل خروج'),
              onTap: () async {
                await auth.logout();
                _go(context, const AuthPage());
              },
            ),
          ],
        ),
      ),
    );
  }
}
