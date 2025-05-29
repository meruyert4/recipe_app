import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/widgets/profile_image.dart';

void main() {
  const String testImageUrl = 'http://example.com/profile.jpg';
  const double testHeight = 80.0;

  testWidgets('ProfileImage displays with correct decoration and image provider', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileImage(
            image: testImageUrl,
            height: testHeight,
          ),
        ),
      ),
    );

    // Find the Container
    final containerFinder = find.byType(Container);
    expect(containerFinder, findsOneWidget);

    final Container container = tester.widget(containerFinder);
    final BoxDecoration decoration = container.decoration as BoxDecoration;

    // Verify shape
    expect(decoration.shape, BoxShape.circle);
    expect(decoration.color, Colors.grey.shade200);

    // Verify DecorationImage
    expect(decoration.image, isA<DecorationImage>());
    final DecorationImage decorationImage = decoration.image!;
    expect(decorationImage.fit, BoxFit.fitHeight);

    // Verify CachedNetworkImageProvider
    expect(decorationImage.image, isA<CachedNetworkImageProvider>());
    final CachedNetworkImageProvider imageProvider = decorationImage.image as CachedNetworkImageProvider;
    expect(imageProvider.url, testImageUrl);

    // Verify boxShadow
    expect(decoration.boxShadow, isNotNull);
    expect(decoration.boxShadow!.length, 1);
    final BoxShadow shadow = decoration.boxShadow![0];
    expect(shadow.color, Colors.grey.withOpacity(0.5));
    expect(shadow.spreadRadius, 2);
    expect(shadow.blurRadius, 5);
    expect(shadow.offset, const Offset(0, 2));

    // Verify height of the container
    expect(container.constraints?.maxHeight, testHeight);
    expect(container.constraints?.minHeight, testHeight);
  });
}