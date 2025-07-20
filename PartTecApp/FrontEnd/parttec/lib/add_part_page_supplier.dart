import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddPartPageForSupplier extends StatefulWidget {
  const AddPartPageForSupplier({super.key});

  @override
  State<AddPartPageForSupplier> createState() => _AddPartPageForSupplierState();
}

class _AddPartPageForSupplierState extends State<AddPartPageForSupplier> {
  final _formKey = GlobalKey<FormState>();

  String? name;
  String? manufacturer;
  String? model;
  String? year;
  String? fuelType;
  String? imageUrl;
  String? user;
  File? _pickedImage;

  final List<String> makes = ['Toyota', 'Hyundai', 'Kia'];
  final List<String> years = ['2025', '2024', '2023', '2022'];
  final List<String> fuelTypes = ['بترول', 'ديزل'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
        imageUrl = pickedFile.path; // حفظ المسار المحلي مؤقتًا
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة قطعة (مورد)'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // اسم القطعة
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'اسم القطعة',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => name = val,
                validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),

              // الشركة المصنعة
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'الماركة',
                  border: OutlineInputBorder(),
                ),
                items: makes.map((make) {
                  return DropdownMenuItem(value: make, child: Text(make));
                }).toList(),
                onChanged: (val) => manufacturer = val,
                validator: (val) => val == null ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),

              // الموديل
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'الموديل',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => model = val,
                validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),

              // السنة
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'سنة الصنع',
                  border: OutlineInputBorder(),
                ),
                items: years
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: (val) => year = val,
                validator: (val) => val == null ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),

              // نوع الوقود
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'نوع الوقود',
                  border: OutlineInputBorder(),
                ),
                items: fuelTypes
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (val) => fuelType = val,
                validator: (val) => val == null ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),

              // اختيار صورة
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الصورة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _pickedImage != null
                          ? Image.file(_pickedImage!, fit: BoxFit.cover)
                          : const Center(
                              child: Text('اضغط لاختيار صورة من المعرض'),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // اسم المستخدم
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'اسم المستخدم',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => user = val,
              ),
              const SizedBox(height: 20),

              // زر الإضافة
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // هنا تنفذ الإرسال أو الحفظ
                    print('--- قطعة جديدة ---');
                    print('Name: $name');
                    print('Manufacturer: $manufacturer');
                    print('Model: $model');
                    print('Year: $year');
                    print('FuelType: $fuelType');
                    print('ImageURL: $imageUrl');
                    print('User: $user');

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت إضافة القطعة بنجاح')),
                    );

                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة القطعة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
