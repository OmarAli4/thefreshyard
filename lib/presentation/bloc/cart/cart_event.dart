import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_variant.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCartEvent extends CartEvent {
  final Product product;
  final ProductVariant variant;
  final int quantity;

  const AddToCartEvent({
    required this.product,
    required this.variant,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [product, variant, quantity];
}

class RemoveFromCartEvent extends CartEvent {
  final String variantId;

  const RemoveFromCartEvent(this.variantId);

  @override
  List<Object?> get props => [variantId];
}

class UpdateQuantityEvent extends CartEvent {
  final String variantId;
  final int newQuantity;

  const UpdateQuantityEvent(this.variantId, this.newQuantity);

  @override
  List<Object?> get props => [variantId, newQuantity];
}

class ClearCartEvent extends CartEvent {}

class CreateCheckoutSessionEvent extends CartEvent {
  final String? customerAccessToken;

  const CreateCheckoutSessionEvent({this.customerAccessToken});

  @override
  List<Object?> get props => [customerAccessToken];
}

class ResetCheckoutStateEvent extends CartEvent {}
