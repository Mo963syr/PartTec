import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/add_part_provider.dart';
import '../setting.dart';

class KiaPartAddPage extends StatefulWidget {
  const KiaPartAddPage({super.key});

  @override
  State<KiaPartAddPage> createState() => _KiaPartAddPageState();
}

class _KiaPartAddPageState extends State<KiaPartAddPage> {
  final List<String> kiaModels = ['Cerato', 'Sportage', 'Rio', 'Sorento'];
  final Map<String, List<String>> modelYears = {
    'Cerato': ['2022', '2023', '2024'],
    'Sportage': ['2021', '2022', '2023'],
    'Rio': ['2020', '2021', '2022'],
    'Sorento': ['2022', '2023'],
  };
  final List<String> availableParts = [
    'فلتر زيت',
    'كمبيوتر محرك',
    'ردياتير',
    'بواجي',
    'كمبروسر',
    'طقم فرامل',
  ];
  final List<String> fuelTypes = ['بترول', 'ديزل'];
  final List<String> categories = [
    'محرك',
    'فرامل',
    'كهرباء',
    'هيكل',
    'إطارات',
    'نظام التعليق'
  ];

  String? selectedModel;
  String? selectedYear;
  String? selectedPart;
  String? selectedFuel;
  String? selectedCategory;
  String? selectedStatus;
  File? _pickedImage;
  TextEditingController priceController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPart() async {
    if (selectedModel == null ||
        selectedYear == null ||
        selectedPart == null ||
        selectedFuel == null ||
        selectedCategory == null ||
        priceController.text.isEmpty ||
        _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد'),
        content: const Text('هل تريد إضافة القطعة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('نعم')),
        ],
      ),
    );

    if (confirm != true) return;

    final provider = Provider.of<AddPartProvider>(context, listen: false);
    final success = await provider.addPart(
      name: selectedPart!,
      manufacturer: 'Kia',
      model: selectedModel!,
      year: selectedYear!,
      fuelType: selectedFuel!,
      category: selectedCategory!,
      status: 'جديد',
      price: priceController.text,
      image: _pickedImage,
    );

    if (success) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('تم بنجاح'),
          content: const Text('تمت إضافة القطعة.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('موافق'),
            ),
          ],
        ),
      );
    } else {
      final error = provider.errorMessage ?? 'حدث خطأ غير معروف';
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('فشل الإرسال'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('موافق'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AddPartProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
          title: const Text('إضافة قطعة - Kia'), backgroundColor: Colors.blue),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isLoading,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedModel == null)
                      _buildSelection(
                          'اختر الموديل:',
                          kiaModels,
                          Icons.directions_car,
                          (val) => setState(() => selectedModel = val))
                    else if (selectedYear == null)
                      _buildSelection(
                          'اختر سنة الصنع:',
                          modelYears[selectedModel]!,
                          Icons.date_range,
                          (val) => setState(() => selectedYear = val))
                    else if (selectedPart == null)
                      _buildSelection(
                          'اختر القطعة:',
                          availableParts,
                          Icons.build,
                          (val) => setState(() => selectedPart = val))
                    else
                      _buildFinalForm(),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildSelection(String title, List<String> items, IconData icon,
      void Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items
              .map((item) => Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: InkWell(
                      onTap: () => onSelect(item),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2 - 24,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, size: 30, color: Colors.blue),
                            const SizedBox(height: 8),
                            Text(item, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFinalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'السعر (بالدولار)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text('اختيار صورة'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
        ),
        const SizedBox(height: 10),
        if (_pickedImage != null)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(_pickedImage!,
                  width: 120, height: 120, fit: BoxFit.cover),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.send),
          label: const Text('إرسال'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14)),
        )
      ],
    );
  }
}
