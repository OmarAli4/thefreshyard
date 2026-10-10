import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';

class OtpVerificationForm extends StatefulWidget {
  final String email;
  final bool isNewUser;
  final VoidCallback? onBack;

  const OtpVerificationForm({
    super.key,
    required this.email,
    this.isNewUser = false,
    this.onBack,
  });

  @override
  State<OtpVerificationForm> createState() => _OtpVerificationFormState();
}

class _OtpVerificationFormState extends State<OtpVerificationForm> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorMessage;
  int _countdownSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _countdownSeconds = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        if (mounted) {
          setState(() => _countdownSeconds--);
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _openEmailApp() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: widget.email,
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        await launchUrl(Uri.parse('https://mail.google.com'), mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.brandDarkGreen,
            content: Text(
              "Please check your inbox in your email app.",
              style: TextStyle(color: AppColors.brandGold, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }

  Future<void> _openShopifyWebPortal() async {
    final uri = Uri.parse('https://thefreshyard.shop/account/login');
    try {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _submitCode() {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      setState(() => _errorMessage = "Please enter the complete 6-digit code.");
      return;
    }
    setState(() => _errorMessage = null);
    context.read<AuthBloc>().add(
      VerifyOtpEvent(
        email: widget.email,
        code: code,
      ),
    );
  }

  void _resendCode() {
    if (_countdownSeconds > 0) return;
    context.read<AuthBloc>().add(ResendOtpEvent(email: widget.email));
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.brandDarkGreen,
        content: Text(
          "A fresh 6-digit code has been sent to your email.",
          style: TextStyle(color: AppColors.brandGold, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOtpBoxes(String text) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Invisible TextField overlay
          Opacity(
            opacity: 0.0,
            child: SizedBox(
              height: 56,
              child: TextField(
                controller: _otpController,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (val) {
                  setState(() {});
                  if (val.length == 6) {
                    _submitCode();
                  }
                },
              ),
            ),
          ),
          // 6 distinct luxury digit cells
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              final isFilled = index < text.length;
              final isFocused = _focusNode.hasFocus && index == text.length;
              final char = isFilled ? text[index] : '';

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44,
                height: 52,
                decoration: BoxDecoration(
                  color: isFilled
                      ? AppColors.brandDarkGreen.withValues(alpha: 0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFocused
                        ? AppColors.brandDarkGreen
                        : (isFilled ? AppColors.brandGold : Colors.grey.shade300),
                    width: isFocused ? 2.2 : (isFilled ? 1.6 : 1.2),
                  ),
                  boxShadow: [
                    if (isFocused)
                      BoxShadow(
                        color: AppColors.brandDarkGreen.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                alignment: Alignment.center,
                child: isFilled
                    ? Text(
                        char,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandDarkGreen,
                        ),
                      )
                    : (isFocused
                        ? Container(
                            width: 2,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.brandDarkGreen,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          )
                        : Text(
                            "-",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Top Security / Email Illustration
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.brandGold.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.brandDarkGreen,
            size: 40,
          ),
        ),
        const SizedBox(height: 14),

        // Title
        Text(
          widget.isNewUser ? "Verify Your Account" : "Enter Sign-In Code",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.brandDarkGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle with highlighted email
        Text(
          "We sent a 6-digit verification code to:",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.brandDarkGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.email,
            style: const TextStyle(
              color: AppColors.brandDarkGreen,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Error message banner
        if (_errorMessage != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

        // 6-Digit Distinct OTP Boxes
        _buildOtpBoxes(_otpController.text),
        const SizedBox(height: 22),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandDarkGreen,
              foregroundColor: AppColors.brandGold,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            ),
            onPressed: _submitCode,
            icon: const Icon(Icons.verified_user_rounded, color: AppColors.brandGold),
            label: const Text(
              "Verify & Continue",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Open Email App Quick Button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandDarkGreen,
              side: BorderSide(color: AppColors.brandDarkGreen.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
            ),
            onPressed: _openEmailApp,
            icon: const Icon(Icons.mail_outline_rounded, size: 20),
            label: const Text(
              "Open Email App",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Open Shopify Portal Direct Option
        SizedBox(
          width: double.infinity,
          height: 44,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brandDarkGreen,
            ),
            onPressed: _openShopifyWebPortal,
            icon: const Icon(Icons.open_in_browser_rounded, size: 18),
            label: const Text(
              "Sign In via Shopify Portal",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Resend & Change Email Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: widget.onBack ?? () => context.read<AuthBloc>().add(LogoutEvent()),
              icon: const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
              label: const Text(
                "Change Email",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: _countdownSeconds == 0 ? _resendCode : null,
              child: Text(
                _countdownSeconds > 0
                    ? "Resend in ${_countdownSeconds}s"
                    : "Resend Code",
                style: TextStyle(
                  color: _countdownSeconds == 0 ? AppColors.brandDarkGreen : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  decoration: _countdownSeconds == 0 ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
