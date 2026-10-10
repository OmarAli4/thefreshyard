import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/smart_search_engine.dart';
import '../../domain/entities/product.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';
import '../pages/category_products_page.dart';
import '../widgets/product_filter_bottom_sheet.dart';
import '../widgets/exact_match_product_card.dart';
import '../widgets/product_grid_shimmer.dart';
import '../widgets/home_promo_banner.dart';
import '../widgets/special_offers_section.dart';
import '../widgets/circular_category_section.dart';
import '../widgets/best_sellers_section.dart';

class HomeView extends StatefulWidget {
  final VoidCallback onGoToCart;

  const HomeView({
    super.key,
    required this.onGoToCart,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final String _selectedCategory = 'All';
  int _currentPage = 1;
  static const int _itemsPerPage = 12;
  ProductFilterState _filterState = const ProductFilterState();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<ProductBloc>().add(
      const FetchProductsEvent(),
    );
  }

  void _openFilterBottomSheet() {
    ProductFilterBottomSheet.show(
      context,
      currentState: _filterState,
      maxPriceLimit: 1200.0,
      onApply: (newState) {
        setState(() {
          _filterState = newState;
          _currentPage = 1;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      color: AppColors.brandDarkGreen,
      backgroundColor: AppColors.brandCream,
      onRefresh: _onRefresh,
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final productsList = (state is ProductLoaded) ? state.products : <Product>[];

          List<Product> productsToProcess = productsList;

          // 1. Smart Search Query Filter (Weighted Multi-Token + Arabic Normalization + Typo Tolerance)
          if (_searchQuery.isNotEmpty) {
            productsToProcess = SmartSearchEngine.search(
              products: productsToProcess,
              query: _searchQuery,
            );
          }

          // 2. Price Range Filter (Only when user explicitly sets a price filter)
          if (_filterState.isPriceFilterActive) {
            productsToProcess = productsToProcess.where((p) {
              final price = p.variants.isNotEmpty ? p.variants.first.price : 0.0;
              return price >= _filterState.priceRange.start && price <= _filterState.priceRange.end;
            }).toList();
          }

          // 3. In-Stock Filter
          if (_filterState.inStockOnly) {
            productsToProcess = productsToProcess.where((p) {
              return p.variants.isNotEmpty && p.variants.first.price > 0;
            }).toList();
          }

          // 4. Sort Options
          final filteredProducts = List<Product>.from(productsToProcess);
          switch (_filterState.sortOption) {
            case ProductSortOption.priceLowToHigh:
              filteredProducts.sort((a, b) {
                final pA = a.variants.isNotEmpty ? a.variants.first.price : 0.0;
                final pB = b.variants.isNotEmpty ? b.variants.first.price : 0.0;
                return pA.compareTo(pB);
              });
              break;
            case ProductSortOption.priceHighToLow:
              filteredProducts.sort((a, b) {
                final pA = a.variants.isNotEmpty ? a.variants.first.price : 0.0;
                final pB = b.variants.isNotEmpty ? b.variants.first.price : 0.0;
                return pB.compareTo(pA);
              });
              break;
            case ProductSortOption.titleAToZ:
              filteredProducts.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
              break;
            case ProductSortOption.titleZToA:
              filteredProducts.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
              break;
            case ProductSortOption.bestSelling:
              filteredProducts.sort((a, b) => (b.ratingCount ?? 0).compareTo(a.ratingCount ?? 0));
              break;
            case ProductSortOption.featured:
              break;
          }

          final totalPages = (filteredProducts.length / _itemsPerPage).ceil().clamp(1, 99);
          final safePage = _currentPage.clamp(1, totalPages);
          final startIndex = (safePage - 1) * _itemsPerPage;
          final endIndex = (startIndex + _itemsPerPage < filteredProducts.length)
              ? startIndex + _itemsPerPage
              : filteredProducts.length;

          final paginatedProducts = (startIndex < filteredProducts.length)
              ? filteredProducts.sublist(startIndex, endIndex)
              : <Product>[];

          return CustomScrollView(
            physics: const ClampingScrollPhysics(), // Fast, direct 1:1 mobile touch scrolling
            slivers: [
              // 1. Live Interactive Search Bar Above the Banner
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
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
                        _currentPage = 1;
                      });
                    },
                    style: const TextStyle(
                      color: AppColors.brandCream,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                    cursorColor: AppColors.brandGold,
                    decoration: InputDecoration(
                      hintText: 'Search fresh fruits, veggies, organics...',
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
                                  _currentPage = 1;
                                });
                              },
                            )
                          : GestureDetector(
                              onTap: _openFilterBottomSheet,
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: _filterState.hasActiveFilters
                                      ? AppColors.brandGold
                                      : AppColors.brandGold.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  color: _filterState.hasActiveFilters
                                      ? AppColors.brandDarkGreen
                                      : AppColors.brandGold,
                                  size: 13,
                                ),
                              ),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),

              // Show banner, special offers, categories, and best sellers when not searching
              if (_searchQuery.isEmpty) ...[
                // 2. Modern Promo Hero Banner
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 4.0, bottom: 2.0),
                    child: HomePromoBanner(),
                  ),
                ),

                // 3. Special Offers Section
                SliverToBoxAdapter(
                  child: SpecialOffersSection(
                    products: productsList,
                    onGoToCart: widget.onGoToCart,
                  ),
                ),

                // 4. Circular Luxury Categories (Tapping opens CategoryProductsPage)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: CircularCategorySection(
                      selectedCategory: _selectedCategory,
                      onSelectCategory: (title, handle) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryProductsPage(
                              categoryTitle: title,
                              collectionHandle: handle,
                              onGoToCart: widget.onGoToCart,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 5. Best Sellers Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: BestSellersSection(
                      fallbackProducts: productsList,
                      onGoToCart: widget.onGoToCart,
                    ),
                  ),
                ),
              ],

              // 6. Loading Shimmer
              if (state is ProductLoading || state is ProductInitial)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: ProductGridShimmer(),
                  ),
                ),

              // 7. Error State
              if (state is ProductError)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Icon(Icons.wifi_off, size: 40, color: AppColors.brandDarkGreen),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: const TextStyle(
                              color: AppColors.brandDarkGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 8. Search Results Header (Only shown when searching)
              if (_searchQuery.isNotEmpty && state is ProductLoaded && filteredProducts.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Search Results',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brandDarkGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.brandDarkGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.brandDarkGreen.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '${filteredProducts.length} Items',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brandDarkGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (totalPages > 1)
                          Text(
                            'Page $safePage of $totalPages',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.brandDarkGreen.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // 9. HIGH PERFORMANCE LAZY SLIVER GRID (Only shown when searching)
              if (_searchQuery.isNotEmpty && state is ProductLoaded && filteredProducts.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.53,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return RepaintBoundary(
                          child: ExactMatchProductCard(
                            product: paginatedProducts[index],
                            delay: 0,
                            onGoToCart: widget.onGoToCart,
                            heroTag: 'home_product_image_${paginatedProducts[index].id}',
                          ),
                        );
                      },
                      childCount: paginatedProducts.length,
                    ),
                  ),
                ),

              // 10. Empty Search State
              if (_searchQuery.isNotEmpty && state is ProductLoaded && filteredProducts.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 54,
                            color: AppColors.brandDarkGreen,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No harvest found matching "$_searchQuery"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.brandDarkGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 11. Pagination Controls (Only when searching)
              if (_searchQuery.isNotEmpty && state is ProductLoaded && totalPages > 1)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: AppColors.brandDarkGreen.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                size: 16,
                                color: AppColors.brandDarkGreen,
                              ),
                              onPressed: safePage > 1
                                  ? () => setState(() => _currentPage--)
                                  : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: Text(
                                'Page $safePage of $totalPages',
                                style: const TextStyle(
                                  color: AppColors.brandDarkGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.brandDarkGreen,
                              ),
                              onPressed: safePage < totalPages
                                  ? () => setState(() => _currentPage++)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        },
      ),
    );
  }
}
