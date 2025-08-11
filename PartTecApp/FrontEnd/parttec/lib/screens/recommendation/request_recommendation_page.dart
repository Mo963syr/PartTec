import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/order_provider.dart';

class RequestRecommendationPage extends StatefulWidget {
  const RequestRecommendationPage({super.key});

  @override
  State<RequestRecommendationPage> createState() =>
      _RequestRecommendationPageState();
}

class _RequestRecommendationPageState extends State<RequestRecommendationPage> {
  final _formKey = GlobalKey<FormState>();
  String? partName;
  String? carMake;
  String? model;
  String? year;
  String? serialNumber;
  String? note;
  File? _pickedImage;

  final List<String> makes = ['Toyota', 'Hyundai', 'Kia'];
  final List<String> years = ['2025', '2024', '2023', '2022'];

  final Map<String, String> _brandCodeMap = const {
    'Toyota': 'TOY',
    'Hyundai': 'HYU',
    'Kia': 'KIA',
  };

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final f = await picker.pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => _pickedImage = File(f.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final provider = context.read<OrderProvider>();
    final brandCode = _brandCodeMap[carMake ?? ''] ?? '';

    final mergedNotes = [
      if ((note ?? '').trim().isNotEmpty) note!.trim(),
      if ((serialNumber ?? '').trim().isNotEmpty)
        'Serial: ${serialNumber!.trim()}',
    ].join(' • ');

    final ok = await provider.createSpecificOrder(
      brandCode: brandCode,
      partName: (partName == null || partName!.trim().isEmpty)
          ? 'unspecified'
          : partName!.trim(),
      carModel: model!.trim(),
      carYear: year!,
      notes: mergedNotes.isEmpty ? null : mergedNotes,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'تم إرسال الطلب${provider.lastOrderId != null ? " (#${provider.lastOrderId})" : ""}')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.lastError ?? 'فشل الإرسال')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<OrderProvider>().isSubmitting;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('طلب توصية قطعة')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'اسم القطعة (اختياري)',
                      border: OutlineInputBorder()),
                  onSaved: (v) => partName = v,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: 'نوع السيارة (الماركة)',
                      border: OutlineInputBorder()),
                  items: makes
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  value: carMake,
                  onChanged: (v) => setState(() => carMake = v),
                  validator: (v) => v == null ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'موديل السيارة', border: OutlineInputBorder()),
                  onSaved: (v) => model = v,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'الرقم التسلسلي (اختياري)',
                      border: OutlineInputBorder()),
                  onSaved: (v) => serialNumber = v,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: 'سنة الصنع', border: OutlineInputBorder()),
                  items: years
                      .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                      .toList(),
                  value: year,
                  onChanged: (v) => setState(() => year = v),
                  validator: (v) => v == null ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'وصف مكان العطل (اختياري)',
                      border: OutlineInputBorder()),
                  onSaved: (v) => note = v,
                ),
                const SizedBox(height: 12),
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
                        : const Center(
                            child: Text('اضغط لاختيار صورة (اختياري)')),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: isSubmitting ? null : _submit,
                  icon: const Icon(Icons.send),
                  label: Text(isSubmitting ? 'جارٍ الإرسال...' : 'إرسال الطلب'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
