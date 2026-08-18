import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../widgets/auth_login_form.dart';
import '../widgets/auth_register_form.dart';
import '../widgets/order_card.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLoginTab = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red[900],
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is RegisterSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.brandDarkGreen,
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.brandGold),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.message,
                      style: const TextStyle(
                        color: AppColors.brandGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          setState(() {
            _isLoginTab = true;
          });
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(
            key: ValueKey('profile_loading'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.brandDarkGreen),
                SizedBox(height: 16),
                Text(
                  "Connecting to Shopify...",
                  style: TextStyle(
                    color: AppColors.brandDarkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is Authenticated) {
          final customer = state.customer;
          return SingleChildScrollView(
            key: const ValueKey('authenticated_profile'),
            padding: const EdgeInsets.all(16.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Member Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.brandDarkGreen, Color(0xFF144D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandDarkGreen.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.brandGold,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.brandDarkGreen,
                              child: Text(
                                customer.firstName.isNotEmpty
                                    ? customer.firstName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brandGold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.fullName.isNotEmpty
                                      ? customer.fullName
                                      : 'Valued Customer',
                                  style: const TextStyle(
                                    color: AppColors.brandGold,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Georgia',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  customer.email,
                                  style: TextStyle(
                                    color: AppColors.brandCream.withValues(alpha: 0.9),
                                    fontSize: 13,
                                  ),
                                ),
                                if (customer.phone != null &&
                                    customer.phone!.isNotEmpty)
                                  Text(
                                    customer.phone!,
                                    style: TextStyle(
                                      color: AppColors.brandCream.withValues(alpha: 0.9),
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Sign Out',
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.redAccent,
                              size: 26,
                            ),
                            onPressed: () {
                              context.read<AuthBloc>().add(LogoutEvent());
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppColors.brandDarkGreen,
                                  content: Text(
                                    'Signed out successfully.',
                                    style: TextStyle(color: AppColors.brandGold),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.brandGold.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: AppColors.brandGold, size: 16),
                            SizedBox(width: 6),
                            Text(
                              "Fresh Yard Organic Member",
                              style: TextStyle(
                                color: AppColors.brandGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Saved Address Card
                if (customer.defaultAddress != null &&
                    customer.defaultAddress!.isNotEmpty) ...[
                  const Text(
                    "Saved Delivery Address",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandDarkGreen,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.brandDarkGreen.withValues(alpha: 0.15),
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.brandDarkGreen.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.brandDarkGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            customer.defaultAddress!,
                            style: const TextStyle(
                              color: AppColors.brandTextDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Order History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Order History (${customer.orders.length})",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandDarkGreen,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    const Icon(Icons.history, color: AppColors.brandDarkGreen),
                  ],
                ),
                const SizedBox(height: 12),
                if (customer.orders.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.brandDarkGreen.withValues(alpha: 0.08),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 54,
                          color: AppColors.brandGold,
                        ),
                        SizedBox(height: 12),
                        Text(
                          "No past orders found yet.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandDarkGreen,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Your completed store orders will appear here automatically.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customer.orders.length,
                    itemBuilder: (context, index) {
                      return OrderCard(order: customer.orders[index]);
                    },
                  ),
              ],
            ),
          );
        }

        // Unauthenticated View
        return SingleChildScrollView(
          key: const ValueKey('unauthenticated_profile'),
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Luxury Hero Card Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brandDarkGreen, Color(0xFF104029)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.brandGold.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_pin,
                        color: AppColors.brandGold,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Welcome to The Fresh Yard",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.brandGold,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Sign in or create an account to view past orders, track live deliveries, & enjoy member perks.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.brandCream.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Main Glassmorphic Auth Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Segmented Pill Switcher
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.brandDarkGreen.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isLoginTab = true;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _isLoginTab
                                      ? AppColors.brandDarkGreen
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: _isLoginTab
                                      ? [
                                          BoxShadow(
                                            color: AppColors.brandDarkGreen.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  "Sign In",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _isLoginTab
                                        ? AppColors.brandGold
                                        : AppColors.brandDarkGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isLoginTab = false;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: !_isLoginTab
                                      ? AppColors.brandDarkGreen
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: !_isLoginTab
                                      ? [
                                          BoxShadow(
                                            color: AppColors.brandDarkGreen.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  "Create Account",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: !_isLoginTab
                                        ? AppColors.brandGold
                                        : AppColors.brandDarkGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_isLoginTab)
                      const AuthLoginForm()
                    else
                      const AuthRegisterForm(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Benefits Grid Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBenefitBadge(Icons.eco_outlined, "100% Organic"),
                  _buildBenefitBadge(
                    Icons.local_shipping_outlined,
                    "Fast Express",
                  ),
                  _buildBenefitBadge(Icons.security, "Shopify Secured"),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBenefitBadge(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: AppColors.brandDarkGreen, size: 22),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.brandDarkGreen,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
