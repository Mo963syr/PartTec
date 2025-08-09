import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/parts_provider.dart';

class ManagePartsPage extends StatefulWidget {
  const ManagePartsPage({super.key});

  @override
  State<ManagePartsPage> createState() => _ManagePartsPageState();
}

class _ManagePartsPageState extends State<ManagePartsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<PartsProvider>(context, listen: false).fetchParts());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PartsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة القطع'),
        backgroundColor: Colors.blue,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.parts.length,
              itemBuilder: (context, index) {
                final part = provider.parts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(part['name'] ?? ''),
                    subtitle: Text(
                        "${part['manufacturer'] ?? ''} - ${part['model'] ?? ''}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('تأكيد الحذف'),
                            content: const Text('هل تريد حذف هذه القطعة؟'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('إلغاء'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('نعم'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await provider.deletePart(part['_id']);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
