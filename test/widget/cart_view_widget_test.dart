import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_fresh_yard/domain/entities/product.dart';
import 'package:the_fresh_yard/domain/entities/product_variant.dart';
import 'package:the_fresh_yard/presentation/bloc/cart/cart_bloc.dart';
import 'package:the_fresh_yard/presentation/bloc/cart/cart_event.dart';
import 'package:the_fresh_yard/presentation/views/cart_view.dart';

void main() {
  testWidgets('CartView shows empty state when cart has no items and triggers callback', (WidgetTester tester) async {
    final cartBloc = CartBloc();
    addTearDown(cartBloc.close);

    bool explored = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<CartBloc>.value(
            value: cartBloc,
            child: CartView(
              onExploreProducts: () {
                explored = true;
              },
            ),
          ),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    expect(find.byKey(const ValueKey('empty_cart')), findsOneWidget);
    expect(find.text('Your Cart is Empty'), findsOneWidget);

    final startShoppingBtn = find.text('Start Shopping');
    expect(startShoppingBtn, findsOneWidget);

    await tester.tap(startShoppingBtn);
    await tester.pump();

    expect(explored, isTrue);
  });

  testWidgets('CartView displays items when cart is not empty', (WidgetTester tester) async {
    final cartBloc = CartBloc();
    addTearDown(cartBloc.close);

    const variant = ProductVariant(
      id: 'var_test',
      title: '1kg Box',
      price: 60.0,
      currencyCode: 'EGP',
      options: {},
    );

    const product = Product(
      id: 'prod_test',
      title: 'Fresh Red Apples',
      variants: [variant],
    );

    cartBloc.add(const AddToCartEvent(
      product: product,
      variant: variant,
      quantity: 2,
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<CartBloc>.value(
            value: cartBloc,
            child: CartView(
              onExploreProducts: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('cart_content')), findsOneWidget);
    expect(find.text('Fresh Red Apples'), findsOneWidget);
  });
}
