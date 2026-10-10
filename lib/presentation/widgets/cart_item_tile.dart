import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/cart_item.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final variant = item.selectedVariant;
    final product = item.product;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image with CachedNetworkImage
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 70,
              height: 70,
              color: const Color(0xFFF7F7F3),
              child: product.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      memCacheWidth: 200,
                      memCacheHeight: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: const Color(0xFFEEEEEE)),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.local_florist,
                        color: AppColors.brandEmerald,
                        size: 30,
                      ),
                    )
                  : const Icon(
                      Icons.local_florist,
                      color: AppColors.brandEmerald,
                      size: 30,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Info & Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.brandTextDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  variant.title != 'Default Title' ? variant.title : 'Standard Unit',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'LE ${item.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.brandEmerald,
                    fontSize: 15,
                    fontFamily: 'sans-serif',
                  ),
                ),
              ],
            ),
          ),
          // Stepper + Delete Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSubtle,
                  size: 18,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<CartBloc>().add(RemoveFromCartEvent(variant.id));
                },
              ),
              const SizedBox(height: 6),
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.brandLightGreen,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.brandFreshGreen.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      icon: const Icon(
                        Icons.remove,
                        size: 14,
                        color: AppColors.brandEmerald,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.read<CartBloc>().add(
                              UpdateQuantityEvent(
                                variant.id,
                                item.quantity - 1,
                              ),
                            );
                      },
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.brandDarkGreen,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      icon: const Icon(
                        Icons.add,
                        size: 14,
                        color: AppColors.brandEmerald,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.read<CartBloc>().add(
                              UpdateQuantityEvent(
                                variant.id,
                                item.quantity + 1,
                              ),
                            );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
