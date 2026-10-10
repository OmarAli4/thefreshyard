import 'package:flutter_test/flutter_test.dart';
import 'package:the_fresh_yard/domain/entities/cart_item.dart';
import 'package:the_fresh_yard/domain/entities/product.dart';
import 'package:the_fresh_yard/domain/entities/product_variant.dart';
import 'package:the_fresh_yard/presentation/bloc/cart/cart_bloc.dart';
import 'package:the_fresh_yard/presentation/bloc/cart/cart_event.dart';

void main() {
  group('Cart Subtotal & Quantity Calculation Tests', () {
    const variantA = ProductVariant(
      id: 'var_a',
      title: '1kg',
      price: 45.50,
      currencyCode: 'EGP',
      options: {},
    );

    const productA = Product(
      id: 'prod_a',
      title: 'Organic Apple',
      variants: [variantA],
    );

    const variantB = ProductVariant(
      id: 'var_b',
      title: '2kg Box',
      price: 110.25,
      currencyCode: 'EGP',
      options: {},
    );

    const productB = Product(
      id: 'prod_b',
      title: 'Fresh Mango',
      variants: [variantB],
    );

    test('Adding multiple distinct items computes correct subtotal and itemCount', () async {
      final cartBloc = CartBloc();

      // Add 2 of Product A (45.50 * 2 = 91.00)
      cartBloc.add(const AddToCartEvent(
        product: productA,
        variant: variantA,
        quantity: 2,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      // Add 1 of Product B (110.25)
      cartBloc.add(const AddToCartEvent(
        product: productB,
        variant: variantB,
        quantity: 1,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cartBloc.state.items.length, 2);
      expect(cartBloc.state.totalItemCount, 3);
      expect(cartBloc.state.subtotal, closeTo(201.25, 0.001));

      // Update quantity of Product A to 4 (45.50 * 4 = 182.00)
      // Total should now be 182.00 + 110.25 = 292.25
      cartBloc.add(const UpdateQuantityEvent('var_a', 4));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cartBloc.state.totalItemCount, 5);
      expect(cartBloc.state.subtotal, closeTo(292.25, 0.001));

      // Clear cart
      cartBloc.add(ClearCartEvent());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cartBloc.state.items, isEmpty);
      expect(cartBloc.state.totalItemCount, 0);
      expect(cartBloc.state.subtotal, 0.0);
    });

    test('CartItem domain entity correctly computes item totalPrice', () {
      final item = CartItem(
        product: productA,
        selectedVariant: variantA,
        quantity: 3,
      );

      expect(item.totalPrice, 136.50);
    });
  });
}
