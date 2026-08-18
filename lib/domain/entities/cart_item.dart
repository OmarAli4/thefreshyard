import 'package:equatable/equatable.dart';
import 'product.dart';
import 'product_variant.dart';

class CartItem extends Equatable {
  final Product product;
  final ProductVariant selectedVariant;
  final int quantity;

  const CartItem({
    required this.product,
    required this.selectedVariant,
    required this.quantity,
  });

  double get totalPrice => selectedVariant.price * quantity;

  CartItem copyWith({
    Product? product,
    ProductVariant? selectedVariant,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, selectedVariant, quantity];
}
