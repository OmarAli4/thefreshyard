import '../entities/product.dart';
import '../repositories/i_product_repository.dart';

class GetProductsUseCase {
  final IProductRepository repository;

  GetProductsUseCase(this.repository);

  Stream<List<Product>> call({int limit = 500, String? collectionHandle}) async* {
    final stream = repository.getProducts(limit: limit, collectionHandle: collectionHandle);
    
    await for (final products in stream) {
      final sortedProducts = List<Product>.from(products)
        ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      yield sortedProducts;
    }
  }
}
