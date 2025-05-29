import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/models/icon.dart';

void main() {
  group('IconModel Tests', () {
    test('IconModel object should be created with correct properties', () {
      const iconModel = IconModel(
        icon: 'assets/icons/test_icon.svg',
        text: 'Test Icon',
        category: 'TestCategory',
      );

      expect(iconModel.icon, 'assets/icons/test_icon.svg');
      expect(iconModel.text, 'Test Icon');
      expect(iconModel.category, 'TestCategory');
    });
  });
}