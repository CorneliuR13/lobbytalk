import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lobbytalk/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('App should start and show login screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify that the login screen is shown
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextFormField),
          findsNWidgets(2)); // Email and password fields
    });

    testWidgets('User can navigate to registration screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap on the register button
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Verify that the registration screen is shown
      expect(find.text('Register'), findsOneWidget);
      expect(find.byType(TextFormField),
          findsNWidgets(3)); // Name, email, and password fields
    });
  });
}
