import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../widgets/animated_walking_man.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/free_shipping_progress.dart';

class CartView extends StatefulWidget {
  final VoidCallback onExploreProducts;

  const CartView({
    super.key,
    required this.onExploreProducts,
  });

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final TextEditingController _deliveryNoteController = TextEditingController();

  @override
  void dispose() {
    _deliveryNoteController.dispose();
    super.dispose();
  }

  void _launchCheckout(BuildContext context, String checkoutUrl) async {
    final uri = Uri.parse(checkoutUrl);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Strict Security HTTPS and Whitelist Domain Validation
    final host = uri.host.toLowerCase();
    final isValidScheme = uri.scheme == 'https';
    final isValidDomain = ApiConstants.checkoutAllowedDomains.any(
      (domain) => host == domain.toLowerCase() || host.endsWith('.${domain.toLowerCase()}'),
    );

    if (!isValidScheme || !isValidDomain) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.saleRed,
          content: Text(
            'Security Alert: Unauthorized checkout domain blocked.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return;
    }

    try {
      if (kIsWeb) {
        // On Web / Mobile Web: Navigate directly in current tab (_self)
        // This prevents popup blockers on Mobile Safari & Mobile Chrome from blocking checkout
        final launched = await launchUrl(
          uri,
          webOnlyWindowName: '_self',
        );
        if (!launched) {
          await launchUrl(uri, webOnlyWindowName: '_blank');
        }
      } else {
        // On Native Mobile App (iOS / Android APK)
        bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
        if (!launched) {
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
        }
      }
    } catch (e) {
      try {
        await launchUrl(uri);
      } catch (err) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            backgroundColor: AppColors.saleRed,
            content: Text(
              'Error opening checkout: $err',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
        if (state.checkoutNoticeMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.brandOrange,
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
              backgroundColor: AppColors.saleRed,
              content: Text(
                state.checkoutError!,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        if (state.checkoutUrl != null && !state.isCheckoutLoading) {
          final url = state.checkoutUrl!;
          // Reset checkout state immediately so it never fires again on next cart change
          context.read<CartBloc>().add(ResetCheckoutStateEvent());
          _launchCheckout(context, url);
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.brandDarkGreen,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const AnimatedWalkingMan(
                      height: 70,
                      color: AppColors.brandGold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Your Cart is Empty",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandTextDark,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Explore fresh organic fruits, vegetables, & farm-to-table harvests!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandDarkGreen,
                      foregroundColor: AppColors.brandGold,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: widget.onExploreProducts,
                    icon: const Icon(Icons.storefront_rounded, size: 20),
                    label: const Text(
                      "Start Shopping",
                      style: TextStyle(
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

        final totalAmount = state.subtotal;

        return SingleChildScrollView(
          key: const ValueKey('cart_content'),
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "My Basket",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandDarkGreen,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.brandLightGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${state.totalItemCount} Items',
                          style: const TextStyle(
                            color: AppColors.brandEmerald,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.read<CartBloc>().add(ClearCartEvent());
                    },
                    icon: const Icon(
                      Icons.delete_sweep_outlined,
                      color: AppColors.saleRed,
                      size: 18,
                    ),
                    label: const Text(
                      "Clear All",
                      style: TextStyle(
                        color: AppColors.saleRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Free Shipping Bar
              FreeShippingProgress(subtotal: state.subtotal),
              const SizedBox(height: 16),

              // Items List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  return CartItemTile(item: state.items[index]);
                },
              ),
              const SizedBox(height: 16),

              // Promo Code Info Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_offer_outlined, color: AppColors.brandDarkGreen, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Discount codes can be applied at checkout",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandTextDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Note for Courier Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.edit_note_rounded, color: AppColors.brandDarkGreen, size: 20),
                        SizedBox(width: 6),
                        Text(
                          "Delivery Note (Optional)",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandTextDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _deliveryNoteController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Add specific instructions for courier (e.g. Ring bell, leave at door...)",
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSubtle),
                        contentPadding: const EdgeInsets.all(10),
                        filled: true,
                        fillColor: AppColors.surfaceWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.dividerColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bill Summary Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.brandDarkGreen,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandDarkGreen.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                          "LE ${state.subtotal.toStringAsFixed(0)}",
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
                          "Estimated Delivery",
                          style: TextStyle(color: AppColors.brandCream, fontSize: 14),
                        ),
                        Text(
                          "Calculated at checkout",
                          style: TextStyle(
                            color: AppColors.brandCream.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.brandGold, height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(
                            color: AppColors.brandCream,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "LE ${totalAmount.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: AppColors.brandGold,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandGold,
                          foregroundColor: AppColors.brandDarkGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: state.isCheckoutLoading
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
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
                          state.isCheckoutLoading ? "Preparing Secure Checkout..." : "Proceed to Checkout",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
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
