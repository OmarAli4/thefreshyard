import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:the_fresh_yard/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Take Play Store Screenshots', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Wait for network images
    await Future.delayed(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    print('[[SCREENSHOT_1_READY]]');
    await Future.delayed(const Duration(seconds: 3));

    // Tap first product to go to details page
    final firstProduct = find.byType(Card).first;
    if (firstProduct.evaluate().isNotEmpty) {
      await tester.tap(firstProduct);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      print('[[SCREENSHOT_2_READY]]');
      await Future.delayed(const Duration(seconds: 3));

      // Tap back button
      final backButton = find.byTooltip('Back');
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    }

    // Tap Cart Tab (assuming index 1 or specific icon)
    final cartIcon = find.byIcon(Icons.shopping_cart);
    if (cartIcon.evaluate().isNotEmpty) {
      await tester.tap(cartIcon.first);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      print('[[SCREENSHOT_3_READY]]');
      await Future.delayed(const Duration(seconds: 3));
    }

    // Tap Profile Tab
    final profileIcon = find.byIcon(Icons.person);
    if (profileIcon.evaluate().isNotEmpty) {
      await tester.tap(profileIcon.first);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      print('[[SCREENSHOT_4_READY]]');
      await Future.delayed(const Duration(seconds: 3));
    }

    print('ALL DONE');
  });
}
