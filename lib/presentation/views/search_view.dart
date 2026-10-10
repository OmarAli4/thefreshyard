import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/smart_search_engine.dart';
import '../../domain/entities/product.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_state.dart';
import '../widgets/exact_match_product_card.dart';
import '../widgets/product_grid_shimmer.dart';

enum SortOption { defaultSort, priceLowToHigh, priceHighToLow, titleAZ }

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
  SortOption _currentSort = SortOption.defaultSort;

  final List<String> _trendingTags = const [
    'فراولة 🍓',
    'مانجو 🥭',
    'أفوكادو 🥑',
    'طماطم 🍅',
    'عنب 🍇',
    'عصير برتقال 🥤',
    'تفاح 🍎',
    'خضار عضوي 🌿',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _applySorting(List<Product> list) {
    final copy = List<Product>.from(list);
    switch (_currentSort) {
      case SortOption.priceLowToHigh:
        copy.sort((a, b) {
          final pA = a.variants.isNotEmpty ? a.variants.first.price : 0.0;
          final pB = b.variants.isNotEmpty ? b.variants.first.price : 0.0;
          return pA.compareTo(pB);
        });
        break;
      case SortOption.priceHighToLow:
        copy.sort((a, b) {
          final pA = a.variants.isNotEmpty ? a.variants.first.price : 0.0;
          final pB = b.variants.isNotEmpty ? b.variants.first.price : 0.0;
          return pB.compareTo(pA);
        });
        break;
      case SortOption.titleAZ:
        copy.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.defaultSort:
        break;
    }
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Header & Input Bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                    _searchCurrentPage = 1;
                  });
                },
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: "ابحث عن الفواكه، الخضار، المنتجات العضوية...",
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF64748B)),
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
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Trending Tags
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _trendingTags.map((tag) {
                    final cleanTag = tag.split(' ').first;
                    final isSelected = _searchQuery.toLowerCase() == cleanTag.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ActionChip(
                        label: Text(
                          tag,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF1E293B),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: isSelected ? const Color(0xFF10B981) : const Color(0xFFF1F5F9),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        onPressed: () {
                          _searchController.text = cleanTag;
                          setState(() {
                            _searchQuery = cleanTag;
                            _searchCurrentPage = 1;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Sort Options & Count Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'نتائج البحث عن المنتجات',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              PopupMenuButton<SortOption>(
                initialValue: _currentSort,
                onSelected: (option) => setState(() => _currentSort = option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sort_rounded, size: 16, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(
                        _currentSort == SortOption.priceLowToHigh
                            ? 'السعر: من الأقل'
                            : _currentSort == SortOption.priceHighToLow
                                ? 'السعر: من الأعلى'
                                : _currentSort == SortOption.titleAZ
                                    ? 'الاسم: أ-ي'
                                    : 'الترتيب الافتراضي',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F5132),
                        ),
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: SortOption.defaultSort, child: Text('الافتراضي')),
                  PopupMenuItem(value: SortOption.priceLowToHigh, child: Text('السعر: من الأقل للأعلى')),
                  PopupMenuItem(value: SortOption.priceHighToLow, child: Text('السعر: من الأعلى للأقل')),
                  PopupMenuItem(value: SortOption.titleAZ, child: Text('الترتيب الأبجدي')),
                ],
              ),
            ],
          ),
        ),

        // Search Results Grid
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoaded) {
                final filtered = _searchQuery.isEmpty
                    ? state.products
                    : SmartSearchEngine.search(
                        products: state.products,
                        query: _searchQuery,
                      );

                final sortedResults = _currentSort == SortOption.defaultSort
                    ? filtered
                    : _applySorting(filtered);

                if (sortedResults.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 54,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'لم نجد منتجات مطابقة لـ "$_searchQuery"',
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'جرب البحث عن فراولة، مانجو، أفوكادو أو عصائر طازجة',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final totalPages = (sortedResults.length / _itemsPerPage).ceil().clamp(1, 99);
                final safePage = _searchCurrentPage.clamp(1, totalPages);
                final startIndex = (safePage - 1) * _itemsPerPage;
                final endIndex = (startIndex + _itemsPerPage < sortedResults.length)
                    ? startIndex + _itemsPerPage
                    : sortedResults.length;

                final paginatedResults = (startIndex < sortedResults.length)
                    ? sortedResults.sublist(startIndex, endIndex)
                    : <Product>[];

                return Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.58,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: paginatedResults.length,
                        itemBuilder: (context, index) {
                          return ExactMatchProductCard(
                            product: paginatedResults[index],
                            delay: index * 30,
                            onGoToCart: widget.onGoToCart,
                            heroTag: 'search_item_${paginatedResults[index].id}',
                          );
                        },
                      ),
                    ),
                    if (totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_rounded,
                                    size: 16,
                                    color: Color(0xFF0F5132),
                                  ),
                                  onPressed: safePage > 1 ? () => setState(() => _searchCurrentPage--) : null,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    '$safePage / $totalPages',
                                    style: const TextStyle(
                                      color: Color(0xFF0F5132),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: Color(0xFF0F5132),
                                  ),
                                  onPressed: safePage < totalPages ? () => setState(() => _searchCurrentPage++) : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: ProductGridShimmer(),
              );
            },
          ),
        ),
      ],
    );
  }
}
