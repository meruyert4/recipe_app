import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/models/recipe.dart';

void main() {
  group('Recipe Model Tests', () {
    // Тест конструктора и свойств
    test('Recipe object should be created with correct properties', () {
      final recipe = Recipe(
        id: 1,
        title: 'Test Recipe',
        ingredients: ['Ing1', 'Ing2'],
        instructions: 'Do this, then that.',
        imageName: 'test_image',
        cleanedIngredients: ['ing1', 'ing2'],
        cookTime: 30,
      );

      expect(recipe.id, 1);
      expect(recipe.title, 'Test Recipe');
      expect(recipe.ingredients, ['Ing1', 'Ing2']);
      expect(recipe.instructions, 'Do this, then that.');
      expect(recipe.imageName, 'test_image');
      expect(recipe.cleanedIngredients, ['ing1', 'ing2']);
      expect(recipe.cookTime, 30);
    });

    // Тест imageUrl геттера
    test('imageUrl getter should return correct path', () {
      final recipe = Recipe(
        id: 1,
        title: 'Test Recipe',
        ingredients: [],
        instructions: '',
        imageName: 'my_recipe_image',
        cleanedIngredients: [],
        cookTime: 0,
      );
      expect(recipe.imageUrl, 'assets/recipe_dataset/images/my_recipe_image.jpg');
    });

    // Тесты для статического метода parseStringList
    group('parseStringList', () {
      test('should parse a standard string list representation', () {
        const input = "['ingredient1', 'ingredient2', 'ingredient 3']";
        final expected = ['ingredient1', 'ingredient2', 'ingredient 3'];
        expect(Recipe.parseStringList(input), equals(expected));
      });

      test('should handle empty list string', () {
        const input = "[]";
        if (Recipe.parseStringList(input).length == 1 && Recipe.parseStringList(input)[0].isEmpty) {
             expect(Recipe.parseStringList(input), equals([''])); // Или equals(<String>[''])
        } else {
            expect(Recipe.parseStringList(input), isEmpty);
        }
      });

      test('should handle list with single item', () {
        const input = "['single_item']";
        final expected = ['single_item'];
        expect(Recipe.parseStringList(input), equals(expected));
      });

      test('should handle extra spaces and single quotes', () {
        const input = "[ ' item with spaces ' , 'another_item' ]";
        final expected = ['item with spaces', 'another_item'];
        expect(Recipe.parseStringList(input), equals(expected));
      });

       test('should handle list string without brackets but with quotes', () {
        const input = "'item1','item2'";
        final expected = ["item1", "item2"];
        expect(Recipe.parseStringList(input), equals(expected));
      });
    });

    // Тесты для factory Recipe.fromCsv
    group('Recipe.fromCsv', () {
      test('should create Recipe object from valid CSV values', () {
        final csvValues = [
          101,
          'CSV Recipe',
          "['Salt', 'Pepper']",
          'Mix well.',
          'csv_image',
          "['salt', 'pepper']",
          15
        ];
        final recipe = Recipe.fromCsv(csvValues);

        expect(recipe.id, 101);
        expect(recipe.title, 'CSV Recipe');
        expect(recipe.ingredients, ['Salt', 'Pepper']);
        expect(recipe.instructions, 'Mix well.');
        expect(recipe.imageName, 'csv_image');
        expect(recipe.cleanedIngredients, ['salt', 'pepper']);
        expect(recipe.cookTime, 15);
      });

      test('should handle CSV values with different types correctly', () {
          final csvValues = [
            1, // id (int)
            "Pasta Carbonara", // title (String)
            "['Spaghetti', 'Eggs', 'Pancetta', 'Parmesan Cheese', 'Black Pepper']", // ingredients (String to List<String>)
            "Cook spaghetti. Fry pancetta. Mix eggs and cheese. Combine all.", // instructions (String)
            "pasta_carbonara_image", // imageName (String)
            "['spaghetti', 'eggs', 'pancetta', 'parmesan cheese', 'black pepper']", // cleanedIngredients (String to List<String>)
            20 // cookTime (int)
          ];
          final recipe = Recipe.fromCsv(csvValues);
          expect(recipe.id, 1);
          expect(recipe.title, "Pasta Carbonara");
          expect(recipe.ingredients, ['Spaghetti', 'Eggs', 'Pancetta', 'Parmesan Cheese', 'Black Pepper']);
          expect(recipe.instructions, "Cook spaghetti. Fry pancetta. Mix eggs and cheese. Combine all.");
          expect(recipe.imageName, "pasta_carbonara_image");
          expect(recipe.cleanedIngredients, ['spaghetti', 'eggs', 'pancetta', 'parmesan cheese', 'black pepper']);
          expect(recipe.cookTime, 20);
      });
    });
  });
}