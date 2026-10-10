import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'safe_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../pages/product_details_page.dart';
import '../pages/category_products_page.dart';

import '../../data/datasources/product_remote_data_source.dart';

class BestSellersSection extends StatefulWidget {
  final List<Product> fallbackProducts;
  final VoidCallback onGoToCart;

  const BestSellersSection({
    super.key,
    required this.fallbackProducts,
    required this.onGoToCart,
  });

  @override
  State<BestSellersSection> createState() => _BestSellersSectionState();
}

class _BestSellersSectionState extends State<BestSellersSection> {
  List<Product>? _bestSellers;

  @override
  void initState() {
    super.initState();
    _fetchBestSellers();
  }

  Future<void> _fetchBestSellers() async {
    try {
      final dataSource = ProductRemoteDataSourceImpl();
      final models = await dataSource.getBestSellingProducts(limit: 11);
      if (mounted && models.isNotEmpty) {
        setState(() {
          _bestSellers = models.map((m) => m.toDomain()).toList();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bestSellerItems = _bestSellers ?? widget.fallbackProducts.take(11).toList();

    if (bestSellerItems.isEmpty) {
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
                        color: AppColors.brandGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: AppColors.brandGold,
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
                            'Best Sellers',
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
                            'Most loved fresh picks by our community',
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
                  color: AppColors.brandGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.brandGold.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  'TOP RATED',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brandGold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal Best Seller Cards
        SizedBox(
          height: 298,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: bestSellerItems.length,
            itemBuilder: (context, index) {
              final product = bestSellerItems[index];
              final startingPrice = product.variants.isNotEmpty
                  ? product.variants.first.price
                  : 0.0;
              final heroTag = 'best_seller_prod_${product.id}_$index';

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
                              widget.onGoToCart();
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
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15),
                                      ),
                                      child: SafeNetworkImage(
                                        imageUrl: product.imageUrl ?? '',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Best Seller Badge
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.brandGold,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.25),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'BEST SELLER',
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.brandDarkGreen,
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
                                    const SizedBox(height: 2),
                                    // Rating Stars
                                    if (product.rating != null && product.ratingCount != null && product.ratingCount! > 0)
                                      Row(
                                        children: [
                                          ...List.generate(
                                            5,
                                            (i) => Icon(
                                              i < product.rating!.round() ? Icons.star_rounded : Icons.star_border_rounded,
                                              size: 11,
                                              color: AppColors.brandGold,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            product.rating!.toStringAsFixed(1),
                                            style: const TextStyle(
                                              color: AppColors.brandGold,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    const Spacer(),
                                    Text(
                                      'LE ${startingPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.brandGold,
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

        // Stylish View More Button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryProductsPage(
                      categoryTitle: 'Best Selling Products',
                      collectionHandle: 'best-selling-products',
                      onGoToCart: widget.onGoToCart,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.brandDarkGreen,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: AppColors.brandGold.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View More Best Sellers',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandGold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.brandGold,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
