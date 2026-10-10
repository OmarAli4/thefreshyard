import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/smart_search_engine.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_state.dart';
import '../widgets/exact_match_product_card.dart';
import '../widgets/product_filter_bottom_sheet.dart';
import '../widgets/product_grid_shimmer.dart';

class CategoryProductsPage extends StatefulWidget {
  final String categoryTitle;
  final String collectionHandle;
  final VoidCallback onGoToCart;

  const CategoryProductsPage({
    super.key,
    required this.categoryTitle,
    required this.collectionHandle,
    required this.onGoToCart,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Product> _allProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 12;
  ProductFilterState _filterState = const ProductFilterState();

  StreamSubscription<List<Product>>? _subscription;

  @override
  void initState() {
    super.initState();
    _fetchCategoryProducts();
  }

  void _fetchCategoryProducts() async {
    final getProductsUseCase = context.read<GetProductsUseCase>();

    setState(() {
      _isLoading = true;
    });

    if (widget.collectionHandle.toLowerCase() == 'best-selling-products' ||
        widget.collectionHandle.toLowerCase() == 'best-sellers') {
      try {
        final dataSource = ProductRemoteDataSourceImpl();
        final models = await dataSource.getBestSellingProducts(limit: 50);
        if (mounted && models.isNotEmpty) {
          setState(() {
            _allProducts = models.map((m) => m.toDomain()).toList();
            _isLoading = false;
          });
          return;
        }
      } catch (_) {}
    }

    _subscription?.cancel();

    _subscription = getProductsUseCase(
      collectionHandle: widget.collectionHandle == 'all' ? null : widget.collectionHandle,
    ).listen((products) {
      if (mounted) {
        setState(() {
          _allProducts = products;
          _isLoading = false;
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
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
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _changePage(int page, int totalPages) {
    if (page >= 1 && page <= totalPages) {
      setState(() {
        _currentPage = page;
      });
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Product> productsToProcess = _allProducts;

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

    // 5. Pagination Calculations
    final totalPages = (filteredProducts.length / _itemsPerPage).ceil().clamp(1, 99);
    final safePage = _currentPage.clamp(1, totalPages);
    final startIndex = (safePage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage < filteredProducts.length)
        ? startIndex + _itemsPerPage
        : filteredProducts.length;

    final paginatedProducts = (startIndex < filteredProducts.length)
        ? filteredProducts.sublist(startIndex, endIndex)
        : <Product>[];

    return Scaffold(
      backgroundColor: AppColors.brandDarkGreen,
      appBar: AppBar(
        backgroundColor: AppColors.brandDarkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.brandGold,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.categoryTitle.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: AppColors.brandGold,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              return Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onGoToCart();
                  },
                  child: Badge(
                    isLabelVisible: cartState.totalItemCount > 0,
                    label: Text(
                      '${cartState.totalItemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.redAccent,
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.brandGold,
                      size: 24,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.brandGold.withValues(alpha: 0.25),
            height: 1.0,
          ),
        ),
      ),
      body: Container(
        color: AppColors.brandDarkGreen,
        child: RefreshIndicator(
          color: AppColors.brandDarkGreen,
          backgroundColor: AppColors.brandCream,
          onRefresh: () async {
            _fetchCategoryProducts();
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              // 1. Search & Item Count Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      // Search TextField
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
                            hintText: 'Search within ${widget.categoryTitle}...',
                            hintStyle: TextStyle(
                              color: AppColors.brandCream.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.brandGold,
                              size: 20,
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
                              vertical: 11,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Row with Count & Pages
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.brandGold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.brandGold.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  '${filteredProducts.length} Products Found',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.brandGold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (totalPages > 1)
                            Text(
                              'Page $safePage of $totalPages',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.brandGold.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Loading State
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: ProductGridShimmer(),
                  ),
                ),

              // 3. Empty State
              if (!_isLoading && filteredProducts.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.category_outlined,
                            size: 54,
                            color: AppColors.brandGold,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No products found matching "$_searchQuery"'
                                : 'No products available in ${widget.categoryTitle}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.brandGold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 4. Products Grid (1:1 Exact Square Match)
              if (!_isLoading && filteredProducts.isNotEmpty)
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
                            heroTag: 'cat_page_prod_${paginatedProducts[index].id}',
                          ),
                        );
                      },
                      childCount: paginatedProducts.length,
                    ),
                  ),
                ),

              // 5. Pagination Controls
              if (!_isLoading && totalPages > 1)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandDarkGreen,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: AppColors.brandGold.withValues(alpha: 0.5),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                size: 16,
                                color: AppColors.brandGold,
                              ),
                              onPressed: safePage > 1
                                  ? () => _changePage(safePage - 1, totalPages)
                                  : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Text(
                                'Page $safePage of $totalPages',
                                style: const TextStyle(
                                  color: AppColors.brandGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.brandGold,
                              ),
                              onPressed: safePage < totalPages
                                  ? () => _changePage(safePage + 1, totalPages)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
