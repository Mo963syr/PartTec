import 'package:flutter/material.dart';
import 'package:parttec/screens/part/PartsSectionPage.dart';
import 'package:parttec/theme/app_theme.dart';
import 'package:parttec/widgets/ui_kit.dart';

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
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: const Text(
                  'لوحة المورد',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpaces.md),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpaces.lg,
                    crossAxisSpacing: AppSpaces.lg,
                    childAspectRatio: 1,
                    children: [
                      _buildCard(
                        context,
                        icon: Icons.widgets,
                        title: 'قسم القطع',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PartsSectionPage(),
                            ),
                          );
                        },
                      ),
                      _buildCard(
                        context,
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
                        context,
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
                        context,
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
                        context,
                        icon: Icons.recommend,
                        title: 'طلبات التوصية',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecommendationOrdersPage(
                                roleOverride: 'user',
                              ),
                            ),
                          );
                        },
                      ),
                      _buildCard(
                        context,
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
                        context,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(AppSpaces.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: AppColors.primary),
              const SizedBox(height: AppSpaces.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
