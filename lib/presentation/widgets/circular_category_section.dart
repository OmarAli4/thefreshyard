import 'package:flutter/material.dart';
import '../../core/services/dynamic_content_service.dart';
import '../../core/services/collection_cache_service.dart';
import '../../core/theme/app_colors.dart';

class CategoryBubbleItem {
  final String title;
  final String handle;
  final String assetPath;

  const CategoryBubbleItem({
    required this.title,
    required this.handle,
    required this.assetPath,
  });
}

class CircularCategorySection extends StatelessWidget {
  final String selectedCategory;
  final Function(String title, String handle) onSelectCategory;

  const CircularCategorySection({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  Widget _buildBubbleImage(String path) {
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.brandDarkGreen,
        ),
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.brandDarkGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        DynamicContentService.instance,
        CollectionCacheService.instance,
      ]),
      builder: (context, _) {
        final liveCollections = CollectionCacheService.instance.collections;

        final List<CategoryBubbleItem> categories = liveCollections
            .where((c) =>
                c.handle.toLowerCase() != 'best-selling-products' &&
                c.handle.toLowerCase() != 'best-sellers' &&
                !c.title.toLowerCase().contains('best selling'))
            .map((c) => CategoryBubbleItem(
                  title: c.title.toUpperCase(),
                  handle: c.handle,
                  assetPath: c.imageUrl.isNotEmpty
                      ? c.imageUrl
                      : 'assets/images/banner_berry_wow.jpg',
                ))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.brandGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: AppColors.brandGold,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Explore Collections',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandGold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Full Multi-Row Grid Layout with Bigger Circular Bubbles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = selectedCategory.toUpperCase() == cat.title ||
                      (selectedCategory.toLowerCase() == 'all' && cat.handle == 'all') ||
                      (selectedCategory.toLowerCase() == cat.handle.toLowerCase());

                  // Get Dynamic Image from CMS
                  final imagePath = DynamicContentService.instance.getCategoryImage(
                    cat.handle,
                    cat.assetPath,
                  );

                  return GestureDetector(
                    onTap: () => onSelectCategory(cat.title, cat.handle),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        width: 102,
                        height: 102,
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFFFDF79),
                                    AppColors.brandGold,
                                    Color(0xFF8A6E24),
                                    AppColors.brandGold,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    AppColors.brandGold.withValues(alpha: 0.7),
                                    AppColors.brandDarkGreen,
                                    AppColors.brandGold.withValues(alpha: 0.35),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.brandGold.withValues(alpha: 0.5),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: ClipOval(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 1. Dynamic or 8K Bespoke Produce Photography Asset
                              _buildBubbleImage(imagePath),

                              // 2. Center/Bottom Dark Vignette for Text Readability
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: isSelected ? 0.45 : 0.65),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),

                              // 3. Complete Text Badge with 100% Un-truncated Multi-line Text
                              Positioned(
                                left: 4,
                                right: 4,
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.brandGold
                                        : Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFFFF6D6)
                                          : AppColors.brandGold.withValues(alpha: 0.85),
                                      width: 0.9,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.35),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    cat.title,
                                    textAlign: TextAlign.center,
                                    maxLines: 2, // Wraps to multiple lines cleanly without any truncation (...)
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.4,
                                      height: 1.1,
                                      color: isSelected
                                          ? AppColors.brandDarkGreen
                                          : AppColors.brandGold,
                                    ),
                                  ),
                                ),
                              ),

                              // 4. Top Glow Indicator when Selected
                              if (isSelected)
                                Positioned(
                                  top: 6,
                                  right: 0,
                                  left: 0,
                                  child: Center(
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.brandGold,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.brandGold,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}
