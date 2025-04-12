// lib/models/recipe_model.dart
class Recipe {
  final String recipeId;
  final String recipeName;
  final List<String> recipeIngredients;
  final String recipeMethod;
  final String recipeImage;
  final String recipeCategory;
  final double prepTime;
  final double cookTime;
  final int recipeServing;

  Recipe({
    required this.recipeId,
    required this.recipeName,
    required this.recipeIngredients,
    required this.recipeMethod,
    required this.recipeImage,
    required this.recipeCategory,
    required this.prepTime,
    required this.cookTime,
    required this.recipeServing,
  });

  // Add fromCsv factory constructor if needed
  factory Recipe.fromCsv(List<dynamic> fields) {
    return Recipe(
      recipeId: fields[0],
      recipeName: fields[1],
      recipeIngredients: fields[2].split(','), // Convert string to List
      recipeMethod: fields[3],
      recipeImage: fields[4],
      recipeCategory: fields[5] ?? 'Uncategorized',
      prepTime: double.tryParse(fields[6]) ?? 0,
      cookTime: double.tryParse(fields[7]) ?? 0,
      recipeServing: int.tryParse(fields[8]) ?? 1,
    );
  }
}