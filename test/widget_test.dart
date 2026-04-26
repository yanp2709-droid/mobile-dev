import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:first_application_Yan/main.dart';
import 'package:first_application_Yan/screens/login_page.dart';

void main() {
  testWidgets('App shows generator and can save a favorite', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(bootstrapMode: AppBootstrapMode.demo));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Like'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Like'));
    await tester.pump();

    await tester.tap(find.text('Favorites').first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('Login page opens the register screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
  });
}
