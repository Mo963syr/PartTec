import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:parttec/utils/app_settings.dart';
import 'package:parttec/utils/session_store.dart';

class UploadPartsExcelPage extends StatefulWidget {
  const UploadPartsExcelPage({super.key});

  @override
  State<UploadPartsExcelPage> createState() => _UploadPartsExcelPageState();
}

class _UploadPartsExcelPageState extends State<UploadPartsExcelPage> {
  String? selectedFile;
  File? pickedFile;
  bool isUploading = false;

  Future<void> _pickExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'], // حصراً Excel
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          pickedFile = File(result.files.single.path!);
          selectedFile = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ خطأ أثناء اختيار الملف: $e")),
      );
    }
  }

  Future<void> _uploadExcelFile() async {
    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء اختيار ملف Excel أولاً")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final uri = Uri.parse("${AppSettings.serverurl}/parts/upload-excel");

      // ✅ أنشئ الـ request
      var request = http.MultipartRequest("POST", uri);

      // ✅ إضافة userId إلى الـ body
      final userId = await SessionStore.userId();
      request.fields["userId"] = userId ?? "";

      // ✅ إضافة الملف
      request.files.add(
        await http.MultipartFile.fromPath("file", pickedFile!.path),
      );

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تم رفع الملف بنجاح")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ فشل رفع الملف: $resBody")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ خطأ: $e")),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("رفع قطع (Excel)")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text("اختيار ملف Excel"),
              onPressed: _pickExcelFile,
            ),
            const SizedBox(height: 20),
            if (selectedFile != null)
              Text(
                "تم اختيار الملف: $selectedFile",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: isUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(isUploading ? "جاري الرفع..." : "رفع الملف"),
              onPressed: isUploading ? null : _uploadExcelFile,
            ),
          ],
        ),
      ),
    );
  }
}
