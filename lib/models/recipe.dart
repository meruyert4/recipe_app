class Recipe {
  final int id;
  final String title;
  final List<String> ingredients;
  final String instructions;
  final String imageName;
  final List<String> cleanedIngredients;
  final int cookTime;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.imageName,
    required this.cleanedIngredients,
    required this.cookTime,
  });

  factory Recipe.fromCsv(List<dynamic> values) {
  return Recipe(
    id:values[0],
    title: values[1], // Title
    ingredients: parseStringList(values[2]), // Ingredients
    instructions: values[3], // Instructions
    imageName: values[4], // Image_Name
    cleanedIngredients: parseStringList(values[5]),
    cookTime: values[6]
     // Cleaned_Ingredients
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

  String get imageUrl => 'assets/recipe_dataset/images/$imageName.jpg';
}
