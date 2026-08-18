import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/product.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../pages/product_details_page.dart';

class ExactMatchProductCard extends StatelessWidget {
  final Product product;
  final int delay;
  final VoidCallback? onGoToCart;
  final String? heroTag;

  const ExactMatchProductCard({
    super.key,
    required this.product,
    required this.delay,
    this.onGoToCart,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final startingPrice = product.variants.isNotEmpty
        ? product.variants.first.price
        : 0.0;
    final effectiveHeroTag = heroTag ?? 'product_image_${product.id}';

    return RepaintBoundary(
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.brandDarkGreen,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top clickable image & product info section
            Expanded(
              flex: 6,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsPage(
                        product: product,
                        heroTag: effectiveHeroTag,
                      ),
                    ),
                  ).then((value) {
                    if (value == true && onGoToCart != null) {
                      onGoToCart!();
                    }
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Hero(
                        tag: effectiveHeroTag,
                        child: Container(
                          color: const Color(0xFFF1E9D7),
                          child: product.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: product.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(color: Colors.grey[200]),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                        Icons.broken_image,
                                        color: AppColors.brandDarkGreen,
                                      ),
                                )
                              : const Icon(
                                  Icons.local_florist,
                                  size: 40,
                                  color: AppColors.brandDarkGreen,
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: AppColors.brandGold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (index) => const Icon(
                                  Icons.star,
                                  size: 11,
                                  color: AppColors.brandGold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '(3)',
                                style: TextStyle(
                                  color: AppColors.brandGold,
                                  fontSize: 10,
                                  fontFamily: 'sans-serif',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'LE ${startingPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'sans-serif',
                              color: AppColors.brandGold,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'LE ${startingPrice.toStringAsFixed(2)}/250g',
                            style: TextStyle(
                              fontFamily: 'sans-serif',
                              color: AppColors.brandGold.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom non-navigating + / - counter row
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) {
                  final variant = product.variants.isNotEmpty
                      ? product.variants.first
                      : null;

                  final cartItemIndex = variant != null
                      ? cartState.items.indexWhere(
                          (item) => item.selectedVariant.id == variant.id,
                        )
                      : -1;

                  final cartQuantity = cartItemIndex >= 0
                      ? cartState.items[cartItemIndex].quantity
                      : 0;

                  return Container(
                    height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.brandGold.withValues(alpha: 0.8),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          icon: Icon(
                            Icons.remove,
                            color: AppColors.brandGold.withValues(alpha: 0.8),
                            size: 16,
                          ),
                          onPressed: (cartQuantity > 0 && variant != null)
                              ? () => context.read<CartBloc>().add(
                                    UpdateQuantityEvent(
                                      variant.id,
                                      cartQuantity - 1,
                                    ),
                                  )
                              : null,
                        ),
                        Text(
                          '$cartQuantity',
                          style: const TextStyle(
                            fontFamily: 'sans-serif',
                            color: AppColors.brandGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          icon: Icon(
                            Icons.add,
                            color: AppColors.brandGold.withValues(alpha: 0.8),
                            size: 16,
                          ),
                          onPressed: variant != null
                              ? () {
                                  context.read<CartBloc>().add(
                                        AddToCartEvent(
                                          product: product,
                                          variant: variant,
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: AppColors.brandDarkGreen,
                                      content: Text(
                                        'Added "${product.title}" to cart!',
                                        style: const TextStyle(
                                          color: AppColors.brandGold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    )
    .animate(delay: delay.ms)
    .fadeIn(duration: 400.ms)
    .slideY(
      begin: 0.08,
      end: 0,
      duration: 400.ms,
      curve: Curves.easeOutQuart,
    );
  }
}
