// lib/provider/saved_provider.dart
import 'package:flutter/material.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/saved_recipes.dart';

class SavedProvider with ChangeNotifier {
  final Map<String, SavedRecipe> _savedRecipes = {};

  Map<String, SavedRecipe> get getSaved => _savedRecipes;

  void addRecipe(Recipe recipe) {
    final savedRecipe = SavedRecipe.fromRecipe(recipe);
    _savedRecipes[recipe.title] = savedRecipe;
    notifyListeners();
  }

  void removeRecipe(String title) {
    _savedRecipes.remove(title);
    notifyListeners();
  }

  void addAndRemoveFromSaved(Recipe recipe) {
    if (_savedRecipes.containsKey(recipe.title)) {
      _savedRecipes.remove(recipe.title);
    } else {
      _savedRecipes[recipe.title] = SavedRecipe.fromRecipe(recipe);
    }
    notifyListeners();
  }
}
