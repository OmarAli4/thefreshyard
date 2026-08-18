import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';
import '../widgets/category_chip.dart';
import '../widgets/exact_match_product_card.dart';
import '../widgets/product_grid_shimmer.dart';
import '../../data/datasources/collection_remote_data_source.dart';

class HomeView extends StatefulWidget {
  final VoidCallback onGoToCart;

  const HomeView({
    super.key,
    required this.onGoToCart,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _selectedCategory = 'All';
  int _currentPage = 1;
  static const int _itemsPerPage = 12;

  final Map<String, int> _categoryCounts = {};

  List<Map<String, String>> _categories = [
    {'title': 'All', 'handle': 'all'},
  ];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    // Import needed dynamically or at top. We will ensure the import is present later if needed.
    // Actually we should add the import at the top using multi_replace. Let's do that in a sec.
    final dataSource = CollectionRemoteDataSourceImpl();
    final collections = await dataSource.getCollections(limit: 20);
    
    if (mounted) {
      setState(() {
        _categories = [
          {'title': 'All', 'handle': 'all'},
          ...collections,
        ];
        _isLoadingCategories = false;
      });
    }
  }

  List<Map<String, String>> get _sortedCategories {
    if (_categories.isEmpty) return [];
    final copy = List<Map<String, String>>.from(_categories);
    final allCat = copy.firstWhere((c) => c['handle'] == 'all', orElse: () => {'title': 'All', 'handle': 'all'});
    copy.removeWhere((c) => c['handle'] == 'all');
    copy.sort(
      (a, b) => a['title']!.toLowerCase().compareTo(b['title']!.toLowerCase()),
    );
    return [allCat, ...copy];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('home'),
      children: [
        SizedBox(
          height: 50,
          child: _isLoadingCategories
              ? const Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.brandDarkGreen,
                    ),
                  ),
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: _sortedCategories
                      .map(
                        (cat) => CategoryChip(
                          category: cat,
                          isSelected: _selectedCategory == cat['title'],
                          count: _categoryCounts[cat['title']],
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat['title']!;
                              _currentPage = 1;
                            });
                            context.read<ProductBloc>().add(
                              FetchProductsEvent(collectionHandle: cat['handle']!),
                            );
                          },
                        ),
                      )
                      .toList(),
                ),
        ),
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, state) {
              if (state is ProductLoading || state is ProductInitial) {
                return const ProductGridShimmer();
              }
              if (state is ProductError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: AppColors.brandDarkGreen),
                  ),
                );
              }
              if (state is ProductLoaded) {
                // Update category product count for trace tracking
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _categoryCounts[_selectedCategory] != state.products.length) {
                    setState(() {
                      _categoryCounts[_selectedCategory] = state.products.length;
                    });
                  }
                });

                final filteredProducts = List<Product>.from(state.products)
                  ..sort(
                    (a, b) => a.title.toLowerCase().compareTo(
                      b.title.toLowerCase(),
                    ),
                  );

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 60,
                          color: AppColors.brandDarkGreen,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No products in $_selectedCategory category',
                          style: const TextStyle(
                            color: AppColors.brandDarkGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final totalPages = (filteredProducts.length / _itemsPerPage)
                    .ceil()
                    .clamp(1, 99);
                final safePage = _currentPage.clamp(1, totalPages);
                final startIndex = (safePage - 1) * _itemsPerPage;
                final endIndex =
                    (startIndex + _itemsPerPage < filteredProducts.length)
                    ? startIndex + _itemsPerPage
                    : filteredProducts.length;

                final paginatedProducts =
                    (startIndex < filteredProducts.length)
                    ? filteredProducts.sublist(startIndex, endIndex)
                    : <Product>[];

                return Column(
                  children: [
                    // Category Quantity Trace Header Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                _selectedCategory,
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brandDarkGreen,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                              'Showing ${paginatedProducts.length} of ${filteredProducts.length}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.brandDarkGreen.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 6.0,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.52,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: paginatedProducts.length,
                        itemBuilder: (context, index) {
                          return ExactMatchProductCard(
                            product: paginatedProducts[index],
                            delay: index * 50,
                            onGoToCart: widget.onGoToCart,
                            heroTag: 'home_product_image_${paginatedProducts[index].id}',
                          );
                        },
                      ),
                    ),
                    if (totalPages > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
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
                                horizontal: 12.0,
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
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
