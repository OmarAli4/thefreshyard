import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final bool isCheckoutLoading;
  final String? checkoutUrl;
  final String? checkoutError;
  final String? checkoutNoticeMessage;

  const CartState({
    this.items = const [],
    this.isCheckoutLoading = false,
    this.checkoutUrl,
    this.checkoutError,
    this.checkoutNoticeMessage,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  String get currencyCode => items.isNotEmpty ? items.first.selectedVariant.currencyCode : 'LE';

  CartState copyWith({
    List<CartItem>? items,
    bool? isCheckoutLoading,
    String? checkoutUrl,
    String? checkoutError,
    String? checkoutNoticeMessage,
    bool clearCheckoutUrl = false,
    bool clearCheckoutError = false,
    bool clearCheckoutNotice = false,
  }) {
    return CartState(
      items: items ?? this.items,
      isCheckoutLoading: isCheckoutLoading ?? this.isCheckoutLoading,
      checkoutUrl: clearCheckoutUrl ? null : (checkoutUrl ?? this.checkoutUrl),
      checkoutError: clearCheckoutError ? null : (checkoutError ?? this.checkoutError),
      checkoutNoticeMessage: clearCheckoutNotice ? null : (checkoutNoticeMessage ?? this.checkoutNoticeMessage),
    );
  }

  @override
  List<Object?> get props => [
        items,
        isCheckoutLoading,
        checkoutUrl,
        checkoutError,
        checkoutNoticeMessage,
      ];
}
