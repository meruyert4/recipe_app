import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recipe_app/screens/forum_screen.dart';
import 'mocks/setup_firebase_mocks.dart';

void main() {
  setUpAll(() async {
    FakeFirebaseCore.registerWith();
    await Firebase.initializeApp();
  });

  testWidgets('ForumScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ForumScreen(),
      ),
    );

    expect(find.text('Community Forum'), findsOneWidget); 
  });
}
