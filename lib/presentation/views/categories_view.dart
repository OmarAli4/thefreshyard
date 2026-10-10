import 'package:flutter/material.dart';
import '../../core/services/dynamic_content_service.dart';
import '../../core/services/collection_cache_service.dart';
import '../../core/theme/app_colors.dart';
import '../pages/category_products_page.dart';

class CategoryDetailItem {
  final String title;
  final String subtitle;
  final String handle;
  final String assetPath;
  final String tag;

  const CategoryDetailItem({
    required this.title,
    required this.subtitle,
    required this.handle,
    required this.assetPath,
    required this.tag,
  });
}

class CategoriesView extends StatefulWidget {
  final VoidCallback onGoToCart;

  const CategoriesView({
    super.key,
    required this.onGoToCart,
  });

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildCardImage(String path) {
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

        final List<CategoryDetailItem> shopifyCollections = liveCollections
            .map((c) => CategoryDetailItem(
                  title: c.title,
                  subtitle: 'Explore fresh ${c.title.toLowerCase()} from our harvest',
                  handle: c.handle,
                  assetPath: c.imageUrl.isNotEmpty
                      ? c.imageUrl
                      : 'assets/images/banner_berry_wow.jpg',
                  tag: 'FRESH HARVEST',
                ))
            .toList();

        final filteredCategories = _searchQuery.isEmpty
            ? shopifyCollections
            : shopifyCollections.where((c) {
                final title = c.title.toLowerCase();
                final subtitle = c.subtitle.toLowerCase();
                final q = _searchQuery.toLowerCase();
                return title.contains(q) || subtitle.contains(q);
              }).toList();

        return Scaffold(
          backgroundColor: AppColors.brandDarkGreen,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // 1. Search Bar & Title Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'COLLECTIONS',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: AppColors.brandGold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Explore official curated collections',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.brandCream,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.brandGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.brandGold.withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '${shopifyCollections.length} COLLECTIONS',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brandGold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.brandDarkGreen,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: AppColors.brandGold.withValues(alpha: 0.45),
                            width: 1.1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim();
                            });
                          },
                          style: const TextStyle(
                            color: AppColors.brandCream,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                          cursorColor: AppColors.brandGold,
                          decoration: InputDecoration(
                            hintText: 'Search collections (Fruits, Matcha, Veggies...)',
                            hintStyle: TextStyle(
                              color: AppColors.brandCream.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.brandGold,
                              size: 21,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: AppColors.brandGold,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Department Cards List (Tapping opens CategoryProductsPage)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = filteredCategories[index];
                      return _buildLuxuryCategoryCard(category);
                    },
                    childCount: filteredCategories.length,
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildLuxuryCategoryCard(CategoryDetailItem category) {
    // Dynamic image lookup
    final imagePath = DynamicContentService.instance.getCategoryImage(
      category.handle,
      category.assetPath,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsPage(
              categoryTitle: category.title,
              collectionHandle: category.handle,
              onGoToCart: widget.onGoToCart,
            ),
          ),
        );
      },
      child: Container(
        height: 145,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.brandDarkGreen,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.brandGold.withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0E2313).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Dynamic or 8K Image Asset
              _buildCardImage(imagePath),

              // 2. Subtle Cinematic Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),

              // 3. Category Details & Call-To-Action
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tag Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.brandGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.brandGold.withValues(alpha: 0.6),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              category.tag,
                              style: const TextStyle(
                                color: AppColors.brandGold,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Category Title
                          Text(
                            category.title,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandGold,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Subtitle
                          Text(
                            category.subtitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.brandCream.withValues(alpha: 0.85),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Arrow Action Button
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.brandGold,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandGold.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.brandDarkGreen,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
