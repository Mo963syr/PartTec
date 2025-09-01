import 'package:flutter/material.dart';
import 'package:parttec/screens/order/my_order_page.dart';
import 'package:parttec/screens/recommendation/request_recommendation_page.dart';
import '../order/recommendation_orders_page.dart';
import '../part/add_part_page_supplier.dart';
import '../part/manage_parts_page.dart';
import '../order/GroupedOrdersPage.dart';
import '../part/added_parts_page.dart';
import '../recommendation/recommendation_requests_page.dart';
import 'seller_reviews_page.dart';
import 'DeliveredOrdersPage.dart.dart';
import 'sellers.dart';

class SupplierDashboard extends StatelessWidget {
  const SupplierDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المورد'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 3 / 2,
          children: [
            _buildCard(
              icon: Icons.add_box,
              title: 'إضافة قطعة',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KiaPartAddPage(),
                  ),
                );
              },
            ),
            _buildCard(
              icon: Icons.edit_note,
              title: 'طلباتي',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyOrdersPage(),
                  ),
                );
              },
            ),
            _buildCard(
              icon: Icons.shopping_cart,
              title: 'طلبات الزبائن',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupedOrdersPage(),
                  ),
                );
              },
            ),
            _buildCard(
              icon: Icons.view_list,
              title: 'عرض القطع المضافة',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddedPartsPage(),
                  ),
                );
              },
            ),
            _buildCard(
              icon: Icons.recommend,
              title: 'طلبات التوصية',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RecommendationOrdersPage(roleOverride: 'user'),
                  ),
                );
              },
            ),
            _buildCard(
              icon: Icons.recommend,
              title: 'التقييمات',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SellerReviewsPage(),
                  ),
                );
              },
            ),
            _buildCard(
              icon: Icons.storefront,
              title: 'التجار',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TradersDashboard(),
                  ),
                );
              },
            ),
            _buildCard(
              icon: Icons.history,
              title: 'السجل',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeliveredOrdersPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
                  child: Icon(icon, size: 50, color: Colors.blue),
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
