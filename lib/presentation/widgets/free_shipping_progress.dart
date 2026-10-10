import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FreeShippingProgress extends StatelessWidget {
  final double subtotal;
  final double threshold;

  const FreeShippingProgress({
    super.key,
    required this.subtotal,
    this.threshold = 300.0,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (threshold - subtotal).clamp(0.0, threshold);
    final progress = (subtotal / threshold).clamp(0.0, 1.0);
    final isQualified = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isQualified ? AppColors.brandLightGreen : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isQualified
              ? AppColors.brandFreshGreen.withValues(alpha: 0.5)
              : AppColors.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isQualified ? Icons.check_circle : Icons.local_shipping_outlined,
                size: 20,
                color: isQualified
                    ? AppColors.brandFreshGreen
                    : AppColors.brandEmerald,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isQualified
                      ? "🎉 You've unlocked FREE Express Shipping!"
                      : "Add LE ${remaining.toStringAsFixed(0)} more for FREE Delivery!",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isQualified
                        ? AppColors.brandEmerald
                        : AppColors.brandTextDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                isQualified
                    ? AppColors.brandFreshGreen
                    : AppColors.brandGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
