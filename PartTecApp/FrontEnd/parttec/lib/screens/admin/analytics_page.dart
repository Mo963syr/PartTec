import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final analytics = provider.analytics;
        final totalSales = analytics['totalSales'] ?? 0.0;
        final totalOrders = analytics['totalOrders'] ?? 0;
        final discountUsage = analytics['discountUsage'] ?? 0.0;
        return provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => provider.fetchAnalytics(),
                child: ListView(
                  padding: const EdgeInsets.all(32),
                  children: [
                    _buildStatCard(
                      title: 'إجمالي المبيعات',
                      value: '${totalSales.toStringAsFixed(2)} ليرة',
                      color: Colors.blueAccent,
                      icon: Icons.attach_money,
                    ),
                    const SizedBox(height: 20),
                    _buildStatCard(
                      title: 'إجمالي الطلبات',
                      value: totalOrders.toString(),
                      color: Colors.purpleAccent,
                      icon: Icons.shopping_cart,
                    ),
                    const SizedBox(height: 20),
                    _buildStatCard(
                      title: 'استخدام الخصم',
                      value: '${(discountUsage * 100).toStringAsFixed(1)}%',
                      color: Colors.green,
                      icon: Icons.percent,
                    ),
                  ],
                ),
              );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
