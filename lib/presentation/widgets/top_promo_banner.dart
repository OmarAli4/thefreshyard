import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TopPromoBanner extends StatelessWidget {
  const TopPromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.brandGold,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: const Text(
        'SIGN UP FOR 10% OFF ON FIRST ORDER',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Georgia',
          color: AppColors.brandDarkGreen,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
