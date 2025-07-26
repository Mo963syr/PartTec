import 'package:flutter/material.dart';
import 'add_part_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parttec/setting.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool showCars = true;
  int _selectedIndex = 2;
  String userId = '687ff5a6bf0de81878ed94f5';

  String? selectedMake;
  String? selectedModel;
  String? selectedYear;
  String? selectedFuel;

  List<dynamic> userCars = [];
  List<dynamic> availableParts = [];
  bool isLoadingAvailable = true;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchUserCars();
    fetchAvailableParts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchUserCars() async {
    try {
      final response = await http.get(
        Uri.parse('${AppSettings.serverurl}/cars/veiwCars/$userId'),
      );
      if (response.statusCode == 200) {
        setState(() => userCars = jsonDecode(response.body));
      }
    } catch (e) {
      print('خطأ أثناء تحميل السيارات: $e');
    }
  }

  Future<void> fetchAvailableParts() async {
    try {
      final response = await http.get(
        Uri.parse('${AppSettings.serverurl}/part/viewPrivateParts'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final parts = decoded['parts'];
        setState(() {
          availableParts = parts;
          isLoadingAvailable = false;
        });
      } else {
        print('❌ فشل تحميل القطع: ${response.body}');
        setState(() => isLoadingAvailable = false);
      }
    } catch (e) {
      print('❌ خطأ أثناء تحميل القطع: $e');
      setState(() => isLoadingAvailable = false);
    }
  }

  void submitCar() async {
    if (selectedMake == null ||
        selectedModel == null ||
        selectedYear == null ||
        selectedFuel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى تحديد جميع البيانات')),
      );
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('${AppSettings.serverurl}/cars/add/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'manufacturer': selectedMake,
          'model': selectedModel,
          'year': selectedYear,
          'fuelType': selectedFuel,
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ تم حفظ السيارة بنجاح')),
        );
        setState(() {
          selectedMake = selectedModel = selectedYear = selectedFuel = null;
        });
        fetchUserCars();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ فشل في الحفظ: ${response.body}')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ خطأ في الاتصال بالخادم')),
      );
    }
  }

  final List<String> makes = [
    'Hyundai', 'All', 'Acura', 'Alfa Romeo', 'Aston Martin', 'Audi', 'Bentley',
    'BMW', 'Bugatti', 'Buick', 'Cadillac', 'Chevrolet', 'Chrysler', 'Citroën',
    'Dacia', 'Dodge', 'Ferrari', 'Fiat', 'Ford', 'Genesis', 'GMC', 'Honda',
    'Infiniti', 'Jaguar', 'Jeep', 'Kia', 'Koenigsegg', 'Lamborghini',
    'Land Rover', 'Lexus', 'Lucid', 'Maserati', 'Mazda', 'McLaren',
    'Mercedes-Benz', 'Mini', 'Mitsubishi', 'Nissan', 'Opel', 'Peugeot',
    'Porsche', 'Renault', 'Rolls-Royce', 'Saab', 'Seat', 'Škoda', 'Subaru',
    'Suzuki', 'Tesla', 'Toyota', 'Volkswagen', 'Volvo'
  ];

  final Map<String, List<String>> modelsByMake = {
    'Kia': ['Sportage', 'Sorento', 'Cerato'],
    'Toyota': ['Corolla', 'Camry', 'Land Cruiser'],
    'Hyundai': ['Elantra', 'Sonata', 'Tucson'],
  };

  final List<String> years = [
    '2025', '2024', '2023', '2022', '2021', '2020', '2019', '2018'
  ];

  final List<String> fuelTypes = ['بترول', 'ديزل'];

  Widget _buildScrollableCategory(String category) {
    return RefreshIndicator(
      displacement: 200.0, // زيادة مسافة سحب المؤشر
      strokeWidth: 3.0,
      onRefresh: () async {
        await fetchAvailableParts();
      },
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: _buildPartsByCategory(category),
      ),
    );
  }

  Widget _buildPartsByCategory(String category) {
    final filtered = availableParts.where((part) {
      final c = (part['category'] ?? '').toString().toLowerCase();
      return c == category.toLowerCase();
    }).toList();

    if (filtered.isEmpty)
      return Center(child: Text('لا توجد قطع في هذا القسم'));

    return GridView.builder(
      padding: const EdgeInsets.only(top: 10),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (ctx, i) {
        final p = filtered[i];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: p['imageUrl'] != null
                      ? Image.network(p['imageUrl'],
                      fit: BoxFit.cover, width: double.infinity)
                      : Icon(Icons.image, size: 50, color: Colors.grey),
                ),
                SizedBox(height: 6),
                Text(p['name'] ?? 'بدون اسم',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('قطع الغيار'), backgroundColor: Colors.blue),
      body: RefreshIndicator(
        displacement: 200.0, // زيادة مسافة سحب المؤشر
        strokeWidth: 3.0,
        onRefresh: () async {
          await fetchAvailableParts();
        },
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 160,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userCars.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => showCars = !showCars),
                        child: Row(
                          children: [
                            Text('🚗 سياراتك:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Icon(showCars ? Icons.expand_less : Icons.expand_more,
                                color: Colors.blue),
                          ],
                        ),
                      ),
                      if (showCars)
                        ...userCars.map((c) => Text(
                            '• ${c['manufacturer']} ${c['model']} (${c['year']})'))
                            .toList(),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          labelText: 'ماركة السيارة', border: OutlineInputBorder()),
                      value: selectedMake,
                      items: makes
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedMake = val;
                          selectedModel = null;
                          selectedYear = null;
                          selectedFuel = null;
                        });
                      },
                    ),
                    if (selectedMake != null) ...[
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            labelText: 'الموديل', border: OutlineInputBorder()),
                        value: selectedModel,
                        items: (modelsByMake[selectedMake] ?? [])
                            .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedModel = val;
                          });
                        },
                      ),
                    ],
                    if (selectedModel != null) ...[
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            labelText: 'سنة الصنع', border: OutlineInputBorder()),
                        value: selectedYear,
                        items: years
                            .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedYear = val;
                          });
                        },
                      ),
                    ],
                    if (selectedYear != null) ...[
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            labelText: 'نوع الوقود', border: OutlineInputBorder()),
                        value: selectedFuel,
                        items: fuelTypes
                            .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedFuel = val;
                          });
                        },
                      ),
                    ],
                    if (selectedFuel != null) ...[
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: Icon(Icons.save),
                        label: Text('حفظ السيارة'),
                        onPressed: submitCar,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isLoadingAvailable)
                Padding(
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
                            _buildScrollableCategory('محرك'),
                            _buildScrollableCategory('هيكل'),
                            _buildScrollableCategory('فرامل'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
      bottomNavigationBar: BottomAppBar(
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
      ),
    );
  }
}