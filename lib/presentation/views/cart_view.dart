import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../widgets/cart_item_tile.dart';

class CartView extends StatelessWidget {
  final VoidCallback onExploreProducts;

  const CartView({
    super.key,
    required this.onExploreProducts,
  });

  void _launchCheckout(BuildContext context, String checkoutUrl) async {
    final uri = Uri.parse(checkoutUrl);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Strict Security HTTPS and Whitelist Domain Validation
    final isValidScheme = uri.scheme == 'https';
    final isValidDomain = ApiConstants.checkoutAllowedDomains.any(
      (domain) => uri.host == domain || uri.host.endsWith('.$domain'),
    );

    if (!isValidScheme || !isValidDomain) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Security Alert: Unauthorized checkout domain blocked.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return;
    }

    try {
      final isSupported = await canLaunchUrl(uri);
      if (isSupported) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Could not open secure browser for checkout.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error launching checkout browser: $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
        if (state.checkoutNoticeMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orange[800],
              duration: const Duration(seconds: 5),
              content: Text(
                state.checkoutNoticeMessage!,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        if (state.checkoutError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(
                state.checkoutError!,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        if (state.checkoutUrl != null && !state.isCheckoutLoading) {
          _launchCheckout(context, state.checkoutUrl!);
        }
      },
      builder: (context, state) {
        if (state.items.isEmpty) {
          return Center(
            key: const ValueKey('empty_cart'),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 90,
                    color: AppColors.brandGold.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Your Shopping Cart is Empty",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandDarkGreen,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Explore fresh organic fruits, vegetables, & signature mixes!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandDarkGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: onExploreProducts,
                    icon: const Icon(Icons.storefront, color: AppColors.brandGold),
                    label: const Text(
                      "Explore Products",
                      style: TextStyle(
                        color: AppColors.brandGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          key: const ValueKey('cart_content'),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Cart (${state.totalItemCount})",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandDarkGreen,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        context.read<CartBloc>().add(ClearCartEvent()),
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    label: const Text(
                      "Clear All",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    return CartItemTile(item: state.items[index]);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brandDarkGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Subtotal",
                          style: TextStyle(color: AppColors.brandCream, fontSize: 14),
                        ),
                        Text(
                          "LE ${state.subtotal.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: AppColors.brandGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Shipping",
                          style: TextStyle(color: AppColors.brandCream, fontSize: 14),
                        ),
                        Text(
                          "Calculated at checkout",
                          style: TextStyle(
                            color: AppColors.brandCream.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: AppColors.brandGold, height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            color: AppColors.brandGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "LE ${state.subtotal.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: AppColors.brandGold,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandGold,
                          foregroundColor: AppColors.brandDarkGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: state.isCheckoutLoading
                            ? null
                            : () {
                                final authState = context.read<AuthBloc>().state;
                                final token = authState is Authenticated ? authState.accessToken : null;
                                context.read<CartBloc>().add(
                                      CreateCheckoutSessionEvent(customerAccessToken: token),
                                    );
                              },
                        icon: state.isCheckoutLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.brandDarkGreen,
                                ),
                              )
                            : const Icon(
                                Icons.lock_outline,
                                color: AppColors.brandDarkGreen,
                              ),
                        label: Text(
                          state.isCheckoutLoading ? "Creating Checkout..." : "Proceed to Checkout",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
