import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../widgets/animated_drawing_text_logo.dart';

const Color brandDarkGreen = AppColors.brandDarkGreen;
const Color brandCream = AppColors.brandCream;
const Color brandGold = AppColors.brandGold;
const Color brandTextDark = AppColors.brandTextDark;

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isLoginTab = true;
  bool _isPasswordVisible = false;
  String? _formValidationError;

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final TextEditingController _regFirstNameController = TextEditingController();
  final TextEditingController _regLastNameController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regFirstNameController.dispose();
    _regLastNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandCream,
      appBar: AppBar(
        backgroundColor: brandDarkGreen,
        elevation: 0,
        centerTitle: true,
        title: const AnimatedDrawingTextLogo(
          height: 24.0,
          strokeColor: brandGold,
          fillColor: brandGold,
          duration: Duration(seconds: 3),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: brandGold, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
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
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                backgroundColor: brandDarkGreen,
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: brandGold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: brandGold, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
            setState(() {
              _isLoginTab = true;
              _formValidationError = null;
            });
          } else if (state is Authenticated) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: brandDarkGreen,
                content: Text(
                  'Welcome, ${state.customer.fullName}!',
                  style: const TextStyle(color: brandGold, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: brandDarkGreen),
                  SizedBox(height: 16),
                  Text("Authenticating with Shopify...", style: TextStyle(color: brandDarkGreen, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            );
          }

          if (state is Authenticated) {
            final customer = state.customer;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [brandDarkGreen, Color(0xFF144D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: brandDarkGreen.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(color: brandGold, shape: BoxShape.circle),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: brandDarkGreen,
                                child: Text(
                                  customer.firstName.isNotEmpty ? customer.firstName[0].toUpperCase() : 'U',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: brandGold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.fullName.isNotEmpty ? customer.fullName : 'Valued Customer',
                                    style: const TextStyle(color: brandGold, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(customer.email, style: TextStyle(color: brandCream.withValues(alpha: 0.9), fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                
                // Luxury Hero Card Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [brandDarkGreen, Color(0xFF104029)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: brandDarkGreen.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: brandGold.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.lock_person_outlined, color: brandGold, size: 38),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _isLoginTab ? "Sign In to Your Account" : "Join The Fresh Yard",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: brandGold, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isLoginTab
                            ? "Enter your credentials to access your organic order history & saved addresses."
                            : "Create a new member account to enjoy fast checkout & exclusive organic perks.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: brandCream.withValues(alpha: 0.85), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Auth Form Card Container
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: brandGold.withValues(alpha: 0.35), width: 1.2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Segmented Pill Switcher
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: brandDarkGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isLoginTab = true;
                                    _formValidationError = null;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isLoginTab ? brandDarkGreen : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: _isLoginTab ? [BoxShadow(color: brandDarkGreen.withValues(alpha: 0.25), blurRadius: 4)] : [],
                                  ),
                                  child: Text(
                                    "Sign In",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _isLoginTab ? brandGold : brandDarkGreen,
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
                                    _formValidationError = null;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isLoginTab ? brandDarkGreen : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: !_isLoginTab ? [BoxShadow(color: brandDarkGreen.withValues(alpha: 0.25), blurRadius: 4)] : [],
                                  ),
                                  child: Text(
                                    "Create Account",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: !_isLoginTab ? brandGold : brandDarkGreen,
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

                      // Validation Error Banner
                      if (_formValidationError != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_formValidationError!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ],
                          ),
                        ),

                      if (_isLoginTab) ...[
                        // SIGN IN FORM
                        TextField(
                          controller: _loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email Address",
                            hintText: "example@gmail.com",
                            labelStyle: const TextStyle(color: brandDarkGreen),
                            prefixIcon: const Icon(Icons.email_outlined, color: brandDarkGreen),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: brandDarkGreen, width: 2)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _loginPasswordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: const TextStyle(color: brandDarkGreen),
                            prefixIcon: const Icon(Icons.lock_outline, color: brandDarkGreen),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: brandDarkGreen),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: brandDarkGreen, width: 2)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandDarkGreen,
                              foregroundColor: brandGold,
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                            ),
                            onPressed: () {
                              final email = _loginEmailController.text.trim();
                              final pass = _loginPasswordController.text.trim();

                              if (email.isEmpty || !email.contains('@')) {
                                setState(() => _formValidationError = "Please enter a valid email address.");
                                return;
                              }
                              if (pass.isEmpty) {
                                setState(() => _formValidationError = "Please enter your password.");
                                return;
                              }

                              setState(() => _formValidationError = null);
                              context.read<AuthBloc>().add(LoginEvent(email: email, password: pass));
                            },
                            icon: const Icon(Icons.login, color: brandGold),
                            label: const Text("Sign In", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ] else ...[
                        // CREATE ACCOUNT FORM
                        TextField(
                          controller: _regFirstNameController,
                          decoration: InputDecoration(
                            labelText: "First Name",
                            labelStyle: const TextStyle(color: brandDarkGreen),
                            prefixIcon: const Icon(Icons.person_outline, color: brandDarkGreen),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: brandDarkGreen, width: 2)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _regLastNameController,
                          decoration: InputDecoration(
                            labelText: "Last Name",
                            labelStyle: const TextStyle(color: brandDarkGreen),
                            prefixIcon: const Icon(Icons.person_outline, color: brandDarkGreen),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: brandDarkGreen, width: 2)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _regEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email Address",
                            hintText: "example@gmail.com",
                            labelStyle: const TextStyle(color: brandDarkGreen),
                            prefixIcon: const Icon(Icons.email_outlined, color: brandDarkGreen),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: brandDarkGreen, width: 2)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _regPasswordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Password (min 6 characters)",
                            labelStyle: const TextStyle(color: brandDarkGreen),
                            prefixIcon: const Icon(Icons.lock_outline, color: brandDarkGreen),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: brandDarkGreen),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: brandDarkGreen, width: 2)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandDarkGreen,
                              foregroundColor: brandGold,
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                            ),
                            onPressed: () {
                              final fn = _regFirstNameController.text.trim();
                              final ln = _regLastNameController.text.trim();
                              final email = _regEmailController.text.trim();
                              final pass = _regPasswordController.text.trim();

                              if (fn.isEmpty) {
                                setState(() => _formValidationError = "Please enter your first name.");
                                return;
                              }
                              if (email.isEmpty || !email.contains('@')) {
                                setState(() => _formValidationError = "Please enter a valid email address.");
                                return;
                              }
                              if (pass.length < 6) {
                                setState(() => _formValidationError = "Password must be at least 6 characters.");
                                return;
                              }

                              setState(() => _formValidationError = null);
                              context.read<AuthBloc>().add(RegisterEvent(
                                firstName: fn,
                                lastName: ln,
                                email: email,
                                password: pass,
                              ));
                            },
                            icon: const Icon(Icons.person_add_alt_1, color: brandGold),
                            label: const Text("Create Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Benefits Grid Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBenefitBadge(Icons.eco_outlined, "100% Organic"),
                    _buildBenefitBadge(Icons.local_shipping_outlined, "Fast Express"),
                    _buildBenefitBadge(Icons.security, "Shopify Secured"),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBenefitBadge(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: brandDarkGreen, size: 22),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: brandDarkGreen, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
