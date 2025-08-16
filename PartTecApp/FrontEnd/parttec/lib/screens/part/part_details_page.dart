import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../widgets/ui_kit.dart';

import '../../providers/cart_provider.dart';
import '../../models/part.dart';
import 'part_reviews_section.dart';
import '../../utils/session_store.dart';

class PartDetailsPage extends StatelessWidget {
  final Part part;
  const PartDetailsPage({Key? key, required this.part}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = part.imageUrl;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            const GradientBackground(child: SizedBox.expand()),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  stretch: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  expandedHeight: 280,
                  leading: Padding(
                    padding:
                        const EdgeInsetsDirectional.only(start: 12, top: 8),
                    child: _CircleIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: imageUrl.isNotEmpty
                        ? Image.network(imageUrl, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 100)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(part.name,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.text)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text('\$${part.price}',
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary)),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(part.status ?? "غير محدد",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (part.serialNumber != null &&
                                    part.serialNumber!.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.qr_code_2,
                                          size: 18, color: AppColors.primary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                          child: Text(
                                              "تسلسلي: ${part.serialNumber}")),
                                      IconButton(
                                        icon: const Icon(Icons.copy, size: 18),
                                        onPressed: () async {
                                          await Clipboard.setData(ClipboardData(
                                              text: part.serialNumber!));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      "تم نسخ الرقم التسلسلي")));
                                        },
                                      )
                                    ],
                                  )
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(Icons.directions_car, "الموديل",
                                    part.model),
                                _buildDetailRow(Icons.factory, "الماركة",
                                    part.manufacturer),
                                _buildDetailRow(
                                    Icons.event,
                                    "سنة الصنع",
                                    part.year != 0
                                        ? part.year.toString()
                                        : "غير محدد"),
                                _buildDetailRow(Icons.local_gas_station,
                                    "نوع الوقود", part.fuelType),
                                _buildDetailRow(
                                    Icons.category, "الفئة", part.category),
                                const SizedBox(height: 10),
                                const Text("الوصف",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(part.description ?? "لا يوجد وصف"),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("تقييمات الزبائن",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                FutureBuilder<String?>(
                                  future: SessionStore.userId(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2)));
                                    }
                                    final uid = snapshot.data;
                                    if (uid == null || uid.isEmpty) {
                                      return const Text(
                                          "⚠️ الرجاء تسجيل الدخول لعرض/إضافة التقييمات.");
                                    }
                                    return PartReviewsSection(
                                        partId: part.id, userId: uid);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.of(context).padding.bottom,
              child: _BottomAddToCart(part: part),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? "غير متوفر")),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: child,
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _BottomAddToCart extends StatelessWidget {
  final Part part;
  const _BottomAddToCart({required this.part});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final success =
            await context.read<CartProvider>().addToCartToServer(part);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? "تمت الإضافة إلى السلة" : "فشلت الإضافة"),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
      },
      icon: const Icon(Icons.add_shopping_cart),
      label: const Text("إضافة إلى السلة"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
