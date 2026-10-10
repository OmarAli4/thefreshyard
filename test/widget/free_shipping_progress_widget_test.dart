import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_fresh_yard/presentation/widgets/free_shipping_progress.dart';

void main() {
  testWidgets('FreeShippingProgress shows remaining amount when subtotal < threshold', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FreeShippingProgress(
            subtotal: 120.0,
            threshold: 300.0,
          ),
        ),
      ),
    );

    expect(find.text('Add LE 180 more for FREE Delivery!'), findsOneWidget);
    expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
  });

  testWidgets('FreeShippingProgress shows success message when subtotal >= threshold', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FreeShippingProgress(
            subtotal: 350.0,
            threshold: 300.0,
          ),
        ),
      ),
    );

    expect(find.text("🎉 You've unlocked FREE Express Shipping!"), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
