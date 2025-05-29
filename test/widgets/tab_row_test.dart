import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/widgets/tab_row.dart';
import 'package:sizer/sizer.dart';

void main() {
  group('TabRow Widget Tests', () {
    testWidgets('TabRow displays a horizontal ListView with correct TabButtons', (WidgetTester tester) async {
      await tester.pumpWidget(
        Sizer( // Wrap with Sizer
          builder: (context, orientation, deviceType) {
            return const MaterialApp(
              home: Scaffold(body: TabRow()),
            );
          },
        ),
      );

      // Verify ListView is present and horizontal
      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);
      final ListView listView = tester.widget(listViewFinder);
      expect(listView.scrollDirection, Axis.horizontal);

      // Verify the TabButtons are present by their text
      expect(find.text('Filter'), findsOneWidget);
      expect(find.text('Sort'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);

      // Check that these texts are indeed within TabButtons widgets
      expect(find.widgetWithText(TabButtons, 'Filter'), findsOneWidget);
      expect(find.widgetWithText(TabButtons, 'Sort'), findsOneWidget);
      expect(find.widgetWithText(TabButtons, 'Category'), findsOneWidget);
    });
  });

  group('TabButtons Widget Tests', () {
    const String buttonText = 'Test Button';
    const primaryColor = Colors.purple;

    testWidgets('TabButtons displays OutlinedButton with correct text and style', (WidgetTester tester) async {
      await tester.pumpWidget(
        Sizer( // Wrap with Sizer
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              theme: ThemeData(primaryColor: primaryColor),
              home: const Scaffold(
                body: TabButtons(text: buttonText),
              ),
            );
          },
        ),
      );

      // Verify OutlinedButton is present
      final outlinedButtonFinder = find.byType(OutlinedButton);
      expect(outlinedButtonFinder, findsOneWidget);

      // Verify the text within the button
      final textFinder = find.text(buttonText);
      expect(textFinder, findsOneWidget);

      // Verify the button's child is the Text widget
      final OutlinedButton button = tester.widget(outlinedButtonFinder);
      expect(button.child, isA<Text>());
      final Text buttonTextWidget = button.child as Text;
      expect(buttonTextWidget.data, buttonText);

      // Verify text style (color from theme)
      expect(buttonTextWidget.style?.color, primaryColor);

      // Test onPressed (it's empty, but we can ensure it's callable)
      await tester.tap(outlinedButtonFinder);
      await tester.pump(); // Process the tap
      // No assertion needed if onPressed is empty, just that it doesn't crash.
    });
  });
}