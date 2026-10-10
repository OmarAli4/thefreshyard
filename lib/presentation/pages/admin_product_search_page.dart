import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';
import '../../data/repositories/product_repository.dart';

class AdminProductSearchPage extends StatefulWidget {
  final List<Product> initialProducts;

  const AdminProductSearchPage({super.key, required this.initialProducts});

  @override
  State<AdminProductSearchPage> createState() => _AdminProductSearchPageState();
}

class _AdminProductSearchPageState extends State<AdminProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  
  bool _isLoading = false;
  bool _hasNextPage = true;
  String? _endCursor;
  
  final _repository = ProductRepository();

  @override
  void initState() {
    super.initState();
    _allProducts = widget.initialProducts.toList();
    _filteredProducts = _allProducts;
    
    _scrollController.addListener(_onScroll);
    
    // Automatically load the first real page from the API to override/append to the initial fallback products.
    _loadMoreProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _loadMoreProducts() async {
    if (_isLoading || !_hasNextPage) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final result = await _repository.getProductsPaginated(
      limit: 20,
      cursor: _endCursor,
    );
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        
        // Remove fallback initial products once we get real ones from the API
        if (_endCursor == null && result.products.isNotEmpty) {
           _allProducts.clear();
        }
        
        // Avoid adding duplicates
        for (var newProduct in result.products) {
          if (!_allProducts.any((p) => p.id == newProduct.id)) {
            _allProducts.add(newProduct);
          }
        }
        
        _hasNextPage = result.hasNextPage;
        _endCursor = result.endCursor;
        
        _filterProducts(_searchController.text);
      });
    }
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredProducts = _allProducts.toList());
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        return p.title.toLowerCase().contains(lowerQuery) ||
            (p.description?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brandDarkGreen),
        title: TextField(
          controller: _searchController,
          onChanged: _filterProducts,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          style: const TextStyle(color: AppColors.brandDarkGreen, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _searchController.clear();
                _filterProducts('');
              },
            ),
        ],
      ),
      body: _filteredProducts.isEmpty && !_isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No products found.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _filteredProducts.length + (_isLoading ? 1 : 0),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == _filteredProducts.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandDarkGreen),
                      ),
                    ),
                  );
                }
              
                final product = _filteredProducts[index];
                final price = product.variants.isNotEmpty ? product.variants.first.price : 0.0;
                
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  title: Text(
                    product.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandDarkGreen),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'LE ${price.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.brandGold, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context, product);
                  },
                );
              },
            ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
