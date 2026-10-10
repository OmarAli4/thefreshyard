import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TopPromoBanner extends StatelessWidget {
  final String message;

  const TopPromoBanner({
    super.key,
    this.message = 'FRESH ORGANIC HARVEST • DIRECT FROM OUR FARMS TO YOUR DOOR',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.brandGold,
      padding: const EdgeInsets.symmetric(vertical: 5.5),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'sans-serif',
          color: AppColors.brandDarkGreen,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
