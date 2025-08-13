import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_kit.dart';
import '../home/home_page.dart';
import '../location/ChooseDestinationPage.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _agreeTerms = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ChooseDestinationPage()),
    );
  }

  InputDecoration _input(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.chipBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpaces.md,
        vertical: AppSpaces.sm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpaces.md),
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 2,
                          ),
                        ),
                        child: const Icon(Icons.car_repair,
                            size: 38, color: Colors.white),
                      ),
                      const SizedBox(height: AppSpaces.md),
                      const Text(
                        'مرحباً بك في PartTec',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpaces.lg),
                      Card(
                        color: Colors.white.withOpacity(0.98),
                        elevation: 10,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpaces.lg),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  splashFactory: NoSplash.splashFactory,
                                  dividerColor: Colors.transparent,
                                  indicator: BoxDecoration(
                                    color: const Color(0x1A2196F3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  labelColor: AppColors.primary,
                                  unselectedLabelColor: AppColors.textWeak,
                                  labelStyle: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                  tabs: const [
                                    Tab(
                                        icon: Icon(Icons.login),
                                        text: 'تسجيل دخول'),
                                    Tab(
                                        icon: Icon(Icons.person_add_alt),
                                        text: 'إنشاء حساب'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpaces.lg),
                              SizedBox(
                                height: 400,
                                child: TabBarView(
                                  controller: _tabController,
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    Column(
                                      children: [
                                        TextField(
                                          controller: _loginEmailCtrl,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: _input(
                                              'البريد الإلكتروني',
                                              icon: Icons.email),
                                        ),
                                        const SizedBox(height: AppSpaces.md),
                                        TextField(
                                          controller: _loginPassCtrl,
                                          obscureText: true,
                                          decoration: _input('كلمة المرور',
                                              icon: Icons.lock),
                                        ),
                                        const SizedBox(height: AppSpaces.lg),
                                        Row(
                                          children: [
                                            const Spacer(),
                                            TextButton(
                                              onPressed: () {},
                                              child: const Text(
                                                  'نسيت كلمة المرور؟'),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: _goToHome,
                                            icon:
                                                const Icon(Icons.check_circle),
                                            label: const Text('تسجيل الدخول'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        TextField(
                                          controller: _nameCtrl,
                                          textInputAction: TextInputAction.next,
                                          decoration: _input('الاسم الكامل',
                                              icon: Icons.person),
                                        ),
                                        const SizedBox(height: AppSpaces.md),
                                        TextField(
                                          controller: _emailCtrl,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: _input(
                                              'البريد الإلكتروني',
                                              icon: Icons.email),
                                        ),
                                        const SizedBox(height: AppSpaces.md),
                                        TextField(
                                          controller: _passCtrl,
                                          obscureText: true,
                                          decoration: _input('كلمة المرور',
                                              icon: Icons.lock),
                                        ),
                                        const SizedBox(height: AppSpaces.md),
                                        TextField(
                                          controller: _pass2Ctrl,
                                          obscureText: true,
                                          decoration: _input(
                                              'تأكيد كلمة المرور',
                                              icon: Icons.lock_reset),
                                        ),
                                        const SizedBox(height: AppSpaces.md),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: _agreeTerms,
                                              onChanged: (v) => setState(() =>
                                                  _agreeTerms = v ?? false),
                                              activeColor: AppColors.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'أوافق على الشروط والأحكام وسياسة الخصوصية',
                                                style: TextStyle(
                                                    color: Colors.grey[700]),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed:
                                                _agreeTerms ? _goToHome : null,
                                            icon: const Icon(
                                                Icons.person_add_alt),
                                            label: const Text('إنشاء حساب'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpaces.lg),
                      Text(
                        '© PartTec - جميع الحقوق محفوظة',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpaces.md),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
