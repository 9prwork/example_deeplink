import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example_deeplink/main.dart';

void main() {
  testWidgets('shows home view with sample deep links', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Deep Link Demo'), findsOneWidget);
    expect(find.text('exampledeeplink://product/42'), findsOneWidget);
    expect(find.text('exampledeeplink://profile/9prwork'), findsOneWidget);
  });

  testWidgets('tapping the product button opens product detail', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.widgetWithText(FilledButton, 'Open product/42'));
    await tester.pumpAndSettle();

    expect(find.text('Product id: 42'), findsOneWidget);
  });
}
