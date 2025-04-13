import 'package:recipe_app/models/recipe.dart';

class SavedRecipe {
  final String title;
  final List<String> ingredients;
  final String instructions;
  final String imageName;
  final List<String> cleanedIngredients;

  SavedRecipe({
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.imageName,
    required this.cleanedIngredients,
  });

  factory SavedRecipe.fromRecipe(Recipe recipe) {
    return SavedRecipe(
      title: recipe.title,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      imageName: recipe.imageName,
      cleanedIngredients: recipe.cleanedIngredients,
    );
  }

  Recipe toRecipe() {
  return Recipe(
    title: title,
    ingredients: ingredients,
    instructions: instructions,
    imageName: imageName,
    cleanedIngredients: cleanedIngredients,
  );
}


  // Getter for the image URL
  String get imageUrl => 'assets/recipe_dataset/images/$imageName.jpg';
}
