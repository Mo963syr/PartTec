import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parttec/models/part.dart';
import '../../Widgets/parts_widgets.dart';
import '../part/add_part_page.dart';
import '../../providers/home_provider.dart';
import '../cart/cart_page.dart';
import '../order/my_order_page.dart';
import '../favorites/favorite_parts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;

  late final TextEditingController _serialController;
  String _serialSearchQuery = '';
  List<Part> _serialSearchResults = [];

  @override
  void initState() {
    super.initState();

    _serialController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    _serialController.dispose();
    super.dispose();
  }

  void _performSerialSearch() {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final query = _serialController.text.trim();

    setState(() {
      _serialSearchQuery = query;
      if (query.isNotEmpty) {
        _serialSearchResults = provider.availableParts
            .where((part) =>
                part.serialNumber != null &&
                part.serialNumber!.trim().toLowerCase() == query.toLowerCase())
            .toList();
      } else {
        _serialSearchResults = [];
      }
    });
  }

  Future<void> _refresh() async {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    await provider.fetchUserCars();
    await provider.fetchAvailableParts();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('قطع الغيار'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                      context, MaterialPageRoute(builder: (_) => CartPage()))
                  .then((_) => _refresh());
            },
          ),
        ],
      ),
      body: (provider.isLoadingAvailable && provider.availableParts.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              displacement: 200.0,
              strokeWidth: 3.0,
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 160,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.userCars.isNotEmpty)
                      _buildUserCarsSection(provider),
                    _buildCarFormSection(context, provider),
                    _buildPartsSection(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddPartPage()))
              .then((_) => _refresh());
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildUserCarsSection(HomeProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: provider.toggleShowCars,
            child: Row(
              children: [
                const Text(
                  '🚗 سياراتك:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(
                  provider.showCars ? Icons.expand_less : Icons.expand_more,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          if (provider.showCars)
            ...provider.userCars.map((c) =>
                Text('• ${c['manufacturer']} ${c['model']} (${c['year']})')),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عرض قطع ${provider.isPrivate ? "خاصة" : "عامة"}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Switch(
                value: provider.isPrivate,
                onChanged: (_) => provider.toggleIsPrivate(),
                activeColor: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarFormSection(BuildContext context, HomeProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'ماركة السيارة',
              border: OutlineInputBorder(),
            ),
            value: provider.selectedMake,
            items: provider.makes
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: provider.setSelectedMake,
          ),
          if (provider.selectedMake != null) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'الموديل',
                border: OutlineInputBorder(),
              ),
              value: provider.selectedModel,
              items: (provider.modelsByMake[provider.selectedMake] ?? [])
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: provider.setSelectedModel,
            ),
          ],
          if (provider.selectedModel != null) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'سنة الصنع',
                border: OutlineInputBorder(),
              ),
              value: provider.selectedYear,
              items: provider.years
                  .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                  .toList(),
              onChanged: provider.setSelectedYear,
            ),
          ],
          if (provider.selectedYear != null) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'نوع الوقود',
                border: OutlineInputBorder(),
              ),
              value: provider.selectedFuel,
              items: provider.fuelTypes
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: provider.setSelectedFuel,
            ),
          ],
          if (provider.selectedFuel != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('حفظ السيارة'),
              onPressed: () => provider.submitCar(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPartsSection() {
    final List<Map<String, dynamic>> categories = [
      {'label': 'محرك', 'icon': Icons.settings},
      {'label': 'هيكل', 'icon': Icons.car_repair},
      {'label': 'فرامل', 'icon': Icons.settings_input_component},
      {'label': 'كهرباء', 'icon': Icons.electrical_services},
      {'label': 'إطارات', 'icon': Icons.circle},
      {'label': 'نظام التعليق', 'icon': Icons.sync_alt},
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _serialController,
            decoration: InputDecoration(
              labelText: 'ابحث بالرقم التسلسلي',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _performSerialSearch,
              ),
            ),
            onSubmitted: (_) => _performSerialSearch(),
          ),
          const SizedBox(height: 10),
          if (_serialSearchQuery.isNotEmpty)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.44,
              child: PartsGrid(parts: _serialSearchResults),
            )
          else
            DefaultTabController(
              length: categories.length,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      isScrollable: true,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: categories
                          .map((cat) => Tab(
                                icon: Icon(cat['icon'] as IconData),
                                text: cat['label'] as String,
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.44,
                    child: TabBarView(
                      children: categories
                          .map<Widget>((cat) => CategoryTabView(
                              category: (cat['label'] ?? '') as String))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
              ),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            IconButton(
              icon: Icon(
                Icons.history,
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: MyOrdersPage(),
                  ),
                ).whenComplete(() => _refresh());
              },
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: _selectedIndex == 3 ? Colors.blue : Colors.grey,
              ),
              onPressed: () {
                Navigator.push(context,
                        MaterialPageRoute(builder: (_) => FavoritePartsPage()))
                    .then((_) => _refresh());
                setState(() => _selectedIndex = 3);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.home,
                color: _selectedIndex == 2 ? Colors.blue : Colors.grey,
              ),
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
          ],
        ),
      ),
    );
  }
}
