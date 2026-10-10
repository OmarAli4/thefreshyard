import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final Map<String, String> category;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    this.count,
    required this.onTap,
  });

  String _getArabicCategoryName(String title) {
    final lower = title.toLowerCase();
    if (lower == 'all') return 'الكل • All';
    if (lower.contains('fruit') || lower.contains('berry') || lower.contains('mango')) return 'فواكه • Fruits';
    if (lower.contains('veg') || lower.contains('salad') || lower.contains('green')) return 'خضار • Veggies';
    if (lower.contains('organic') || lower.contains('bio')) return 'عضوي • Organic';
    if (lower.contains('juice') || lower.contains('drink')) return 'عصائر • Juices';
    if (lower.contains('box') || lower.contains('basket') || lower.contains('pack')) return 'بوكسات • Boxes';
    if (lower.contains('herbs') || lower.contains('leaves')) return 'أعشاب • Herbs';
    return title;
  }

  IconData _getCategoryIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('all')) return Icons.apps_rounded;
    if (lower.contains('fruit') || lower.contains('berry') || lower.contains('mango')) {
      return Icons.apple_rounded;
    }
    if (lower.contains('veg') || lower.contains('salad') || lower.contains('green')) {
      return Icons.grass_rounded;
    }
    if (lower.contains('organic') || lower.contains('bio')) {
      return Icons.eco_rounded;
    }
    if (lower.contains('juice') || lower.contains('drink') || lower.contains('beverage')) {
      return Icons.local_drink_rounded;
    }
    if (lower.contains('box') || lower.contains('basket') || lower.contains('pack')) {
      return Icons.inventory_2_rounded;
    }
    if (lower.contains('herbs') || lower.contains('leaves')) {
      return Icons.spa_rounded;
    }
    return Icons.local_florist_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final title = category['title']!;
    final displayName = _getArabicCategoryName(title);
    final icon = _getCategoryIcon(title);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF10B981),
            ),
            const SizedBox(width: 6),
            Text(
              displayName,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF0F5132),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
