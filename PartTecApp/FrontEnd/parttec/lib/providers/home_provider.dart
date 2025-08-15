import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/app_settings.dart';
import '../models/part.dart';
import '../utils/session_store.dart';

class HomeProvider with ChangeNotifier {
  String? _userId; // نخزن المعرف هنا

  bool showCars = true;
  String? selectedMake;
  String? selectedModel;
  String? selectedYear;
  String? selectedFuel;
  List<dynamic> userCars = [];
  List<Part> availableParts = [];
  bool isLoadingAvailable = true;

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
    'Hyundai': ['Elantra', 'Sonata', 'Tucson', 'Azera'],
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

  Future<String?> _getUserId() async {
    _userId ??= await SessionStore.userId();
    return _userId;
  }

  Future<void> fetchUserCars() async {
    final uid = await _getUserId();
    if (uid == null || uid.isEmpty) {
      print('⚠️ لم يتم العثور على userId. يرجى تسجيل الدخول.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${AppSettings.serverurl}/cars/veiwCars/$uid'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userCars = data;
        notifyListeners();
      } else {
        print('❌ فشل تحميل السيارات: ${response.body}');
      }
    } catch (e) {
      print('خطأ أثناء تحميل السيارات: $e');
    }
  }

  bool isPrivate = true;
  void toggleIsPrivate() {
    isPrivate = !isPrivate;
    notifyListeners();
    fetchAvailableParts();
  }

  Future<void> fetchAvailableParts() async {
    final uid = await _getUserId();
    if (uid == null || uid.isEmpty) {
      print('⚠️ لا يوجد userId، لا يمكن تحميل القطع الخاصة.');
      availableParts = [];
      notifyListeners();
      return;
    }

    try {
      isLoadingAvailable = true;
      notifyListeners();

      final String url = isPrivate
          ? '${AppSettings.serverurl}/part/viewPrivateParts/$uid'
          : '${AppSettings.serverurl}/part/viewAllParts';

      final response = await http.get(Uri.parse(url));
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final dynamic list =
            decoded['compatibleParts'] ?? decoded['parts'] ?? [];
        final List<dynamic> jsonList = list is List ? list : [];
        availableParts = jsonList.map((e) => Part.fromJson(e)).toList();
      } else {
        print('❌ فشل تحميل القطع: ${response.body}');
        availableParts = [];
      }
    } catch (e) {
      print('❌ خطأ أثناء تحميل القطع: $e');
      availableParts = [];
    } finally {
      isLoadingAvailable = false;
      notifyListeners();
    }
  }

  void submitCar(BuildContext context) async {
    final uid = await _getUserId();
    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ يرجى تسجيل الدخول أولاً')),
      );
      return;
    }

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
        Uri.parse('${AppSettings.serverurl}/cars/add/$uid'),
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
