import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/seller_orders_provider.dart';
import '../order/SellerOrderDetailsPage.dart';

class DeliveredOrdersPage extends StatefulWidget {
  @override
  State<DeliveredOrdersPage> createState() => _DeliveredOrdersPageState();
}

class _DeliveredOrdersPageState extends State<DeliveredOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _salesFilter = 'اليومي';
  String _purchaseFilter = 'اليومي';

  final List<String> _filters = [
    'اليومي',
    'الأسبوعي',
    'الشهري',
    'السنوي',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // ✅ جلب الطلبات عند بداية الصفحة
    Future.microtask(() {
      context.read<SellerOrdersProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SellerOrdersProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('السجل'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المبيعات'),
            Tab(text: 'المشتريات'),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSales(provider),
                    _buildPurchases(provider),
                  ],
                ),
    );
  }

  /// فلترة حسب الزمن
  List<Map<String, dynamic>> _filterOrders(
      List<Map<String, dynamic>> orders, String filter) {
    DateTime now = DateTime.now();

    return orders.where((order) {
      final date = DateTime.tryParse(order['createdAt'] ?? '') ?? now;
      switch (filter) {
        case 'اليومي':
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        case 'الأسبوعي':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek =
              startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
          return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
        case 'الشهري':
          return date.year == now.year && date.month == now.month;
        case 'السنوي':
          return date.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  /// رسم بياني
  Widget _buildChart(List<Map<String, dynamic>> orders, String filter) {
    if (orders.isEmpty) {
      return const SizedBox(
          height: 200, child: Center(child: Text("لا توجد بيانات")));
    }

    // جمع المبالغ
    double total = orders.fold(
        0.0, (sum, o) => sum + ((o['totalAmount'] ?? 0).toDouble()));

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8,
                    child: Text(
                      filter,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: total,
                  color: Colors.blue,
                  width: 40,
                  borderRadius: BorderRadius.circular(6),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSales(SellerOrdersProvider provider) {
    // ✅ الطلبات من fetchOrders فقط، والحالة "تم التوصيل"
    final deliveredOrders = provider.orders
        .where((o) => (o['status'] ?? '') == 'تم التوصيل')
        .map((o) => Map<String, dynamic>.from(o))
        .toList();

    final filteredOrders = _filterOrders(deliveredOrders, _salesFilter);

    if (filteredOrders.isEmpty) {
      return const Center(child: Text('لا توجد مبيعات'));
    }

    double total = filteredOrders.fold(
        0.0, (sum, o) => sum + ((o['totalAmount'] ?? 0).toDouble()));

    return Column(
      children: [
        // فلترة
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: _salesFilter,
            items: _filters
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (val) {
              setState(() {
                _salesFilter = val!;
              });
            },
          ),
        ),
        // رسم بياني
        _buildChart(filteredOrders, _salesFilter),
        // قائمة الطلبات
        Expanded(
          child: ListView.builder(
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              final items = (order['items'] as List?) ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(items.length.toString()),
                  ),
                  title: Text(
                      'طلب #${(order['orderId'] ?? '').toString().substring(0, 6)}'),
                  subtitle: Text(order['customer']?['name'] ?? 'زبون'),
                  trailing: Text('\$${order['totalAmount']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SellerOrderDetailsPage(
                          customerName: order['customer']?['name'] ?? '',
                          orders: [order],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        // الإجمالي
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إجمالي المبيعات:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPurchases(SellerOrdersProvider provider) {
    final purchases = provider.orders
        .where((o) => (o['status'] ?? '') == 'مكتمل شراء')
        .map((o) => Map<String, dynamic>.from(o))
        .toList();

    final filteredPurchases = _filterOrders(purchases, _purchaseFilter);

    if (filteredPurchases.isEmpty) {
      return const Center(child: Text('لا توجد مشتريات'));
    }

    double total = filteredPurchases.fold(
        0.0, (sum, o) => sum + ((o['totalAmount'] ?? 0).toDouble()));

    return Column(
      children: [
        // فلترة
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: _purchaseFilter,
            items: _filters
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (val) {
              setState(() {
                _purchaseFilter = val!;
              });
            },
          ),
        ),
        // رسم بياني
        _buildChart(filteredPurchases, _purchaseFilter),

        Expanded(
          child: ListView.builder(
            itemCount: filteredPurchases.length,
            itemBuilder: (context, index) {
              final order = filteredPurchases[index];
              final items = (order['items'] as List?) ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Text(items.length.toString()),
                  ),
                  title: Text(
                      'فاتورة #${(order['orderId'] ?? '').toString().substring(0, 6)}'),
                  subtitle: Text(order['supplier']?['name'] ?? 'مورد'),
                  trailing: Text('\$${order['totalAmount']}'),
                ),
              );
            },
          ),
        ),

        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إجمالي المشتريات:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}
