import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/saved_recipes.dart';

void main() {
  group('SavedRecipe Model Tests', () {
    // Базовый Recipe для тестов
    final baseRecipe = Recipe(
      id: 1,
      title: 'Original Recipe',
      ingredients: ['Ing1', 'Ing2'],
      instructions: 'Original instructions.',
      imageName: 'original_image',
      cleanedIngredients: ['ing1', 'ing2'],
      cookTime: 25,
    );

    // Тест конструктора SavedRecipe
    test('SavedRecipe object should be created with correct properties', () {
      final savedRecipe = SavedRecipe(
        id: 2,
        title: 'Saved Test Recipe',
        ingredients: ['SavedIng1', 'SavedIng2'],
        instructions: 'Saved instructions.',
        imageName: 'saved_test_image',
        cleanedIngredients: ['saveding1', 'saveding2'],
        cookTime: 40,
      );

      expect(savedRecipe.id, 2);
      expect(savedRecipe.title, 'Saved Test Recipe');
      expect(savedRecipe.ingredients, ['SavedIng1', 'SavedIng2']);
      expect(savedRecipe.instructions, 'Saved instructions.');
      expect(savedRecipe.imageName, 'saved_test_image');
      expect(savedRecipe.cleanedIngredients, ['saveding1', 'saveding2']);
      expect(savedRecipe.cookTime, 40);
    });

    // Тест factory SavedRecipe.fromRecipe
    test('SavedRecipe.fromRecipe should correctly convert Recipe to SavedRecipe', () {
      final savedRecipe = SavedRecipe.fromRecipe(baseRecipe);

      expect(savedRecipe.id, baseRecipe.id);
      expect(savedRecipe.title, baseRecipe.title);
      expect(savedRecipe.ingredients, baseRecipe.ingredients);
      expect(savedRecipe.instructions, baseRecipe.instructions);
      expect(savedRecipe.imageName, baseRecipe.imageName);
      expect(savedRecipe.cleanedIngredients, baseRecipe.cleanedIngredients);
      expect(savedRecipe.cookTime, baseRecipe.cookTime);
    });

    // Тест метода toRecipe
    test('toRecipe should correctly convert SavedRecipe to Recipe', () {
      final savedRecipe = SavedRecipe.fromRecipe(baseRecipe);
      final convertedRecipe = savedRecipe.toRecipe();

      expect(convertedRecipe.id, savedRecipe.id);
      expect(convertedRecipe.title, savedRecipe.title);
      expect(convertedRecipe.ingredients, savedRecipe.ingredients);
      expect(convertedRecipe.instructions, savedRecipe.instructions);
      expect(convertedRecipe.imageName, savedRecipe.imageName);
      expect(convertedRecipe.cleanedIngredients, savedRecipe.cleanedIngredients);
      expect(convertedRecipe.cookTime, savedRecipe.cookTime);

      // Убедимся, что это действительно объект Recipe
      expect(convertedRecipe, isA<Recipe>());
    });

    // Тест imageUrl геттера
    test('imageUrl getter should return correct path for SavedRecipe', () {
      final savedRecipe = SavedRecipe(
        id: 1,
        title: 'Test Recipe',
        ingredients: [],
        instructions: '',
        imageName: 'saved_recipe_image',
        cleanedIngredients: [],
        cookTime: 0,
      );
      expect(savedRecipe.imageUrl, 'assets/recipe_dataset/images/saved_recipe_image.jpg');
    });
  });
}