import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'safe_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../pages/product_details_page.dart';

class SpecialOffersSection extends StatelessWidget {
  final List<Product> products;
  final VoidCallback onGoToCart;

  const SpecialOffersSection({
    super.key,
    required this.products,
    required this.onGoToCart,
  });

  List<Product> _getOfferProducts() {
    if (products.isNotEmpty) {
      final discounted = products.where((p) {
        if (p.variants.isEmpty) return false;
        final v = p.variants.first;
        return v.compareAtPrice != null && v.compareAtPrice! > v.price;
      }).toList();

      return discounted.isNotEmpty
          ? discounted.take(6).toList()
          : products.take(6).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final offerItems = _getOfferProducts();

    if (offerItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC4AB63).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFE65100),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Special Offers & Deals',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandGold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Limited time discounts on fresh picks',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.brandCream.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'SPECIAL OFFERS',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brandDarkGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal Offer Cards
        SizedBox(
          height: 298,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: offerItems.length,
            itemBuilder: (context, index) {
              final product = offerItems[index];
              final firstVariant = product.variants.isNotEmpty
                  ? product.variants.first
                  : null;
              final startingPrice = firstVariant?.price ?? 0.0;
              final compareAtPrice = firstVariant?.compareAtPrice;
              final hasRealDiscount = compareAtPrice != null && compareAtPrice > startingPrice;
              final heroTag = 'offer_product_${product.id}';

              return Container(
                width: 165,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandDarkGreen,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.brandGold.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Clickable Area
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsPage(
                                product: product,
                                heroTag: heroTag,
                              ),
                            ),
                          ).then((value) {
                            if (value == true) {
                              onGoToCart();
                            }
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1:1 Image & Badge Area
                            AspectRatio(
                              aspectRatio: 1.0,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                      child: SafeNetworkImage(
                                        imageUrl: product.imageUrl ?? '',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Sale Badge
                                  if (hasRealDiscount)
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDC2626),
                                          borderRadius: BorderRadius.circular(6),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          'SAVE ${((1 - startingPrice / compareAtPrice) * 100).toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Info Area
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.brandGold,
                                        height: 1.15,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Prices
                                    Row(
                                      children: [
                                        Text(
                                          'LE ${startingPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.brandGold,
                                          ),
                                        ),
                                        if (hasRealDiscount) ...[
                                          const SizedBox(width: 6),
                                          Text(
                                            'LE ${compareAtPrice.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.brandGold.withValues(alpha: 0.5),
                                              decoration: TextDecoration.lineThrough,
                                              decorationColor: AppColors.brandGold.withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // [-] [Qty] [+] Counter Pill Row (Fixed at Bottom)
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
            },
          ),
        ),
      ],
    );
  }
}
