import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brandDarkGreen.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 75,
              height: 75,
              color: const Color(0xFFF1E9D7),
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.local_florist,
                      color: AppColors.brandDarkGreen,
                    ),
            ),
          ),
          const SizedBox(width: 12),
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
                    color: AppColors.brandDarkGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  variant.title != 'Default Title'
                      ? variant.title
                      : 'Standard Unit',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'LE ${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.brandDarkGreen,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () => context.read<CartBloc>().add(
                  RemoveFromCartEvent(variant.id),
                ),
              ),
              Container(
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.brandDarkGreen.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      icon: const Icon(
                        Icons.remove,
                        size: 14,
                        color: AppColors.brandDarkGreen,
                      ),
                      onPressed: () =>
                          context.read<CartBloc>().add(
                            UpdateQuantityEvent(
                              variant.id,
                              item.quantity - 1,
                            ),
                          ),
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
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      icon: const Icon(
                        Icons.add,
                        size: 14,
                        color: AppColors.brandDarkGreen,
                      ),
                      onPressed: () =>
                          context.read<CartBloc>().add(
                            UpdateQuantityEvent(
                              variant.id,
                              item.quantity + 1,
                            ),
                          ),
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
