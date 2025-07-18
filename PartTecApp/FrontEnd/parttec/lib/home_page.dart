import 'package:flutter/material.dart';
import 'add_part_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parttec/setting.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showCars = true;

  int _selectedIndex = 2;
  String userId = '68761cf7f92107b8288158c2';
  String? selectedMake;
  String? selectedModel;
  String? selectedYear;
  String? selectedFuel;
  List<dynamic> userCars = [];

  Future<void> fetchUserCars() async {
    try {
      final response = await http.get(
        Uri.parse('${AppSettings.baseUrl}/cars/veiwCars/$userId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          userCars = jsonDecode(response.body);
        });
      } else {
        print('فشل في تحميل السيارات: ${response.body}');
      }
    } catch (e) {
      print('خطأ أثناء تحميل السيارات: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserCars();
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
        Uri.parse('${AppSettings.baseUrl}/cars/add/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
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
          selectedMake = null;
          selectedModel = null;
          selectedYear = null;
          selectedFuel = null;
        });
        await fetchUserCars();
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
    'Hyundai',
    'All',
    'Acura',
    'Alfa Romeo',
    'Aston Martin',
    'Audi',
    'Bentley',
    'BMW',
    'Bugatti',
    'Buick',
    'Cadillac',
    'Chevrolet',
    'Chrysler',
    'Citroën',
    'Dacia',
    'Dodge',
    'Ferrari',
    'Fiat',
    'Ford',
    'Genesis',
    'GMC',
    'Honda',
    'Infiniti',
    'Jaguar',
    'Jeep',
    'Kia',
    'Koenigsegg',
    'Lamborghini',
    'Land Rover',
    'Lexus',
    'Lucid',
    'Maserati',
    'Mazda',
    'McLaren',
    'Mercedes-Benz',
    'Mini',
    'Mitsubishi',
    'Nissan',
    'Opel',
    'Peugeot',
    'Porsche',
    'Renault',
    'Rolls-Royce',
    'Saab',
    'Seat',
    'Škoda',
    'Subaru',
    'Suzuki',
    'Tesla',
    'Toyota',
    'Volkswagen',
    'Volvo'
  ];

  final Map<String, List<String>> modelsByMake = {
    'Kia': ['Sportage', 'Sorento', 'Cerato'],
    'Toyota': ['Corolla', 'Camry', 'Land Cruiser'],
    'Hyundai': ['Elantra', 'Sonata', 'Tucson'],
  };

  final List<String> years = [
    '2025',
    '2024',
    '2023',
    '2022',
    '2021',
    '2020',
    '2019',
    '2018'
  ];
  final List<String> fuelTypes = ['بترول', 'ديزل'];

  final List<Map<String, dynamic>> bestSellingParts = [
    {'name': 'Fuel Injector', 'image': 'assets/images/fuel_injector.png'},
    {'name': 'ECU', 'image': 'assets/images/ecu.png'},
    {'name': 'Turbo Charger', 'image': 'assets/images/turbo.png'},
    {'name': 'Compressor', 'image': 'assets/images/compressor.png'},
    {'name': 'Clutch Disc', 'image': 'assets/images/clutch.png'},
    {'name': 'Oil Filter', 'image': 'assets/images/filter.png'},
    {'name': 'Fuel Pump', 'image': 'assets/images/fuel_pump.png'},
    {'name': 'Flywheel', 'image': 'assets/images/flywheel.png'},
    {'name': 'FAN Clutch', 'image': 'assets/images/fan_clutch.png'},
    {'name': 'Starter Motors', 'image': 'assets/images/starter.png'},
    {'name': 'Alternator', 'image': 'assets/images/alternator.png'},
  ];

  final List<Map<String, dynamic>> newParts = [
    {'image': 'assets/images/car1.png', 'label': '20% OFF', 'tag': 'NEW'},
    {'image': 'assets/images/part1.png', 'label': '20% OFF', 'tag': 'NEW'},
    {'image': 'assets/images/part2.png', 'label': '20% OFF', 'tag': 'NEW'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('قطع الغيار'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userCars.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showCars = !showCars;
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            '🚗 سياراتك:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Icon(
                            showCars ? Icons.expand_less : Icons.expand_more,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    AnimatedCrossFade(
                      firstChild: Container(),
                      secondChild: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: userCars.length,
                        itemBuilder: (context, index) {
                          final car = userCars[index];
                          return Container(
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border.all(color: Colors.blue.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Text(
                                        '🚗 ${car['manufacturer'] ?? ''}')),
                                Expanded(
                                    child: Text('📌 ${car['model'] ?? ''}')),
                                Expanded(
                                    child: Text(
                                        '📅 ${car['year']?.toString() ?? ''}')),
                                Expanded(
                                    child: Text('⛽ ${car['fuelType'] ?? ''}')),
                              ],
                            ),
                          );
                        },
                      ),
                      crossFadeState: showCars
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: Duration(milliseconds: 300),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'اختر ماركة السيارة',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    value: selectedMake,
                    items: makes.map((make) {
                      return DropdownMenuItem(value: make, child: Text(make));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMake = value;
                        selectedModel = null;
                        selectedYear = null;
                        selectedFuel = null;
                      });
                    },
                  ),
                  if (selectedMake != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'اختر الموديل',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        value: selectedModel,
                        items: (modelsByMake[selectedMake] ?? []).map((model) {
                          return DropdownMenuItem(
                              value: model, child: Text(model));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedModel = value;
                            selectedYear = null;
                            selectedFuel = null;
                          });
                        },
                      ),
                    ),
                  if (selectedModel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'اختر سنة الصنع',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        value: selectedYear,
                        items: years.map((year) {
                          return DropdownMenuItem(
                              value: year, child: Text(year));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value;
                            selectedFuel = null;
                          });
                        },
                      ),
                    ),
                  if (selectedYear != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'اختر نوع الوقود',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        value: selectedFuel,
                        items: fuelTypes.map((fuel) {
                          return DropdownMenuItem(
                              value: fuel, child: Text(fuel));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedFuel = value;
                          });
                        },
                      ),
                    ),
                  if (selectedFuel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: submitCar,
                          icon: Icon(Icons.save),
                          label: Text('حفظ السيارة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // إعلان
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              height: 100,
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('تسليم في جميع أنحاء العالم - DHL, FedEx, EMS'),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Best Selling Parts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 0.75,
                children: bestSellingParts.map((part) {
                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.grey.shade200,
                          // child: Image.asset(part['image'], fit: BoxFit.contain),
                          child:
                              Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(part['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12)),
                    ],
                  );
                }).toList(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('New Parts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: newParts.length,
                itemBuilder: (context, index) {
                  final part = newParts[index];
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(left: 10),
                    child: Stack(
                      children: [
                        Card(
                          child: Container(
                            width: double.infinity,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            // child: Image.asset(part['image'], fit: BoxFit.cover),
                            child:
                                Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            color: Colors.blue,
                            child: Text(part['label'],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            color: Colors.red,
                            child: Text(part['tag'],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPartPage()),
          );
        },
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
                onPressed: () => setState(() => _selectedIndex = 0),
              ),
              IconButton(
                icon: Icon(Icons.history,
                    color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
                onPressed: () => setState(() => _selectedIndex = 1),
              ),
              SizedBox(width: 40),
              IconButton(
                icon: Icon(Icons.receipt_long,
                    color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
                onPressed: () => setState(() => _selectedIndex = 3),
              ),
              IconButton(
                icon: Icon(Icons.home,
                    color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
                onPressed: () => setState(() => _selectedIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
