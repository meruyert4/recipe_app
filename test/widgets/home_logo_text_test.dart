import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/widgets/rich_text.dart';
import 'package:sizer/sizer.dart';

void main() {
  testWidgets('HomeLogoText displays correctly with theme colors', (WidgetTester tester) async {
    const primaryColor = Colors.blue;
    const defaultTextColor = Colors.black;

    await tester.pumpWidget(
      Sizer( // Wrap with Sizer
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            theme: ThemeData(
              primaryColor: primaryColor,
              textTheme: const TextTheme(
                displayLarge: TextStyle(color: defaultTextColor),
              ),
            ),
            home: const Scaffold(body: HomeLogoText()),
          );
        },
      ),
    );

    // Find the RichText widget
    final RichText richTextWidget = tester.widget(find.byType(RichText));
    final TextSpan textSpan = richTextWidget.text as TextSpan;

    // Verify "Fairy" part
    final fairySpan = textSpan.children![0] as TextSpan;
    expect(fairySpan.text, 'Fairy');
    expect(fairySpan.style?.color, defaultTextColor);
    expect(fairySpan.style?.fontWeight, FontWeight.w600);

    // Verify "Fridge" part
    final fridgeSpan = textSpan.children![1] as TextSpan;
    expect(fridgeSpan.text, 'Fridge');
    expect(fridgeSpan.style?.color, primaryColor);
    expect(fridgeSpan.style?.fontWeight, FontWeight.w600);

    // Verify that the RichText widget's plain text contains "Fairy" and "Fridge"
    final plainText = richTextWidget.text.toPlainText();
    expect(plainText, contains('Fairy'));
    expect(plainText, contains('Fridge'));
    // You can also check the full string if the order is fixed:
    expect(plainText, 'FairyFridge');
  });
}