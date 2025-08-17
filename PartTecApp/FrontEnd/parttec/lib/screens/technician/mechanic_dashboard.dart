import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/mechanic_provider.dart';
import 'mechanic_current_orders_page.dart';
import 'mechanic_order_history_page.dart';
import 'package:flutter/foundation.dart';
import '../../widgets/dev_drawer.dart';

class MechanicDashboard extends StatelessWidget {
  const MechanicDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MechanicProvider()
        ..fetchDiscount()
        ..fetchCurrentOrders()
        ..fetchOrderHistory(),
      child: Scaffold(
        drawer: kDebugMode ? const DevDrawer() : null,
        appBar: AppBar(
          title: const Text('لوحة الفني'),
          centerTitle: true,
        ),
        body: const _MechanicDashboardBody(),
      ),
    );
  }
}

class _MechanicDashboardBody extends StatelessWidget {
  const _MechanicDashboardBody();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MechanicProvider>(context);
    final discount = provider.discountPercentage;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (discount != null)
            Card(
              color: Colors.teal.shade50,
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: const Icon(Icons.local_offer, color: Colors.teal),
                title: Text(
                    'نسبة الخصم الحالية: ${(discount * 100).toStringAsFixed(1)}%'),
                subtitle:
                    const Text('سيتم تطبيق هذه النسبة تلقائياً عند الطلب'),
              ),
            ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 3 / 2,
              children: [
                _buildCard(
                  context,
                  icon: Icons.shopping_bag,
                  title: 'الطلبات الحالية',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MechanicCurrentOrdersPage(),
                      ),
                    );
                  },
                ),
                _buildCard(
                  context,
                  icon: Icons.history,
                  title: 'سجل الطلبات',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MechanicOrderHistoryPage(),
                      ),
                    );
                  },
                ),
                _buildCard(
                  context,
                  icon: Icons.discount,
                  title: 'قطع بأسعار مخفّضة',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'سيتم تطبيق الخصم تلقائياً عند طلب أي قطعة من القائمة الرئيسية'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Icon(icon, size: 50, color: Colors.teal),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
