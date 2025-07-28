import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'providers/add_part_provider.dart';

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
  String? price;
  File? _pickedImage;
  String? serialNumber;
  String? description;

  final List<String> makes = ['Toyota', 'Hyundai', 'Kia'];
  final List<String> years = ['2025', '2024', '2023', '2022'];
  final List<String> fuelTypes = ['بترول', 'ديزل'];
  final List<String> categories = [
    'محرك',
    'فرامل',
    'هيكل',
    'كهرباء',
    'إطارات',
    'نظام التعليق'
  ];
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

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد'),
        content: const Text('هل أنت متأكد أنك تريد إضافة هذه القطعة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('متابعة')),
        ],
      ),
    );

    if (confirm != true) return;

    final provider = Provider.of<AddPartProvider>(context, listen: false);
    final success = await provider.addPart(
      name: name!,
      manufacturer: manufacturer!,
      model: model!,
      year: year!,
      fuelType: fuelType!,
      category: category!,
      status: status!,
      price: price!,
      image: _pickedImage,
    );

    if (success) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تم بنجاح'),
          content: const Text('تمت إضافة القطعة بنجاح.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('موافق'),
            ),
          ],
        ),
      );
    } else {
      final error = provider.errorMessage ?? 'حدث خطأ غير معروف';
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('فشل الإضافة'),
          content: Text(error),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('موافق')),
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
          title: const Text('إضافة قطعة (مورد)'), backgroundColor: Colors.blue),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'اسم القطعة',
                          border: OutlineInputBorder()),
                      onSaved: (val) => name = val,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'الماركة', border: OutlineInputBorder()),
                      items: makes
                          .map((make) =>
                              DropdownMenuItem(value: make, child: Text(make)))
                          .toList(),
                      onChanged: (val) => manufacturer = val,
                      validator: (val) => val == null ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'الموديل', border: OutlineInputBorder()),
                      onSaved: (val) => model = val,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'سنة الصنع', border: OutlineInputBorder()),
                      items: years
                          .map(
                              (y) => DropdownMenuItem(value: y, child: Text(y)))
                          .toList(),
                      onChanged: (val) => year = val,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'الرقم التسلسلي',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (val) => serialNumber = val,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'نوع الوقود',
                          border: OutlineInputBorder()),
                      items: fuelTypes
                          .map(
                              (f) => DropdownMenuItem(value: f, child: Text(f)))
                          .toList(),
                      onChanged: (val) => fuelType = val,
                      validator: (val) => val == null ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'التصنيف', border: OutlineInputBorder()),
                      items: categories
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => category = val,
                      validator: (val) => val == null ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'الحالة', border: OutlineInputBorder()),
                      items: statuses
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => status = val,
                      validator: (val) => val == null ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'السعر (بالدولار)',
                        border: OutlineInputBorder(),
                        suffixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (val) => price = val,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'مطلوب';
                        if (double.tryParse(val) == null)
                          return 'أدخل رقمًا صالحًا';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'وصف القطعة',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onSaved: (val) => description = val,
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الصورة',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
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
                                    child: Text('اضغط لاختيار صورة من المعرض')),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة القطعة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
