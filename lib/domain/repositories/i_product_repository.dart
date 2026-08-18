import '../entities/product.dart';

abstract class IProductRepository {
  Stream<List<Product>> getProducts({int limit = 20, String? collectionHandle});
}
