import 'package:recipe_app/models/recipe.dart';

class SavedRecipe {
  final int id;
  final String title;
  final List<String> ingredients;
  final String instructions;
  final String imageName;
  final List<String> cleanedIngredients;
  final int cookTime;

  SavedRecipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.imageName,
    required this.cleanedIngredients,
    required this.cookTime,
  });

  factory SavedRecipe.fromRecipe(Recipe recipe) {
    return SavedRecipe(
      id: recipe.id,
      title: recipe.title,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      imageName: recipe.imageName,
      cleanedIngredients: recipe.cleanedIngredients,
      cookTime: recipe.cookTime,
    );
  }

  Recipe toRecipe() {
  return Recipe(
    id: id,
    title: title,
    ingredients: ingredients,
    instructions: instructions,
    imageName: imageName,
    cleanedIngredients: cleanedIngredients,
    cookTime: cookTime,
  );
}


  // Getter for the image URL
  String get imageUrl => 'assets/recipe_dataset/images/$imageName.jpg';
}
