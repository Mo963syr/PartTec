import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RequestRecommendationPage extends StatefulWidget {
  @override
  _RequestRecommendationPageState createState() =>
      _RequestRecommendationPageState();
}

class _RequestRecommendationPageState extends State<RequestRecommendationPage> {
  final _formKey = GlobalKey<FormState>();
  String? partName;
  String? carMake;
  String? model;
  String? year;
  String? fuelType;
  String? description;
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
      });
    }
  }

  void _submitRequest() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // TODO: إرسال الطلب للسيرفر

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('✅ تم الإرسال'),
        content: Text('تم إرسال طلب التوصية بنجاح!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('موافق'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلب توصية قطعة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'اسم القطعة (اختياري)',
                    border: OutlineInputBorder()),
                onSaved: (val) => partName = val,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    labelText: 'نوع السيارة', border: OutlineInputBorder()),
                items: makes
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) => carMake = val,
                validator: (val) => val == null ? 'مطلوب' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'موديل السيارة', border: OutlineInputBorder()),
                onSaved: (val) => model = val,
                validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    labelText: 'سنة الصنع', border: OutlineInputBorder()),
                items: years
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: (val) => year = val,
                validator: (val) => val == null ? 'مطلوب' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    labelText: 'نوع الوقود', border: OutlineInputBorder()),
                items: fuelTypes
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (val) => fuelType = val,
                validator: (val) => val == null ? 'مطلوب' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                    labelText: 'وصف مكان العطل', border: OutlineInputBorder()),
                onSaved: (val) => description = val,
              ),
              SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _pickedImage != null
                      ? Image.file(_pickedImage!, fit: BoxFit.cover)
                      : Center(child: Text('اضغط لاختيار صورة')),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submitRequest,
                icon: Icon(Icons.send),
                label: Text('إرسال الطلب'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
