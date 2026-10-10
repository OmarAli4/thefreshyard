import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/admin_service.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../pages/admin_dashboard_page.dart';
import '../widgets/auth_login_form.dart';
import '../widgets/auth_register_form.dart';
import '../widgets/otp_verification_form.dart';
import '../widgets/order_card.dart';


class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLoginTab = true;
  String? _prefilledEmail;

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
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.message,
                      style: TextStyle(
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
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.message,
                      style: TextStyle(
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
            _prefilledEmail = state.registeredEmail;
          });
        } else if (state is ForgotPasswordSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.brandDarkGreen,
              duration: const Duration(seconds: 4),
              content: Row(
                children: [
                  const Icon(Icons.mark_email_read_outlined, color: AppColors.brandGold),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.message,
                      style: TextStyle(
                        color: AppColors.brandGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return Center(
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
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brandGold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.fullName.isNotEmpty
                                      ? customer.fullName
                                      : 'Valued Customer',
                                  style: TextStyle(
                                    color: AppColors.brandGold,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Georgia',
                                  ),
                                ),
                                SizedBox(height: 4),
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
                              size: 24,
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
                      SizedBox(height: 16),
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
                        child: Row(
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

                      // Admin Dashboard Button: Strictly for Authorized Admin Users Only
                      if (AdminService.instance.isEmailAdmin(customer.email)) ...[
                        Container(
                          margin: const EdgeInsets.only(top: 14),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandGold,
                              foregroundColor: AppColors.brandDarkGreen,
                              elevation: 4,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () => _showAdminPinPrompt(context),
                            icon: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.brandDarkGreen, size: 20),
                            label: const Text(
                              "👑 Admin Control Center",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Saved Address Card
                if (customer.defaultAddress != null &&
                    customer.defaultAddress!.isNotEmpty) ...[
                  Text(
                    "Saved Delivery Address",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandDarkGreen,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.brandGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.brandDarkGreen,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            customer.defaultAddress!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.brandTextDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],

                // Past Orders List
                Text(
                  "Order History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandDarkGreen,
                    fontFamily: 'Georgia',
                  ),
                ),
                SizedBox(height: 8),

                if (customer.orders.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.brandGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "No orders placed yet.",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
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
                SizedBox(height: 30),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          key: const ValueKey('unauthenticated_profile'),
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),

              // Luxury Member Card Hero
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brandDarkGreen, Color(0xFF104029)],
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
                    SizedBox(height: 12),
                    Text(
                      "Welcome to The Fresh Yard",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.brandGold,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    SizedBox(height: 6),
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
              SizedBox(height: 24),

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
                    if (state is OtpSentState) ...[
                      OtpVerificationForm(
                        email: state.email,
                        isNewUser: state.isNewUser,
                        onBack: () => context.read<AuthBloc>().add(LogoutEvent()),
                      ),
                    ] else ...[
                      if (_isLoginTab)
                        AuthLoginForm(initialEmail: _prefilledEmail)
                      else
                        const AuthRegisterForm(),

                      const SizedBox(height: 16),

                      // Toggle link
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLoginTab = !_isLoginTab;
                          });
                        },
                        child: Text.rich(
                          TextSpan(
                            text: _isLoginTab
                                ? "Don't have an account? "
                                : "Already have an account? ",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: _isLoginTab ? "Create Account" : "Sign In",
                                style: const TextStyle(
                                  color: AppColors.brandDarkGreen,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 24),

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
              const SizedBox(height: 20),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAdminPinPrompt(BuildContext parentContext) {
    final pinController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (builderCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.brandGold, width: 1.2),
              ),
              title: Row(
                children: [
                  const Icon(Icons.admin_panel_settings_rounded, color: AppColors.brandDarkGreen, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Admin Authorization",
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandDarkGreen,
                        fontSize: 17,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Enter the 4-digit Admin Security PIN to manage banners, categories, and view app sales.",
                    style: TextStyle(fontSize: 12.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: "4-Digit PIN",
                      hintText: "••••",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandDarkGreen,
                    foregroundColor: AppColors.brandGold,
                  ),
                  onPressed: () async {
                    final pin = pinController.text.trim();
                    final isValid = await AdminService.instance.verifyPin(pin);
                    if (dialogCtx.mounted) {
                      Navigator.of(dialogCtx).pop();
                    }
                    if (isValid && parentContext.mounted) {
                      Navigator.push(
                        parentContext,
                        MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                      );
                    } else if (!isValid && parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text("Incorrect Admin PIN. Default PIN is 2026."),
                        ),
                      );
                    }
                  },
                  child: const Text("Enter Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBenefitBadge(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: AppColors.brandDarkGreen, size: 22),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: AppColors.brandDarkGreen,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}



