import '../entities/product.dart';

abstract class IProductRepository {
  Stream<List<Product>> getProducts({int limit = 20, String? collectionHandle});
  Future<List<Product>> getBestSellingProducts({int limit = 10});
  Future<({List<Product> products, bool hasNextPage, String? endCursor})> getProductsPaginated({
    int limit = 20,
    String? cursor,
    String? query,
  });
}
