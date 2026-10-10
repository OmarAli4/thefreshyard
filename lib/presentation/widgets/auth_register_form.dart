import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';

class AuthRegisterForm extends StatefulWidget {
  const AuthRegisterForm({super.key});

  @override
  State<AuthRegisterForm> createState() => _AuthRegisterFormState();
}

class _AuthRegisterFormState extends State<AuthRegisterForm> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _formValidationError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    final fn = _firstNameController.text.trim();
    final ln = _lastNameController.text.trim();
    final email = _emailController.text.trim();

    if (fn.isEmpty) {
      setState(() => _formValidationError = "Please enter your first name.");
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _formValidationError = "Please enter a valid email address.");
      return;
    }

    setState(() => _formValidationError = null);
    context.read<AuthBloc>().add(
      SendRegisterCodeEvent(
        firstName: fn,
        lastName: ln,
        email: email,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_formValidationError != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formValidationError!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // First Name
        TextField(
          controller: _firstNameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: "First Name *",
            labelStyle: const TextStyle(color: AppColors.brandDarkGreen),
            prefixIcon: const Icon(
              Icons.person_outline,
              color: AppColors.brandDarkGreen,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.brandDarkGreen,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Last Name
        TextField(
          controller: _lastNameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: "Last Name (Optional)",
            labelStyle: const TextStyle(color: AppColors.brandDarkGreen),
            prefixIcon: const Icon(
              Icons.person_outline,
              color: AppColors.brandDarkGreen,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.brandDarkGreen,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Email Address
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "Email Address *",
            hintText: "example@gmail.com",
            helperText: "No password required. We'll send you an instant verification code.",
            helperStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
            labelStyle: const TextStyle(color: AppColors.brandDarkGreen),
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.brandDarkGreen,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.brandDarkGreen,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onSubmitted: (_) => _submitRegister(),
        ),
        const SizedBox(height: 24),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandDarkGreen,
              foregroundColor: AppColors.brandGold,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            onPressed: _submitRegister,
            icon: const Icon(
              Icons.person_add_alt_1,
              color: AppColors.brandGold,
            ),
            label: const Text(
              "Create Account",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}