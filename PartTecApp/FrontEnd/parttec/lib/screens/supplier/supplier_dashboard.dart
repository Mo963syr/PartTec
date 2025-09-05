import 'package:flutter/material.dart';
import 'package:parttec/screens/part/PartsSectionPage.dart';
import 'package:parttec/theme/app_theme.dart';
import 'package:parttec/widgets/ui_kit.dart';

import 'package:parttec/screens/order/my_order_page.dart';
import '../auth/auth_page.dart';
import '../cart/cart_page.dart';
import '../order/MyOrdersDashboard.dart';
import '../order/recommendation_orders_page.dart';
import '../order/GroupedOrdersPage.dart';
import '../part/added_parts_page.dart';
import 'DeliveredOrdersPage.dart';
import 'sellers.dart';

import '../../utils/session_store.dart';

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
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      await SessionStore.clear();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthPage()),
                              (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpaces.md),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double maxWidth = constraints.maxWidth;
                      double cardWidth =
                          (maxWidth / 2) - (AppSpaces.lg * 1.5);
                      double cardHeight = cardWidth;

                      return Wrap(
                        spacing: AppSpaces.lg,
                        runSpacing: AppSpaces.lg,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildCard(
                            context,
                            icon: Icons.widgets,
                            title: 'قسم القطع',
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => PartsSectionPage()));
                            },
                          ),
                          _buildCard(
                            context,
                            icon: Icons.edit_note,
                            title: 'طلباتي',
                            onTap: () {
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (_) => MyOrdersDashboard()));
                            },
                          ),
                          _buildCard(
                            context,
                            icon: Icons.shopping_cart,
                            title: 'الطلبات المقدمة من الزبون',
                            onTap: () {
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (_) => GroupedOrdersPage()));
                            },
                          ),
                          _buildCard(
                            context,
                            icon: Icons.view_list,
                            title: 'عرض القطع المضافة',
                            onTap: () {
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (_) => AddedPartsPage()));
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
                                    builder: (_) => RecommendationOrdersPage(roleOverride: 'user')),
                              );
                            },
                          ),
                          _buildCard(
                            context,
                            icon: Icons.storefront,
                            title: 'التجار',
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const TradersDashboard()));
                            },
                          ),
                          _buildCard(
                            context,
                            icon: Icons.history,
                            title: 'السجل',
                            onTap: () {
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (_) => DeliveredOrdersPage()));
                            },
                          ),

                          _buildCard(
                            context,
                            icon: Icons.shopping_basket,
                            title: 'سلة المشتريات',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CartPage(),
                                ),
                              );
                            },
                          ),
                        ].map((card) {
                          return SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: card,
                          );
                        }).toList(),
                      );

                    },
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
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
