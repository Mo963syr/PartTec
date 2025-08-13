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

  // بحث بالرقم التسلسلي
  late final TextEditingController _serialController;
  String _serialSearchQuery = '';
  List<Part> _serialSearchResults = [];

  // فلاتر الفئات (نسخة واحدة فقط)
  final List<Map<String, dynamic>> _categories = const [
    {'label': 'محرك', 'icon': Icons.settings},
    {'label': 'هيكل', 'icon': Icons.car_repair},
    {'label': 'فرامل', 'icon': Icons.settings_input_component},
    {'label': 'كهرباء', 'icon': Icons.electrical_services},
    {'label': 'إطارات', 'icon': Icons.circle},
    {'label': 'نظام التعليق', 'icon': Icons.sync_alt},
  ];
  int _selectedCategoryIndex = 0;

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

  List<Part> _filterByCategory(List<Part> parts) {
    final selectedLabel =
        _categories[_selectedCategoryIndex]['label'] as String;
    return parts
        .where((p) => (p.category ?? '').trim() == selectedLabel)
        .toList();
  }

  void _clearSerialSearch() {
    _serialController.clear();
    setState(() {
      _serialSearchQuery = '';
      _serialSearchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);

    return Scaffold(
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
                        expandedHeight: 150,
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
                                      MaterialPageRoute(
                                          builder: (_) => CartPage()))
                                  .then((_) => _refresh());
                            },
                          ),
                        ],
                        flexibleSpace: const FlexibleSpaceBar(
                          titlePadding: EdgeInsetsDirectional.only(
                              start: 16, bottom: 12, end: 16),
                          title: Text('قطع الغيار',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          background: _HeaderGlow(),
                        ),
                      ),

                      // 🔎 شريط البحث + زر عامة/خاصة — مثبّت بارتفاع ثابت
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SearchBarHeader(
                          minExtent: 120,
                          maxExtent: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // تنسيق أجمل للبحث
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: _FloatingSearchBar(
                                  controller: _serialController,
                                  onSearch: _performSerialSearch,
                                  onClear: _clearSerialSearch,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // زر عامة/خاصة بشكل Segmented Control خفيف
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: _VisibilityToggle(
                                  isPrivate: provider.isPrivate,
                                  onChanged: (val) =>
                                      provider.toggleIsPrivate(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ===== الفئات (Chips) نسخة واحدة متكاملة =====
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: _SectionTitle(title: 'الفئات'),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _CategoryChipsBar(
                          categories: _categories,
                          selectedIndex: _selectedCategoryIndex,
                          onChanged: (i) =>
                              setState(() => _selectedCategoryIndex = i),
                        ),
                      ),

                      // ===== النتائج =====
                      if (_serialSearchQuery.isNotEmpty) ...[
                        // نتائج البحث بالرقم التسلسلي
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
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: PartsGrid(parts: _serialSearchResults),
                            ),
                          ),
                        ),
                      ] else ...[
                        // عرض القطع حسب الفئة المختارة
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: _SectionTitle(
                                title: _categories[_selectedCategoryIndex]
                                    ['label'] as String),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.48,
                              child: PartsGrid(
                                parts:
                                    _filterByCategory(provider.availableParts),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // 🚗 "سياراتي" — سلايدر جذّاب + تبويب الإضافة
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                          child: _MyCarsSection(),
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

      // شريط سفلي
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
            Colors.indigo.shade400
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
        const Positioned.fill(child: Opacity(opacity: 0.15)),
        Positioned(
          right: -40,
          bottom: -20,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
          ),
        ),
        Positioned(
          left: -20,
          top: 10,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06), shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}

// ===== شريط البحث المثبّت (مع ضبط الارتفاع) =====
class _SearchBarHeader extends SliverPersistentHeaderDelegate {
  final double _minExtent;
  final double _maxExtent;
  final Widget child;

  _SearchBarHeader({
    required double minExtent,
    required double maxExtent,
    required this.child,
  })  : _minExtent = minExtent,
        _maxExtent = maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  double get maxExtent => _maxExtent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: maxExtent,
      color: Colors.white.withOpacity(0.95),
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarHeader oldDelegate) {
    return oldDelegate._minExtent != _minExtent ||
        oldDelegate._maxExtent != _maxExtent ||
        oldDelegate.child != child;
  }
}

// ===== شريط بحث مُحسّن مع زر مسح =====
class _FloatingSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback? onClear;

  const _FloatingSearchBar({
    required this.controller,
    required this.onSearch,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onSearch(),
        decoration: InputDecoration(
          hintText: 'ابحث بالرقم التسلسلي...',
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: const Icon(Icons.qr_code_scanner_rounded),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if ((controller.text).isNotEmpty)
                IconButton(
                  tooltip: 'مسح',
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                ),
              IconButton(
                tooltip: 'بحث',
                onPressed: onSearch,
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== عنوان قسم بسيط =====
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

// ===== زر عامة/خاصة (Segmented) =====
class _VisibilityToggle extends StatelessWidget {
  final bool isPrivate;
  final ValueChanged<bool> onChanged;
  const _VisibilityToggle({required this.isPrivate, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          _segBtn(
              label: 'عامة',
              selected: !isPrivate,
              onTap: () => onChanged(false)),
          _segBtn(
              label: 'خاصة', selected: isPrivate, onTap: () => onChanged(true)),
        ],
      ),
    );
  }

  Expanded _segBtn(
      {required String label,
      required bool selected,
      required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0x1A2196F3) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.blue : Colors.black87,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ===== شريط الفئات (نسخة واحدة فقط) =====
class _CategoryChipsBar extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _CategoryChipsBar({
    required this.categories,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, i) {
          final label = categories[i]['label'] as String;
          final isSel = selectedIndex == i;
          return GestureDetector(
            onTap: () => onChanged(i),
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
                        offset: const Offset(0, 6))
                ],
                border: Border.all(
                    color: isSel ? Colors.blue : Colors.grey.shade300),
              ),
              child: Center(
                child: Row(
                  children: [
                    Icon(categories[i]['icon'] as IconData,
                        size: 18, color: isSel ? Colors.white : Colors.black87),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSel ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: categories.length,
      ),
    );
  }
}

// ===== قسم تبويبات "سياراتك" =====
class _MyCarsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    final cars = provider.userCars;

    return Card(
      elevation: 8,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CardHeader(title: 'سياراتي'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12)),
                child: const TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black54,
                  indicator: BoxDecoration(
                      color: Color(0x1A2196F3),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  tabs: [
                    Tab(icon: Icon(Icons.directions_car), text: 'قائمتي'),
                    Tab(
                        icon: Icon(Icons.add_circle_outline),
                        text: 'إضافة/تحديث'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 260,
                child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // سلايدر جذّاب للسيارات
                    cars.isEmpty
                        ? Center(
                            child: Text(
                                'لا توجد سيارات بعد — أضِف سيارتك من التبويب التالي.',
                                style: TextStyle(color: Colors.grey[700])))
                        : _CarsSlider(cars: cars),
                    // نموذج الإضافة/التحديث (كما هو)
                    const SingleChildScrollView(child: _CarFormCard()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarsSlider extends StatefulWidget {
  final List<dynamic> cars;
  const _CarsSlider({required this.cars});

  @override
  State<_CarsSlider> createState() => _CarsSliderState();
}

class _CarsSliderState extends State<_CarsSlider> {
  final PageController _page = PageController(viewportFraction: 0.86);
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _page,
            itemCount: widget.cars.length,
            onPageChanged: (i) => setState(() => _index = i),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, i) {
              final c = widget.cars[i];
              final title = '${c['manufacturer']} ${c['model']}';
              final sub = 'سنة ${c['year']} • ${c['fuel'] ?? 'غير محدد'}';

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.only(
                    right: 10,
                    left: i == 0 ? 2 : 0,
                    bottom: _index == i ? 0 : 10,
                    top: _index == i ? 0 : 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2196F3), Color(0xFF3949AB)],
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 66,
                        height: 66,
                        decoration: const BoxDecoration(
                            color: Colors.white24, shape: BoxShape.circle),
                        child: const Icon(Icons.directions_car,
                            color: Colors.white, size: 34),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(sub,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: -6,
                              children: [
                                if (c['vin'] != null &&
                                    (c['vin'] as String).isNotEmpty)
                                  _pill('VIN: ${c['vin']}'),
                                if (c['engine'] != null)
                                  _pill('محرك: ${c['engine']}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // أزرار سريعة (شكل فقط)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _miniBtn(icon: Icons.edit, tooltip: 'تعديل'),
                          const SizedBox(height: 8),
                          _miniBtn(icon: Icons.delete, tooltip: 'حذف'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.cars.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 18 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF2196F3) : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _pill(String t) => Chip(
        label: Text(t,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      );

  Widget _miniBtn({required IconData icon, String? tooltip}) => Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      );
}

class _CarFormCard extends StatelessWidget {
  const _CarFormCard();

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
                color: Colors.blue, borderRadius: BorderRadius.circular(8))),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
