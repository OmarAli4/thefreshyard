import '../../data/datasources/checkout_remote_data_source.dart';
import '../entities/cart_item.dart';

class CreateCheckoutUseCase {
  final ICheckoutRemoteDataSource repository;

  CreateCheckoutUseCase({required this.repository});

  Future<CheckoutResult> call({
    required List<CartItem> items,
    String? customerAccessToken,
  }) async {
    return await repository.createCheckout(
      items: items,
      customerAccessToken: customerAccessToken,
    );
  }
}
