import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../pages/product_details_page.dart';
import 'safe_network_image.dart';

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

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.brandDarkGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brandGold.withValues(alpha: 0.35),
          width: 1.0,
        ),
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
          // 1. Top Clickable Section (Image + Info)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsPage(
                      product: product,
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
                  // 1:1 AspectRatio Square Image - 100% UN-CROPPED & UN-ZOOMED
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: SafeNetworkImage(
                        imageUrl: product.imageUrl ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Product Info Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontWeight: FontWeight.w500,
                              fontSize: 12.5,
                              color: AppColors.brandGold,
                              height: 1.15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          if (product.rating != null && product.ratingCount != null && product.ratingCount! > 0)
                            Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (index) => Icon(
                                    index < product.rating!.round() ? Icons.star : Icons.star_border,
                                    size: 11,
                                    color: AppColors.brandGold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${product.ratingCount})',
                                  style: const TextStyle(
                                    color: AppColors.brandGold,
                                    fontSize: 10,
                                    fontFamily: 'sans-serif',
                                  ),
                                ),
                              ],
                            ),
                          const Spacer(),
                          Text(
                            'LE ${startingPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'sans-serif',
                              color: AppColors.brandGold,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (product.variants.isNotEmpty &&
                              product.variants.first.title.isNotEmpty &&
                              product.variants.first.title != 'Default Title')
                            Text(
                              product.variants.first.title,
                              style: TextStyle(
                                fontFamily: 'sans-serif',
                                color: AppColors.brandGold.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w400,
                                fontSize: 9.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 2. Bottom Non-navigating Quantity Counter Row
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
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
                  height: 32,
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
                          minWidth: 26,
                          minHeight: 26,
                        ),
                        icon: Icon(
                          Icons.remove,
                          color: AppColors.brandGold.withValues(alpha: 0.8),
                          size: 15,
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
                          fontSize: 13,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 26,
                          minHeight: 26,
                        ),
                        icon: Icon(
                          Icons.add,
                          color: AppColors.brandGold.withValues(alpha: 0.8),
                          size: 15,
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
    );
  }
}
