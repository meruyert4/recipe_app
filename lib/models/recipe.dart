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
    title: values[1], // Title
    ingredients: parseStringList(values[2]), // Ingredients
    instructions: values[3], // Instructions
    imageName: values[4], // Image_Name
    cleanedIngredients: parseStringList(values[5]), // Cleaned_Ingredients
  );
}

static List<String> parseStringList(String value) {
  return value
      .replaceAll('[', '')
      .replaceAll(']', '')
      .split(',')
      .map((e) => e.trim().replaceAll("'", ''))
      .toList();
}

  // Getter for the image URL
  String get imageUrl => 'assets/recipe_dataset/images/$imageName.jpg';
}
