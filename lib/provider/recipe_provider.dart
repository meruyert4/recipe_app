import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import 'package:flutter/services.dart'; // For loading assets
import 'package:csv/csv.dart'; // For CSV parsing
import 'package:flutter/material.dart';

class RecipeProvider extends ChangeNotifier {
  List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  List<Recipe> get popularRecipes {
    // You can change the logic here to define what you want as "popular"
    return _recipes.take(5).toList();
  }

  // Load recipes from CSV file
  Future<void> loadRecipes() async {
  if (_recipes.isNotEmpty) return; // Avoid reloading

  print("Loading recipes...");
  
  final csvData = await rootBundle.loadString('assets/recipe_dataset/recipes.csv');
  print(csvData.substring(0, 200)); // Inspect format

  _recipes = parseCsv(csvData);
  print("Parsed recipes count: ${_recipes.length}");

  notifyListeners();
}


  List<Recipe> parseCsv(String csvContent) {
    final rows = const CsvToListConverter().convert(csvContent, eol: '\n');
    if (rows.isEmpty) return [];

    // Remove header row
    rows.removeAt(0);

    return rows.map((row) => Recipe.fromCsv(row)).toList();
  }

  void searchRecipe(String query) {
    if (query.isEmpty) {
      loadRecipes();
    } else {
      _recipes = _recipes.where((recipe) {
        return recipe.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
      notifyListeners();
    }
  }
}
