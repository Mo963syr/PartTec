import 'package:flutter/material.dart';
import 'add_part_page_supplier.dart';
import 'manage_parts_page.dart';
import 'GroupedOrdersPage.dart';
import 'added_parts_page.dart';
import 'recommendation_requests_page.dart';

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
                    builder: (_) => const KiaPartAddPage(),
                  ),
                );
              },
            ),
            _buildCard(
              icon: Icons.edit_note,
              title: 'تعديل أو حذف قطعة',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManagePartsPage(),
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
              icon: Icons.recommend, // أيقونة تدل على توصية
              title: 'طلبات التوصية',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecommendationRequestsPage(), // صفحة جديدة
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
