import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parttec/setting.dart';

class HomeProvider with ChangeNotifier {
  String userId = '687ff5a6bf0de81878ed94f5';

  // الحالات
  bool showCars = true;
  String? selectedMake;
  String? selectedModel;
  String? selectedYear;
  String? selectedFuel;
  List<dynamic> userCars = [];
  List<dynamic> availableParts = [];
  bool isLoadingAvailable = true;

  // قوائم البيانات
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

  Future<void> fetchUserCars() async {
    try {
      final response = await http.get(
        Uri.parse('${AppSettings.serverurl}/cars/veiwCars/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          userCars = data;
          notifyListeners();
        });
      }
    } catch (e) {
      print('خطأ أثناء تحميل السيارات: $e');
    }
  }

  Future<void> fetchAvailableParts() async {
    try {
      // إشعار ببداية التحميل – مؤجل
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoadingAvailable = true;
        notifyListeners();
      });

      final response = await http.get(
        Uri.parse('${AppSettings.serverurl}/part/viewPrivateParts'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final parts = decoded['parts'] ?? [];

        // تحديث البيانات – مؤجل
        WidgetsBinding.instance.addPostFrameCallback((_) {
          availableParts = parts;
          isLoadingAvailable = false;
          notifyListeners();
        });
      } else {
        print('❌ فشل تحميل القطع: ${response.body}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          isLoadingAvailable = false;
          notifyListeners();
        });
      }
    } catch (e) {
      print('❌ خطأ أثناء تحميل القطع: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoadingAvailable = false;
        notifyListeners();
      });
    }
  }

  void submitCar(BuildContext context) async {
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
        selectedMake = selectedModel = selectedYear = selectedFuel = null;
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

  void toggleShowCars() {
    showCars = !showCars;
    notifyListeners();
  }

  void setSelectedMake(String? value) {
    selectedMake = value;
    selectedModel = null;
    selectedYear = null;
    selectedFuel = null;
    notifyListeners();
  }

  void setSelectedModel(String? value) {
    selectedModel = value;
    notifyListeners();
  }

  void setSelectedYear(String? value) {
    selectedYear = value;
    notifyListeners();
  }

  void setSelectedFuel(String? value) {
    selectedFuel = value;
    notifyListeners();
  }
}
