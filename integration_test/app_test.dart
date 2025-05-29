import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recipe_app/main.dart' as app;
import 'package:recipe_app/screens/auth/login_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  setUp(() async {
    await FirebaseAuth.instance.signOut().catchError((e) {
      print('Error during pre-test signOut in setUp: $e. This might be okay if no user was logged in.');
    });
  });

  testWidgets("App launches, shows loading indicator, then navigates to LoginScreen", (WidgetTester tester) async {
    app.main();

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(StreamBuilder<User?>), findsOneWidget);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.byType(LoginScreen), findsOneWidget,
        reason: "LoginScreen was not found after auth settlement. "
                "Check if a user is unexpectedly logged in, "
                "if AuthGate navigation logic is correct, "
                "or if the screen takes longer to appear. "
                "Current user: ${FirebaseAuth.instance.currentUser?.uid ?? 'none'}.");
  });
}