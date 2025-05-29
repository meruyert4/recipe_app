import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/widgets/offline_banner.dart';

void main() {
  testWidgets('OfflineBanner displays correctly', (WidgetTester tester) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: OfflineBanner()));

    // Verify that the banner displays the correct text.
    expect(find.text('No internet connection'), findsOneWidget);

    // Verify the text style.
    final textWidget = tester.widget<Text>(find.text('No internet connection'));
    expect(textWidget.style?.color, Colors.white);
    expect(textWidget.style?.fontWeight, FontWeight.bold);

    // Verify the banner's background color.
    final containerWidget = tester.widget<Container>(find.byType(Container));
    expect(containerWidget.color, Colors.redAccent);
  });
}