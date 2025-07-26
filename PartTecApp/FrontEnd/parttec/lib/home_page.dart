import 'package:flutter/material.dart';
import 'add_part_page.dart';
import 'providers/home_provider.dart';
import 'package:parttec/Widgets/parts_widgets.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HomeProvider>(context, listen: false);
      provider.fetchUserCars();
      provider.fetchAvailableParts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('قطع الغيار'), backgroundColor: Colors.blue),
      body: RefreshIndicator(
        displacement: 200.0,
        strokeWidth: 3.0,
        onRefresh: () => provider.fetchAvailableParts(),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 160,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider.userCars.isNotEmpty) _buildUserCarsSection(provider),
              _buildCarFormSection(context, provider),
              if (!provider.isLoadingAvailable) _buildPartsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => AddPartPage())),
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildUserCarsSection(HomeProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          GestureDetector(
            onTap: provider.toggleShowCars,
            child: Row(
              children: [
                Text('🚗 سياراتك:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Icon(provider.showCars ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue),
              ],
            ),
          ),
          if (provider.showCars)
            ...provider.userCars
                .map((c) =>
                    Text('• ${c['manufacturer']} ${c['model']} (${c['year']})'))
                .toList(),
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
            decoration: InputDecoration(
                labelText: 'ماركة السيارة', border: OutlineInputBorder()),
            value: provider.selectedMake,
            items: provider.makes
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: provider.setSelectedMake,
          ),
          if (provider.selectedMake != null) ...[
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  labelText: 'الموديل', border: OutlineInputBorder()),
              value: provider.selectedModel,
              items: (provider.modelsByMake[provider.selectedMake] ?? [])
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: provider.setSelectedModel,
            ),
          ],
          if (provider.selectedModel != null) ...[
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  labelText: 'سنة الصنع', border: OutlineInputBorder()),
              value: provider.selectedYear,
              items: provider.years
                  .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                  .toList(),
              onChanged: provider.setSelectedYear,
            ),
          ],
          if (provider.selectedYear != null) ...[
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  labelText: 'نوع الوقود', border: OutlineInputBorder()),
              value: provider.selectedFuel,
              items: provider.fuelTypes
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: provider.setSelectedFuel,
            ),
          ],
          if (provider.selectedFuel != null) ...[
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('حفظ السيارة'),
              onPressed: () => provider.submitCar(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPartsSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(icon: Icon(Icons.settings), text: 'محرك'),
              Tab(icon: Icon(Icons.car_repair), text: 'هيكل'),
              Tab(icon: Icon(Icons.settings_input_component), text: 'فرامل'),
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.44,
            child: TabBarView(
              controller: _tabController,
              children: [
                CategoryTabView(category: 'محرك'),
                CategoryTabView(category: 'هيكل'),
                CategoryTabView(category: 'فرامل'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                icon: Icon(Icons.notifications,
                    color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
                onPressed: () => setState(() => _selectedIndex = 0)),
            IconButton(
                icon: Icon(Icons.history,
                    color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
                onPressed: () => setState(() => _selectedIndex = 1)),
            SizedBox(width: 40),
            IconButton(
                icon: Icon(Icons.receipt_long,
                    color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
                onPressed: () => setState(() => _selectedIndex = 3)),
            IconButton(
                icon: Icon(Icons.home,
                    color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
                onPressed: () => setState(() => _selectedIndex = 2)),
          ],
        ),
      ),
    );
  }
}
