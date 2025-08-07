import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/add_part_provider.dart';
import '../setting.dart';
import 'qr_scan_page.dart';

class KiaPartAddPage extends StatefulWidget {
  const KiaPartAddPage({super.key});

  @override
  State<KiaPartAddPage> createState() => _KiaPartAddPageState();
}

class _KiaPartAddPageState extends State<KiaPartAddPage> {
  final List<String> years = ['2020', '2021', '2022', '2023', '2024'];
  final List<String> partsList = [
    'فلتر زيت',
    'كمبيوتر محرك',
    'ردياتير',
    'بواجي'
  ];
  final List<String> fuels = ['بترول', 'ديزل'];
  final List<String> categories = ['محرك', 'فرامل', 'كهرباء', 'هيكل'];
  final List<String> statuses = ['جديد', 'مستعمل'];

  List<String> brands = [];
  List<String> models = [];

  String? selectedBrand;
  String? selectedModel;
  String? selectedYear;
  String? selectedPart;
  String? selectedFuel;
  String? selectedCategory;
  String? selectedStatus;
  File? _pickedImage;
  final priceController = TextEditingController();
  final serialNumberController = TextEditingController();

  bool isLoading = false;
  bool isModelsLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBrands();
  }

  @override
  void dispose() {
    priceController.dispose();
    serialNumberController.dispose();
    super.dispose();
  }

  Future<void> _fetchBrands() async {
    final url = Uri.parse(
      '${AppSettings.serverurl}/user/viewsellerprands/6891009147d76ee5e1b22647',
    );
    try {
      final r = await http.get(url);
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        setState(() {
          brands = (data['prands'] as List<dynamic>)
              .map((b) => (b as String).capitalize())
              .toList();
        });
      }
    } catch (e) {}
  }

  Future<void> _fetchModels(String brand) async {
    setState(() => isModelsLoading = true);
    final url = Uri.parse(
      '${AppSettings.serverurl}/api/models?brand=${Uri.encodeComponent(brand.toLowerCase())}',
    );
    try {
      final r = await http.get(url);
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        models = List<String>.from(data['models']);
      } else {
        models = [];
      }
    } catch (e) {
      models = [];
    }
    setState(() => isModelsLoading = false);
  }

  Future<void> _pickImage() async {
    final p = ImagePicker();
    final f = await p.pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => _pickedImage = File(f.path));
  }

  Future<void> _submit() async {
    if ([
          selectedBrand,
          selectedModel,
          selectedYear,
          selectedPart,
          selectedFuel,
          selectedCategory,
          selectedStatus
        ].contains(null) ||
        priceController.text.isEmpty ||
        _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول')),
      );
      return;
    }
    setState(() => isLoading = true);
    final ok = await context.read<AddPartProvider>().addPart(
          name: selectedPart!,
          manufacturer: selectedBrand!.toLowerCase(),
          model: selectedModel!,
          year: selectedYear!,
          fuelType: selectedFuel!,
          category: selectedCategory!,
          status: selectedStatus!,
          price: priceController.text,
          image: _pickedImage,
          serialNumber: serialNumberController.text,
        );
    setState(() => isLoading = false);

    final msg = ok
        ? '✅ تمت الإضافة'
        : (context.read<AddPartProvider>().errorMessage ?? 'فشل');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    if (ok) Navigator.pop(context);
  }

  int get _currentStep {
    if (selectedBrand == null) return 0;
    if (selectedModel == null) return 1;
    if (selectedYear == null) return 2;
    if (selectedPart == null) return 3;
    if (selectedFuel == null) return 4;
    if (selectedCategory == null) return 5;
    if (selectedStatus == null) return 6;
    return 7;
  }

  Widget _buildCurrentStep(int step) {
    switch (step) {
      case 0:
        return _cardStep('اختر البراند:', brands, selectedBrand, (b) {
          setState(() {
            selectedBrand = b;
            selectedModel = null;
            _fetchModels(b);
          });
        });
      case 1:
        return _cardStep(
          'اختر الموديل:',
          models,
          selectedModel,
          (m) => setState(() => selectedModel = m),
          loading: isModelsLoading,
        );
      case 2:
        return _cardStep(
          'اختر سنة الصنع:',
          years,
          selectedYear,
          (y) => setState(() => selectedYear = y),
        );
      case 3:
        return _cardStep(
          'اختر اسم القطعة:',
          partsList,
          selectedPart,
          (p) => setState(() => selectedPart = p),
        );
      case 4:
        return _cardStep(
          'اختر نوع الوقود:',
          fuels,
          selectedFuel,
          (f) => setState(() => selectedFuel = f),
        );
      case 5:
        return _cardStep(
          'اختر التصنيف:',
          categories,
          selectedCategory,
          (c) => setState(() => selectedCategory = c),
        );
      case 6:
        return _cardStep(
          'اختر الحالة:',
          statuses,
          selectedStatus,
          (s) => setState(() => selectedStatus = s),
        );
      default:
        return _buildFinalForm();
    }
  }

  Widget _cardStep<T>(
    String title,
    List<T> options,
    T? selected,
    void Function(T) onSelect, {
    bool loading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (loading)
          const Center(child: CircularProgressIndicator())
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: options.map((opt) {
              final txt = opt.toString();
              final isSel = opt == selected;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isSel ? Colors.blue.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isSel ? Border.all(color: Colors.blue, width: 2) : null,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4,
                      color: Colors.black12,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: InkWell(
                  onTap: () => onSelect(opt),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Text(txt,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSel ? FontWeight.bold : FontWeight.normal,
                            color:
                                isSel ? Colors.blue.shade700 : Colors.black87)),
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFinalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: serialNumberController,
          decoration: InputDecoration(
            labelText: 'الرقم التسلسلي (اختياري)',
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(Icons.qr_code_scanner),
              onPressed: () async {
                final code = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QRScanPage()),
                );
                if (code != null) {
                  setState(() {
                    serialNumberController.text = code;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
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
        ),
        if (_pickedImage != null) ...[
          const SizedBox(height: 12),
          Image.file(_pickedImage!, width: 120, height: 120, fit: BoxFit.cover),
        ],
        const SizedBox(height: 20),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة قطعة')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
              child: SingleChildScrollView(
                key: ValueKey<int>(_currentStep),
                padding: const EdgeInsets.all(16),
                child: _buildCurrentStep(_currentStep),
              ),
            ),
    );
  }
}

extension StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
