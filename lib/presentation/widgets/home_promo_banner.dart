import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/dynamic_content_service.dart';
import '../../core/theme/app_colors.dart';

class HomePromoBanner extends StatefulWidget {
  const HomePromoBanner({super.key});

  @override
  State<HomePromoBanner> createState() => _HomePromoBannerState();
}

class _HomePromoBannerState extends State<HomePromoBanner> {
  final PageController _pageController = PageController(viewportFraction: 0.94);
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final banners = DynamicContentService.instance.banners;
      if (_pageController.hasClients && banners.isNotEmpty) {
        final nextIndex = (_currentIndex + 1) % banners.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildBannerImage(String path) {
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.brandDarkGreen,
          child: const Center(
            child: Icon(
              Icons.eco,
              color: AppColors.brandGold,
              size: 40,
            ),
          ),
        ),
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.brandDarkGreen,
        child: const Center(
          child: Icon(
            Icons.eco,
            color: AppColors.brandGold,
            size: 40,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DynamicContentService.instance,
      builder: (context, _) {
        final banners = DynamicContentService.instance.banners;
        if (banners.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            SizedBox(
              height: 195,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.brandDarkGreen,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.brandGold.withValues(alpha: 0.5),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0E2313).withValues(alpha: 0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                        BoxShadow(
                          color: AppColors.brandGold.withValues(alpha: 0.1),
                          blurRadius: 10,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _buildBannerImage(banner.imagePath),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentIndex == index ? 22 : 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? AppColors.brandGold
                        : AppColors.brandGold.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
