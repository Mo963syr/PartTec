import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.bgGradientA,
            AppColors.bgGradientB,
            AppColors.bgGradientC
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpaces.md),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class FloatingSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback? onClear;
  final String hint;
  const FloatingSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.onClear,
    this.hint = 'ابحث...',
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
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: (controller.text.isNotEmpty && onClear != null)
              ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
              : null,
        ),
      ),
    );
  }
}

class VisibilityToggle extends StatelessWidget {
  final bool isPrivate;
  final ValueChanged<bool> onChanged;
  const VisibilityToggle(
      {super.key, required this.isPrivate, required this.onChanged});

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
          _segBtn(context,
              label: 'عامة',
              selected: !isPrivate,
              onTap: () => onChanged(false)),
          _segBtn(context,
              label: 'خاصة', selected: isPrivate, onTap: () => onChanged(true)),
        ],
      ),
    );
  }

  Expanded _segBtn(BuildContext ctx,
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
              color: selected ? AppColors.primary : AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryChipsBar extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const CategoryChipsBar(
      {super.key,
      required this.categories,
      required this.selectedIndex,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpaces.md),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, i) {
          final label = categories[i]['label'] as String;
          final icon = categories[i]['icon'] as IconData;
          final isSel = selectedIndex == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: isSel ? AppColors.primary : AppColors.chipBorder),
                boxShadow: [
                  if (isSel)
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                ],
              ),
              child: Row(
                children: [
                  Icon(icon,
                      size: 18, color: isSel ? Colors.white : AppColors.text),
                  const SizedBox(width: 6),
                  Text(label,
                      style: TextStyle(
                          color: isSel ? Colors.white : AppColors.text,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: AppSpaces.xs),
        itemCount: categories.length,
      ),
    );
  }
}
