import 'package:flutter_test/flutter_test.dart';
import 'package:the_fresh_yard/domain/entities/product.dart';
import 'package:the_fresh_yard/domain/entities/product_variant.dart';
import 'package:the_fresh_yard/presentation/bloc/cart/cart_bloc.dart';
import 'package:the_fresh_yard/presentation/bloc/cart/cart_event.dart';

void main() {
  group('CartBloc Automated Regression Tests', () {
    const sampleProduct = Product(
      id: 'prod_1',
      title: 'Organic Strawberries',
      variants: [
        ProductVariant(
          id: 'var_1',
          title: '500g',
          price: 50.0,
          currencyCode: 'EGP',
          options: {},
        ),
      ],
    );

    const sampleVariant = ProductVariant(
      id: 'var_1',
      title: '500g',
      price: 50.0,
      currencyCode: 'EGP',
      options: {},
    );

    test('Initial state has empty items and null checkoutUrl', () {
      final bloc = CartBloc();
      expect(bloc.state.items, isEmpty);
      expect(bloc.state.checkoutUrl, isNull);
    });

    test('Removing item from cart resets checkoutUrl to null', () async {
      final bloc = CartBloc();

      // 1. Add item
      bloc.add(const AddToCartEvent(
        product: sampleProduct,
        variant: sampleVariant,
        quantity: 2,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.items.length, 1);

      // 2. Remove item
      bloc.add(const RemoveFromCartEvent('var_1'));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.items, isEmpty);
      expect(bloc.state.checkoutUrl, isNull);
    });

    test('Updating quantity resets checkoutUrl and avoids stale checkout', () async {
      final bloc = CartBloc();

      // 1. Add item
      bloc.add(const AddToCartEvent(
        product: sampleProduct,
        variant: sampleVariant,
        quantity: 1,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      // 2. Update quantity
      bloc.add(const UpdateQuantityEvent('var_1', 3));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.items.first.quantity, 3);
      expect(bloc.state.checkoutUrl, isNull);
    });

    test('ResetCheckoutStateEvent explicitly clears checkoutUrl', () async {
      final bloc = CartBloc();
      bloc.add(ResetCheckoutStateEvent());
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.checkoutUrl, isNull);
      expect(bloc.state.checkoutError, isNull);
      expect(bloc.state.checkoutNoticeMessage, isNull);
    });
  });
}
