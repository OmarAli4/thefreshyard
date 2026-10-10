import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/animated_walking_man.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../widgets/safe_network_image.dart';

const Color brandDarkGreen = AppColors.brandDarkGreen;
const Color brandCream = AppColors.brandCream;
const Color brandGold = AppColors.brandGold;

class ProductDetailsPage extends StatefulWidget {
  final Product product;
  final String? heroTag;

  const ProductDetailsPage({super.key, required this.product, this.heroTag});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final startingPrice = widget.product.variants.isNotEmpty ? widget.product.variants.first.price : 0.0;
    final effectiveHeroTag = widget.heroTag ?? 'product_image_${widget.product.id}';
    
    return Scaffold(
      backgroundColor: brandDarkGreen,
      appBar: AppBar(
        backgroundColor: brandDarkGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: brandGold),
        title: const AnimatedWalkingMan(
          height: 36,
          color: brandGold,
          duration: Duration(milliseconds: 1200),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              return IconButton(
                icon: Badge(
                  isLabelVisible: cartState.totalItemCount > 0,
                  label: Text('${cartState.totalItemCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.redAccent,
                  child: const Icon(Icons.shopping_bag_outlined, color: brandGold),
                ),
                onPressed: () => Navigator.pop(context, true),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 340,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Hero(
                  tag: effectiveHeroTag,
                  child: SafeNetworkImage(
                    imageUrl: widget.product.imageUrl ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.product.title,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: brandGold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Price and Sale
                  Row(
                    children: [
                      if (widget.product.variants.isNotEmpty &&
                          widget.product.variants.first.compareAtPrice != null &&
                          widget.product.variants.first.compareAtPrice! > startingPrice) ...[
                        Text(
                          'LE ${widget.product.variants.first.compareAtPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: brandGold.withValues(alpha: 0.5),
                            decoration: TextDecoration.lineThrough,
                            decorationColor: brandGold.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      // New Price
                      Text(
                        'LE ${startingPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: brandGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Sale Badge
                  if (widget.product.variants.isNotEmpty &&
                      widget.product.variants.first.compareAtPrice != null &&
                      widget.product.variants.first.compareAtPrice! > startingPrice)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${((1 - startingPrice / widget.product.variants.first.compareAtPrice!) * 100).toStringAsFixed(0)}% OFF',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 16),
                  Text(
                    'Shipping calculated at checkout.',
                    style: TextStyle(color: brandGold.withValues(alpha: 0.8), decoration: TextDecoration.underline, decorationColor: brandGold.withValues(alpha: 0.8)),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Quantity
                  const Text('Quantity', style: TextStyle(color: brandGold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    width: 140,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: brandGold, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: brandGold, size: 20),
                          onPressed: () {
                            if (quantity > 1) setState(() => quantity--);
                          },
                        ),
                        Text('$quantity', style: const TextStyle(color: brandGold, fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, color: brandGold, size: 20),
                          onPressed: () => setState(() => quantity++),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Add to cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: brandCream, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: () {
                        if (widget.product.variants.isNotEmpty) {
                          context.read<CartBloc>().add(
                            AddToCartEvent(
                              product: widget.product,
                              variant: widget.product.variants.first,
                              quantity: quantity,
                            ),
                          );
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: brandCream,
                              content: Text('Added $quantity x "${widget.product.title}" to cart!', style: const TextStyle(color: brandDarkGreen, fontWeight: FontWeight.bold)),
                            ),
                          );
                        }
                      },
                      child: const Text('Add to cart', style: TextStyle(color: brandCream, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Buy it now Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandCream,
                        foregroundColor: brandDarkGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: () {
                        if (widget.product.variants.isNotEmpty) {
                          context.read<CartBloc>().add(
                            AddToCartEvent(
                              product: widget.product,
                              variant: widget.product.variants.first,
                              quantity: quantity,
                            ),
                          );
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('Buy it now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Description
                  Text(
                    (widget.product.description != null && widget.product.description!.isNotEmpty)
                        ? widget.product.description!
                        : 'Experience the finest selection of fresh items from The Fresh Yard. Carefully handpicked for exceptional freshness, vibrant color, and outstanding flavor.',
                    style: TextStyle(
                      color: brandGold.withValues(alpha: 0.9),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
