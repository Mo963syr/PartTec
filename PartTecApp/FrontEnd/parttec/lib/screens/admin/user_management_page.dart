import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final roles = provider.usersByRole.keys.toList();
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateUserDialog(context),
            child: const Icon(Icons.add),
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.fetchUsers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: roles.length,
                    itemBuilder: (context, index) {
                      final role = roles[index];
                      final users = provider.usersByRole[role] ?? [];
                      return _RoleSection(
                        role: role,
                        users: users,
                        onEdit: (user) =>
                            _showEditUserDialog(context, role, user),
                        onToggleActive: (user) {
                          final current = user['active'] == true;
                          provider.updateUser(
                            user['id'].toString(),
                            role: role,
                            active: !current,
                          );
                        },
                        onDelete: (user) {
                          provider.deleteUser(user['id'].toString());
                        },
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    String role = 'mechanic';
    double? discount;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إنشاء مستخدم جديد'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'الاسم'),
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration:
                        const InputDecoration(labelText: 'البريد الإلكتروني'),
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'كلمة المرور'),
                    obscureText: true,
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: 'الدور'),
                    items: const [
                      DropdownMenuItem(value: 'mechanic', child: Text('فني')),
                      DropdownMenuItem(
                          value: 'delivery', child: Text('موظف توصيل')),
                      DropdownMenuItem(value: 'supplier', child: Text('مورّد')),
                    ],
                    onChanged: (value) {
                      role = value ?? role;
                    },
                  ),
                  if (role == 'mechanic')
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'نسبة الخصم (مثال 0.10)'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        discount = double.tryParse(val);
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Provider.of<AdminProvider>(context, listen: false).createUser(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim(),
                    password: passwordController.text.trim(),
                    role: role,
                    discount: discount,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(
    BuildContext context,
    String role,
    Map<String, dynamic> user,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController =
        TextEditingController(text: user['name']?.toString());
    final emailController =
        TextEditingController(text: user['email']?.toString());
    final phoneController =
        TextEditingController(text: user['phone']?.toString());
    double? discount = user['discount'] != null
        ? double.tryParse(user['discount'].toString())
        : null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل المستخدم'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'الاسم'),
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration:
                        const InputDecoration(labelText: 'البريد الإلكتروني'),
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                  if (role == 'mechanic')
                    TextFormField(
                      initialValue: discount?.toString(),
                      decoration: const InputDecoration(
                          labelText: 'نسبة الخصم (مثال 0.10)'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        discount = double.tryParse(val);
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Provider.of<AdminProvider>(context, listen: false).updateUser(
                    user['id'].toString(),
                    role: role,
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim(),
                    discount: discount,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('تحديث'),
            ),
          ],
        );
      },
    );
  }
}

class _RoleSection extends StatelessWidget {
  final String role;
  final List<Map<String, dynamic>> users;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(Map<String, dynamic>) onToggleActive;
  final void Function(Map<String, dynamic>) onDelete;

  const _RoleSection({
    required this.role,
    required this.users,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    String roleTitle;
    switch (role) {
      case 'mechanic':
        roleTitle = 'الفنيون';
        break;
      case 'delivery':
        roleTitle = 'موظفو التوصيل';
        break;
      case 'supplier':
        roleTitle = 'المورّدون';
        break;
      default:
        roleTitle = role;
        break;
    }
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              roleTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 12),
            ...users.map((user) => ListTile(
                  leading: Icon(
                    role == 'mechanic'
                        ? Icons.engineering
                        : role == 'delivery'
                            ? Icons.delivery_dining
                            : Icons.storefront,
                    color: Colors.teal,
                  ),
                  title: Text(user['name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['email'] ?? ''),
                      Text(user['phone'] ?? ''),
                      if (role == 'mechanic' && user['discount'] != null)
                        Text(
                            'خصم: ${(double.parse(user['discount'].toString()) * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => onEdit(user),
                      ),
                      IconButton(
                        icon: Icon(
                          user['active'] == true
                              ? Icons.toggle_on
                              : Icons.toggle_off,
                          color: user['active'] == true
                              ? Colors.green
                              : Colors.red,
                        ),
                        onPressed: () => onToggleActive(user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDelete(user),
                      ),
                    ],
                  ),
                )),
            if (users.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('لا يوجد مستخدمون في هذه الفئة حالياً'),
              ),
          ],
        ),
      ),
    );
  }
}
