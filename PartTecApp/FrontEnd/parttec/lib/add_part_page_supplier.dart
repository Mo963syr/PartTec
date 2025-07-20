import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parttec/setting.dart';


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
  String? category;
  String? status;
  File? _pickedImage;

  final List<String> makes = ['Toyota', 'Hyundai', 'Kia'];
  final List<String> years = ['2025', '2024', '2023', '2022'];
  final List<String> fuelTypes = ['بترول', 'ديزل'];
  final List<String> categories = ['محرك', 'فرامل', 'هيكل'];
  final List<String> statuses = ['جديد', 'مستعمل'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final uri = Uri.parse('${AppSettings.baseUrl}/part/add');

    final request = http.MultipartRequest('POST', uri);

    request.fields['name'] = name!;
    request.fields['manufacturer'] = manufacturer!;
    request.fields['model'] = model!;
    request.fields['year'] = year!;
    request.fields['fuelType'] = fuelType!;
    request.fields['user'] = '68761cf7f92107b8288158c2';
    request.fields['category'] = category!;
    request.fields['status'] = status!;


    if (_pickedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _pickedImage!.path),
      );
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة القطعة بنجاح')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في الإرسال: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء الإرسال: $e')),
      );
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
                items: makes
                    .map((make) =>
                        DropdownMenuItem(value: make, child: Text(make)))
                    .toList(),
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

              // التصنيف (Category)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'التصنيف',
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => category = val,
                validator: (val) => val == null ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),

              // الحالة (Status)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'الحالة',
                  border: OutlineInputBorder(),
                ),
                items: statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => status = val,
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
              const SizedBox(height: 20),

              // زر الإضافة
              ElevatedButton.icon(
                onPressed: _submitForm,
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
