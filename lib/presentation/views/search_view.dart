import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_state.dart';
import '../widgets/exact_match_product_card.dart';
import '../widgets/product_grid_shimmer.dart';

class SearchView extends StatefulWidget {
  final VoidCallback onGoToCart;

  const SearchView({
    super.key,
    required this.onGoToCart,
  });

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _searchCurrentPage = 1;
  static const int _itemsPerPage = 12;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Live Search",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.brandDarkGreen,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
                _searchCurrentPage = 1;
              });
            },
            style: const TextStyle(
              color: AppColors.brandDarkGreen,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: "Search fruits, vegetables, matcha, juices...",
              hintStyle: TextStyle(
                color: AppColors.brandDarkGreen.withValues(alpha: 0.5),
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.brandDarkGreen),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.brandDarkGreen),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _searchCurrentPage = 1;
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_searchQuery.isEmpty) ...[
            const Text(
              "Trending Searches",
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children:
                    [
                          'Mango',
                          'Strawberry',
                          'Avocado',
                          'Kiwi',
                          'Dragon Fruit',
                          'Matcha',
                          'Tomato',
                          'Garlic',
                        ]
                        .map(
                          (term) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              label: Text(
                                term,
                                style: const TextStyle(
                                  color: AppColors.brandDarkGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: AppColors.brandCream,
                              side: const BorderSide(color: AppColors.brandGold),
                              onPressed: () {
                                _searchController.text = term;
                                setState(() {
                                  _searchQuery = term;
                                  _searchCurrentPage = 1;
                                });
                              },
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoaded) {
                  final results = _searchQuery.isEmpty
                      ? state.products
                      : state.products.where((p) {
                          final title = p.title.toLowerCase();
                          final desc = (p.description ?? '').toLowerCase();
                          final query = _searchQuery.toLowerCase();
                          return title.contains(query) || desc.contains(query);
                        }).toList();

                  if (results.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 60,
                            color: AppColors.brandDarkGreen,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No products found for "$_searchQuery"',
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

                  final totalPages = (results.length / _itemsPerPage)
                      .ceil()
                      .clamp(1, 99);
                  final safePage = _searchCurrentPage.clamp(1, totalPages);
                  final startIndex = (safePage - 1) * _itemsPerPage;
                  final endIndex = (startIndex + _itemsPerPage < results.length)
                      ? startIndex + _itemsPerPage
                      : results.length;

                  final paginatedResults = (startIndex < results.length)
                      ? results.sublist(startIndex, endIndex)
                      : <Product>[];

                  return Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.52,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: paginatedResults.length,
                          itemBuilder: (context, index) {
                            return ExactMatchProductCard(
                              product: paginatedResults[index],
                              delay: index * 30,
                              onGoToCart: widget.onGoToCart,
                              heroTag: 'search_product_image_${paginatedResults[index].id}',
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
                                    ? () => setState(() => _searchCurrentPage--)
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
                                    ? () => setState(() => _searchCurrentPage++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }
                return const ProductGridShimmer();
              },
            ),
          ),
        ],
      ),
    );
  }
}
