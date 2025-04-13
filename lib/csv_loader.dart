import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/recipe.dart';

class CsvLoader {
  static Future<List<Recipe>> loadRecipesFromCsv() async {
    final rawData = await rootBundle.loadString('recipe_dataset/recipes.csv');
    List<List<dynamic>> csvData = const CsvToListConverter().convert(rawData, eol: '\n');

    // Skip header row
    return csvData.skip(1).map((row) => Recipe.fromCsv(row)).toList();
  }
}
