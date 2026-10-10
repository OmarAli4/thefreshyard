import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepository implements IProductRepository {
  final IProductRemoteDataSource _remoteDataSource;

  ProductRepository({IProductRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ProductRemoteDataSourceImpl();

  @override
  Stream<List<Product>> getProducts({
    int limit = 100,
    String? collectionHandle,
  }) async* {
    bool hasEmitted = false;

    // 1. Yield Cached Data First (0ms instant response)
    try {
      final cachedModels = await _remoteDataSource.getCachedProducts(collectionHandle: collectionHandle);
      if (cachedModels.isNotEmpty) {
        yield cachedModels.map((m) => m.toDomain()).toList();
        hasEmitted = true;
      }
    } catch (e) {
      // Ignore cache errors
    }

    // 2. Fetch Fresh Data from Remote
    try {
      final models = await _remoteDataSource.getProducts(
        limit: limit,
        collectionHandle: collectionHandle,
      );

      if (models.isNotEmpty) {
        yield models.map((m) => m.toDomain()).toList();
        hasEmitted = true;
      }
    } catch (e) {
      // Network failed
    }

    // 3. Fallback if network and cache both fail (Prevents hanging / loading forever)
    if (!hasEmitted) {
      yield getFallbackProducts();
    }
  }

  @override
  Future<List<Product>> getBestSellingProducts({int limit = 10}) async {
    try {
      final models = await _remoteDataSource.getBestSellingProducts(limit: limit);
      return models.map((m) => m.toDomain()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<({List<Product> products, bool hasNextPage, String? endCursor})> getProductsPaginated({
    int limit = 20,
    String? cursor,
    String? query,
  }) async {
    try {
      final result = await _remoteDataSource.getProductsPaginated(
        limit: limit,
        cursor: cursor,
        query: query,
      );
      
      return (
        products: result.products.map((m) => m.toDomain()).toList(),
        hasNextPage: result.hasNextPage,
        endCursor: result.endCursor,
      );
    } catch (e) {
      return (products: <Product>[], hasNextPage: false, endCursor: null);
    }
  }

  static List<Product> getFallbackProducts() {
    return const [
      Product(
        id: 'fallback_1',
        title: 'Fresh Strawberries (500g)',
        description: 'Sweet, juicy, freshly picked organic Egyptian strawberries.',
        imageUrl: 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=500&auto=format&fit=crop&q=60',
        variants: [
          ProductVariant(
            id: 'fallback_var_1',
            title: '500g Punnet',
            price: 85.0,
            currencyCode: 'EGP',
            options: {'Weight': '500g'},
          ),
        ],
      ),
      Product(
        id: 'fallback_2',
        title: 'Premium Hass Avocados (1 Kg)',
        description: 'Creamy, nutrient-rich Haas avocados hand-selected for optimal ripeness.',
        imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=500&auto=format&fit=crop&q=60',
        variants: [
          ProductVariant(
            id: 'fallback_var_2',
            title: '1 Kg',
            price: 120.0,
            currencyCode: 'EGP',
            options: {'Weight': '1 Kg'},
          ),
        ],
      ),
      Product(
        id: 'fallback_3',
        title: 'Egyptian Sweet Mangoes (1 Kg)',
        description: 'Famous Egyptian seasonal mangoes with rich aroma and delightful sweetness.',
        imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=500&auto=format&fit=crop&q=60',
        variants: [
          ProductVariant(
            id: 'fallback_var_3',
            title: '1 Kg',
            price: 65.0,
            currencyCode: 'EGP',
            options: {'Weight': '1 Kg'},
          ),
        ],
      ),
      Product(
        id: 'fallback_4',
        title: 'Seedless Green Grapes (500g)',
        description: 'Crisp, refreshing seedless table grapes from our sunny orchards.',
        imageUrl: 'https://images.unsplash.com/photo-1596363505729-4190a9506133?w=500&auto=format&fit=crop&q=60',
        variants: [
          ProductVariant(
            id: 'fallback_var_4',
            title: '500g',
            price: 55.0,
            currencyCode: 'EGP',
            options: {'Weight': '500g'},
          ),
        ],
      ),
      Product(
        id: 'fallback_5',
        title: 'Organic Cherry Tomatoes (250g)',
        description: 'Vine-ripened, naturally sweet cherry tomatoes perfect for fresh salads.',
        imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=60',
        variants: [
          ProductVariant(
            id: 'fallback_var_5',
            title: '250g',
            price: 40.0,
            currencyCode: 'EGP',
            options: {'Weight': '250g'},
          ),
        ],
      ),
      Product(
        id: 'fallback_6',
        title: 'Cold-Pressed Orange Juice (1L)',
        description: '100% pure fresh Valencia oranges, cold-pressed with no added sugar.',
        imageUrl: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=500&auto=format&fit=crop&q=60',
        variants: [
          ProductVariant(
            id: 'fallback_var_6',
            title: '1 Liter',
            price: 70.0,
            currencyCode: 'EGP',
            options: {'Size': '1L'},
          ),
        ],
      ),
    ];
  }
}
