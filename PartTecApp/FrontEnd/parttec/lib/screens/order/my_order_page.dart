import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:parttec/theme/app_theme.dart';
import 'package:parttec/widgets/ui_kit.dart';
import 'package:parttec/utils/app_settings.dart';
import 'package:parttec/utils/session_store.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> groupedOrders = [];
  String? errorMessage;
  String? _uid; // نحتفظ بالمعرّف محليًا بعد قراءته أول مرة

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      _uid ??= await SessionStore.userId();
      if (_uid == null || _uid!.isEmpty) {
        setState(() {
          errorMessage = '⚠️ يُرجى تسجيل الدخول أولًا لعرض الطلبات.';
          isLoading = false;
        });
        return;
      }

      final base = AppSettings.serverurl;
      final res1 = await http.get(Uri.parse('$base/order/viewuserorder/$_uid'));
      final res2 = await http
          .get(Uri.parse('$base/order/viewuserspicificorder/$_uid'));

      final List<Map<String, dynamic>> list = [];
      if (res1.statusCode == 200) {
        list.addAll(_parseAndMapOrders(res1.body, isSpecific: false));
      }
      if (res2.statusCode == 200) {
        list.addAll(_parseAndMapOrders(res2.body, isSpecific: true));
      }

      if (list.isEmpty && (res1.statusCode != 200 || res2.statusCode != 200)) {
        errorMessage =
        'فشل تحميل الطلبات (${res1.statusCode}/${res2.statusCode})';
      }

      setState(() {
        groupedOrders = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'حدث خطأ أثناء جلب الطلبات: $e';
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _parseAndMapOrders(
      String responseBody, {
        required bool isSpecific,
      }) {
    final raw = json.decode(responseBody);
    List rawList = [];

    if (isSpecific) {
      if (raw is Map && raw['orders'] is List) {
        rawList = raw['orders'];
      }
    } else {
      if (raw is Map && raw['orders'] is List) {
        rawList = raw['orders'];
      } else if (raw is List) {
        rawList = raw;
      }
    }

    return rawList.whereType<Map>().map<Map<String, dynamic>>((o) {
      final map = Map<String, dynamic>.from(o as Map);

      if (isSpecific) {
        return {
          'orderId': map['_id'] ?? '',
          'status': map['status'] ?? 'غير محدد',
          'expanded': false,
          'items': [
            {
              'name': map['name'] ?? 'اسم غير معروف',
              'image': map['imageUrl'],
              'price': map['price'],
              'status': map['status'] ?? 'غير محدد',
              'canCancel': false,
              'cartId': map['_id'] ?? '',
            }
          ],
        };
      } else {
        final src = (map['cartIds'] ?? map['items'] ?? []) as List?;
        final items = (src ?? []).whereType<Map>().map<Map<String, dynamic>>((it) {
          final itm = Map<String, dynamic>.from(it as Map);
          final part = (itm['partId'] ?? itm);

          String? name;
          String? image;
          dynamic price;
          if (part is Map) {
            final pMap = Map<String, dynamic>.from(part);
            name = pMap['name']?.toString();
            image = pMap['imageUrl']?.toString();
            price = pMap['price'];
          }

          return {
            'name': name ?? 'اسم غير معروف',
            'image': image,
            'price': price,
            'status': itm['status'] ?? map['status'] ?? 'غير متوفر',
            'canCancel': (map['status'] == 'قيد التجهيز'),
            'cartId': itm['_id'] ?? '',
          };
        }).toList();

        return {
          'orderId': map['_id'] ?? '',
          'status': map['status'] ?? 'غير معروف',
          'expanded': false,
          'items': items,
        };
      }
    }).toList();
  }

  Future<void> cancelOrder(String cartId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ تم طلب إلغاء الطلب $cartId (تجريبي)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            const _GradientBackground(),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  stretch: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  expandedHeight: 150,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: const FlexibleSpaceBar(
                    titlePadding:
                    EdgeInsetsDirectional.only(start: 16, bottom: 12, end: 16),
                    title: Text('طلباتي',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    background: _HeaderGlow(),
                  ),
                ),
                if (isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (errorMessage != null && groupedOrders.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('$errorMessage')),
                  )
                else if (groupedOrders.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('لا توجد طلبات لعرضها حاليًا.')),
                    )
                  else ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                        sliver: SliverList.builder(
                          itemCount: groupedOrders.length,
                          itemBuilder: (_, index) {
                            final order = groupedOrders[index];
                            final expanded = (order['expanded'] as bool?) ?? false;
                            final status = order['status'] as String? ?? 'غير معروف';
                            final items =
                                (order['items'] as List?)?.cast<Map<String, dynamic>>() ??
                                    const [];

                            return _OrderCard(
                              index: index,
                              status: status,
                              expanded: expanded,
                              items: items,
                              onToggle: (v) =>
                                  setState(() => groupedOrders[index]['expanded'] = v),
                              onCancel: (id) => cancelOrder(id),
                            );
                          },
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 140)),
                    ],
              ],
            ),
            if (!isLoading)
              Positioned.fill(
                child: RefreshIndicator(
                  displacement: 140,
                  strokeWidth: 2.4,
                  onRefresh: fetchOrders,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [SizedBox(height: 0)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MyOrdersBottomSheetView extends StatefulWidget {
  const MyOrdersBottomSheetView({super.key});

  @override
  State<MyOrdersBottomSheetView> createState() =>
      _MyOrdersBottomSheetViewState();
}

class _MyOrdersBottomSheetViewState extends State<MyOrdersBottomSheetView> {
  bool isLoading = true;
  List<Map<String, dynamic>> grouped = [];
  String? errorMsg;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      _uid ??= await SessionStore.userId();
      if (_uid == null || _uid!.isEmpty) {
        setState(() {
          errorMsg = '⚠️ يُرجى تسجيل الدخول أولًا لعرض الطلبات.';
          isLoading = false;
        });
        return;
      }

      final base = AppSettings.serverurl;
      final res1 = await http.get(Uri.parse('$base/order/viewuserorder/$_uid'));
      final res2 =
      await http.get(Uri.parse('$base/order/viewuserspicificorder/$_uid'));

      final List<Map<String, dynamic>> list = [];
      if (res1.statusCode == 200) list.addAll(_parse(res1.body, false));
      if (res2.statusCode == 200) list.addAll(_parse(res2.body, true));

      if (list.isEmpty && (res1.statusCode != 200 || res2.statusCode != 200)) {
        errorMsg = 'فشل تحميل الطلبات (${res1.statusCode}/${res2.statusCode})';
      }

      setState(() {
        grouped = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = 'خطأ أثناء الجلب: $e';
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _parse(String body, bool specific) {
    final decoded = json.decode(body);
    List raw = [];
    if (specific) {
      if (decoded is Map && decoded['orders'] is List) raw = decoded['orders'];
    } else {
      if (decoded is Map && decoded['orders'] is List) {
        raw = decoded['orders'];
      } else if (decoded is List) {
        raw = decoded;
      }
    }

    return raw.whereType<Map>().map<Map<String, dynamic>>((o) {
      final map = Map<String, dynamic>.from(o as Map);

      if (specific) {
        return {
          'status': map['status'] ?? 'غير محدد',
          'expanded': false,
          'items': [
            {
              'name': map['name'] ?? 'اسم غير معروف',
              'image': map['imageUrl'],
              'price': map['price'],
              'status': map['status'] ?? 'غير محدد',
              'canCancel': false,
              'cartId': map['_id'] ?? '',
            }
          ],
        };
      } else {
        final src = (map['cartIds'] ?? map['items'] ?? []) as List?;
        final items =
        (src ?? []).whereType<Map>().map<Map<String, dynamic>>((it) {
          final itm = Map<String, dynamic>.from(it as Map);
          final part = (itm['partId'] ?? itm);
          String? name, image;
          dynamic price;
          if (part is Map) {
            final pMap = Map<String, dynamic>.from(part);
            name = pMap['name']?.toString();
            image = pMap['imageUrl']?.toString();
            price = pMap['price'];
          }
          return {
            'name': name ?? 'اسم غير معروف',
            'image': image,
            'price': price,
            'status': itm['status'] ?? map['status'] ?? 'غير متوفر',
            'canCancel': (map['status'] == 'قيد التجهيز'),
            'cartId': itm['_id'] ?? '',
          };
        }).toList();

        return {
          'status': map['status'] ?? 'غير معروف',
          'expanded': false,
          'items': items,
        };
      }
    }).toList();
  }

  Future<void> _cancel(String cartId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ تم طلب إلغاء الطلب $cartId (تجريبي)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (errorMsg != null && grouped.isEmpty) {
      return Center(child: Text('$errorMsg'));
    }
    if (grouped.isEmpty) {
      return const Center(child: Text('لا توجد طلبات لعرضها حاليًا.'));
    }

    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: grouped.length,
        itemBuilder: (_, index) {
          final order = grouped[index];
          final expanded = (order['expanded'] as bool?) ?? false;
          final status = order['status'] as String? ?? 'غير معروف';
          final items =
              (order['items'] as List?)?.cast<Map<String, dynamic>>() ??
                  const [];

          return _OrderCard(
            index: index,
            status: status,
            expanded: expanded,
            items: items,
            onToggle: (v) => setState(() => order['expanded'] = v),
            onCancel: _cancel,
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final int index;
  final String status;
  final bool expanded;
  final List<Map<String, dynamic>> items;
  final ValueChanged<bool> onToggle;
  final Future<void> Function(String cartId) onCancel;

  const _OrderCard({
    required this.index,
    required this.status,
    required this.expanded,
    required this.items,
    required this.onToggle,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpaces.md,
              vertical: AppSpaces.sm,
            ),
            leading: const Icon(Icons.receipt, color: Colors.blue),
            title: Text('طلب رقم: ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('الحالة: $status'),
            trailing: IconButton(
              icon: Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              ),
              onPressed: () => onToggle(!expanded),
            ),
          ),
          if (expanded)
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final it = items[i];
                  final canCancel = (it['canCancel'] as bool?) ?? false;
                  final image = it['image'] as String?;
                  final name = it['name'] as String? ?? 'اسم غير معروف';
                  final price = it['price'];
                  final displayStatus =
                      (it['status'] as String?) ?? 'غير متوفر';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpaces.md,
                      vertical: 6,
                    ),
                    leading: (image != null && image.isNotEmpty)
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.broken_image, color: Colors.grey[300]),
                      ),
                    )
                        : Icon(Icons.image_not_supported, color: Colors.grey[300]),
                    title: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'السعر: ${price != null ? '\$${price}' : 'غير متوفر'}',
                    ),
                    trailing: canCancel
                        ? TextButton(
                      onPressed: () => onCancel((it['cartId'] as String?) ?? ''),
                      child: const Text('إلغاء',
                          style: TextStyle(color: Colors.red)),
                    )
                        : Text(displayStatus,
                        style: const TextStyle(color: Colors.grey)),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

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
        const Positioned( child: Opacity(opacity: 0.15)),
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
