import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_fresh_yard/domain/entities/cart_item.dart';
import 'package:the_fresh_yard/domain/entities/product.dart';
import 'package:the_fresh_yard/domain/entities/product_variant.dart';
import 'package:the_fresh_yard/presentation/bloc/cart/cart_bloc.dart';
import 'package:the_fresh_yard/presentation/widgets/cart_item_tile.dart';

void main() {
  testWidgets('CartItemTile displays product info and quantity', (WidgetTester tester) async {
    final cartBloc = CartBloc();
    addTearDown(cartBloc.close);

    const variant = ProductVariant(
      id: 'var_1',
      title: '1kg Box',
      price: 55.0,
      currencyCode: 'EGP',
      options: {},
    );

    const product = Product(
      id: 'prod_1',
      title: 'Organic Strawberries',
      variants: [variant],
    );

    const item = CartItem(
      product: product,
      selectedVariant: variant,
      quantity: 2,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<CartBloc>.value(
            value: cartBloc,
            child: const CartItemTile(item: item),
          ),
        ),
      ),
    );

    expect(find.text('Organic Strawberries'), findsOneWidget);
    expect(find.text('1kg Box'), findsOneWidget);
    expect(find.text('LE 110'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });
}
