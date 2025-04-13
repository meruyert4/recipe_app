class Recipe {
  final String title;
  final List<String> ingredients;
  final String instructions;
  final String imageName;
  final List<String> cleanedIngredients;

  Recipe({
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.imageName,
    required this.cleanedIngredients,
  });

  factory Recipe.fromCsv(List<dynamic> values) {
    return Recipe(
      title: values[0],
      ingredients: values[1],
      instructions: values[2],
      imageName: values[3],
      cleanedIngredients: values[4],
    );
  }

  // Getter for the image URL
  String get imageUrl => 'assets/recipe_dataset/images/$imageName';
}
