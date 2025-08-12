import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parttec/models/part.dart';
import '../../widgets/parts_widgets.dart';
import '../part/add_part_page.dart';
import '../../providers/home_provider.dart';
import '../cart/cart_page.dart';
import '../order/my_order_page.dart';
import '../favorites/favorite_parts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 2;

  late final TextEditingController _serialController;
  String _serialSearchQuery = '';
  List<Part> _serialSearchResults = [];

  @override
  void initState() {
    super.initState();
    _serialController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _serialController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    await provider.fetchUserCars();
    await provider.fetchAvailableParts();
  }

  void _performSerialSearch() {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final query = _serialController.text.trim();

    setState(() {
      _serialSearchQuery = query;
      if (query.isNotEmpty) {
        _serialSearchResults = provider.availableParts
            .where((part) =>
                part.serialNumber != null &&
                part.serialNumber!.trim().toLowerCase() == query.toLowerCase())
            .toList();
      } else {
        _serialSearchResults = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);

    final categories = [
      {'label': 'محرك', 'icon': Icons.settings},
      {'label': 'هيكل', 'icon': Icons.car_repair},
      {'label': 'فرامل', 'icon': Icons.settings_input_component},
      {'label': 'كهرباء', 'icon': Icons.electrical_services},
      {'label': 'إطارات', 'icon': Icons.circle},
      {'label': 'نظام التعليق', 'icon': Icons.sync_alt},
    ];

    return Scaffold(
      // خلفية متدرجة عصرية
      body: Stack(
        children: [
          const _GradientBackground(),
          (provider.isLoadingAvailable && provider.availableParts.isEmpty)
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refresh,
                  displacement: 140,
                  strokeWidth: 2.8,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        stretch: true,
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        expandedHeight: 190,
                        leading: IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {},
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => CartPage()),
                              ).then((_) => _refresh());
                            },
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          stretchModes: const [
                            StretchMode.zoomBackground,
                            StretchMode.blurBackground,
                            StretchMode.fadeTitle,
                          ],
                          titlePadding: const EdgeInsetsDirectional.only(
                              start: 16, bottom: 12, end: 16),
                          title: const Text('قطع الغيار',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          background: const _HeaderGlow(),
                        ),
                      ),

                      // بطاقة معلومات سريعة + تبديل عامة/خاصة + سياراتك
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: _QuickInfoCard(
                              provider: provider,
                              onToggle: provider.toggleIsPrivate),
                        ),
                      ),

                      // شريط البحث الطافي
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                          child: _FloatingSearchBar(
                            controller: _serialController,
                            onSearch: _performSerialSearch,
                          ),
                        ),
                      ),

                      // نتائج البحث (إن وجدت)
                      if (_serialSearchQuery.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: _SectionTitle(
                              title: 'نتائج الرقم التسلسلي',
                              trailing: Text(
                                '${_serialSearchResults.length} نتيجة',
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      if (_serialSearchQuery.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: PartsGrid(parts: _serialSearchResults),
                            ),
                          ),
                        ),

                      // تبويبات الفئات (Chips)
                      if (_serialSearchQuery.isEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                            child: _SectionTitle(title: 'الفئات'),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _ScrollableChips(
                            categories: categories,
                          ),
                        ),

                        // المحتوى حسب التبويب
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            child: _TabbedCategories(categories: categories),
                          ),
                        ),
                      ],

                      // نموذج إضافة سيارة (مبسّط ضمن بطاقة)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                          child: _CarFormCard(),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),

      // زر إضافة طافٍ
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddPartPage()))
              .then((_) => _refresh());
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text('إضافة قطعة'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // شريط سفلي عصري
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      elevation: 10,
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: 'الإشعارات',
              icon: Icon(Icons.notifications,
                  color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            IconButton(
              tooltip: 'طلباتي',
              icon: Icon(Icons.history,
                  color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.88,
                    maxChildSize: 0.95,
                    minChildSize: 0.6,
                    builder: (_, controller) => ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Material(
                        color: Colors.white,
                        child: SingleChildScrollView(
                          controller: controller,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: MyOrdersPage(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ).whenComplete(() => _refresh());
              },
            ),
            const SizedBox(width: 40),
            IconButton(
              tooltip: 'المفضلة',
              icon: Icon(Icons.favorite,
                  color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
              onPressed: () {
                Navigator.push(context,
                        MaterialPageRoute(builder: (_) => FavoritePartsPage()))
                    .then((_) => _refresh());
                setState(() => _selectedIndex = 3);
              },
            ),
            IconButton(
              tooltip: 'الرئيسية',
              icon: Icon(Icons.home,
                  color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
          ],
        ),
      ),
    );
  }
}

/* ======================= عناصر الواجهة المخصّصة ======================= */

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade400,
            Colors.indigo.shade400,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}

class _HeaderGlow extends StatelessWidget {
  const _HeaderGlow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
          ),
        ),
        Positioned(
          right: -40,
          bottom: -20,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -20,
          top: 10,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickInfoCard extends StatelessWidget {
  final HomeProvider provider;
  final VoidCallback onToggle;

  const _QuickInfoCard({required this.provider, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cars = provider.userCars;
    return Card(
      elevation: 8,
      shadowColor: Colors.black12,
      color: Colors.white.withOpacity(0.96),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان + سويتش عامة/خاصة
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('سياراتك',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(
                  provider.isPrivate ? 'خاصة' : 'عامة',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: provider.isPrivate,
                  onChanged: (_) => onToggle(),
                  activeColor: Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 8),
            if (cars.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cars
                    .map((c) => Chip(
                          backgroundColor: Colors.blue.shade50,
                          label: Text(
                            '${c['manufacturer']} ${c['model']} (${c['year']})',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          avatar: const Icon(Icons.directions_car,
                              size: 18, color: Colors.blue),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ))
                    .toList(),
              )
            else
              Text(
                'أضِف سيارتك لتحصل على توصيات أدق.',
                style: TextStyle(
                    color: Colors.grey[700], fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
    );
  }
}

class _FloatingSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const _FloatingSearchBar({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: TextField(
        controller: controller,
        onSubmitted: (_) => onSearch(),
        decoration: InputDecoration(
          hintText: 'ابحث بالرقم التسلسلي...',
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ScrollableChips extends StatefulWidget {
  final List<Map<String, dynamic>> categories;

  const _ScrollableChips({required this.categories});

  @override
  State<_ScrollableChips> createState() => _ScrollableChipsState();
}

class _ScrollableChipsState extends State<_ScrollableChips>
    with SingleTickerProviderStateMixin {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, i) {
          final label = widget.categories[i]['label'] as String;
          final isSel = selected == i;
          return GestureDetector(
            onTap: () => setState(() => selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSel ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  if (isSel)
                    BoxShadow(
                        color: Colors.blue.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                ],
                border: Border.all(
                    color: isSel ? Colors.blue : Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSel ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: widget.categories.length,
      ),
    );
  }
}

class _TabbedCategories extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const _TabbedCategories({required this.categories});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12, top: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              indicator: BoxDecoration(
                color: Colors.blue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              labelStyle: const TextStyle(fontWeight: FontWeight.w800),
              tabs: categories
                  .map(
                    (cat) => Tab(
                      icon: Icon(cat['icon'] as IconData),
                      text: cat['label'] as String,
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.48,
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              children: categories
                  .map<Widget>(
                    (cat) => CategoryTabView(
                        category: (cat['label'] ?? '') as String),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarFormCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    return Card(
      elevation: 6,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardHeader(title: 'إضافة/تحديث سيارة'),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  labelText: 'ماركة السيارة', border: OutlineInputBorder()),
              value: provider.selectedMake,
              items: provider.makes
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: provider.setSelectedMake,
            ),
            if (provider.selectedMake != null) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: 'الموديل', border: OutlineInputBorder()),
                value: provider.selectedModel,
                items: (provider.modelsByMake[provider.selectedMake] ?? [])
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: provider.setSelectedModel,
              ),
            ],
            if (provider.selectedModel != null) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: 'سنة الصنع', border: OutlineInputBorder()),
                value: provider.selectedYear,
                items: provider.years
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: provider.setSelectedYear,
              ),
            ],
            if (provider.selectedYear != null) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: 'نوع الوقود', border: OutlineInputBorder()),
                value: provider.selectedFuel,
                items: provider.fuelTypes
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: provider.setSelectedFuel,
              ),
            ],
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('حفظ السيارة'),
                onPressed: () => provider.submitCar(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String title;
  const _CardHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
