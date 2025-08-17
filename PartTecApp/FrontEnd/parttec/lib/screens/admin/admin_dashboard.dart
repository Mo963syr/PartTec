import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import 'user_management_page.dart';
import 'analytics_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider()
        ..fetchUsers()
        ..fetchAnalytics(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة التحكم'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'إدارة المستخدمين'),
              Tab(text: 'التحليلات'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [UserManagementPage(), AnalyticsPage()],
        ),
      ),
    );
  }
}
