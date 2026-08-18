import '../../domain/entities/product.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepository implements IProductRepository {
  final IProductRemoteDataSource _remoteDataSource;

  ProductRepository({IProductRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ProductRemoteDataSourceImpl();

  @override
  Stream<List<Product>> getProducts({
    int limit = 500,
    String? collectionHandle,
  }) async* {
    // 1. Yield Cached Data First (if any)
    try {
      final cachedModels = await _remoteDataSource.getCachedProducts(collectionHandle: collectionHandle);
      if (cachedModels.isNotEmpty) {
        yield cachedModels.map((m) => m.toDomain()).toList();
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
      }
    } catch (e) {
      // If network fails and we didn't yield cache, yield fallback data
    }
  }
}
