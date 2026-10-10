import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color backgroundColor;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.backgroundColor = const Color(0xFFF1E9D7),
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: backgroundColor,
        child: const Center(
          child: Icon(
            Icons.local_florist_rounded,
            color: AppColors.brandDarkGreen,
            size: 28,
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        gaplessPlayback: true,
        filterQuality: FilterQuality.low, // Fast bilinear filtering for max FPS
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: backgroundColor,
            child: const Center(
              child: Icon(
                Icons.eco_rounded,
                color: AppColors.brandDarkGreen,
                size: 28,
              ),
            ),
          );
        },
      ),
    );
  }
}
