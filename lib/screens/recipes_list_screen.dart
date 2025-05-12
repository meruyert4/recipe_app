import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';


class RecipesListScreen extends StatefulWidget {
  @override
  _RecipesListScreenState createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends State<RecipesListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _recipesRef = FirebaseDatabase.instance.ref('recipes');

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Recipe List')),
      body: Center(child: Text('Display recipes here...')),

      floatingActionButton: user != null && !user.isAnonymous
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: _showAddRecipeDialog,
            )
          : null,
    );
  }

  void _showAddRecipeDialog() {
    final _formKey = GlobalKey<FormState>();
    final _idController = TextEditingController();
    final _titleController = TextEditingController();
    final _ingredientsController = TextEditingController();
    final _instructionsController = TextEditingController();
    final _imageNameController = TextEditingController();
    final _imageUrlController = TextEditingController();
    final _cleanedIngredientsController = TextEditingController();
    final _cookTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Recipe'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
              TextFormField(controller: _ingredientsController, decoration: InputDecoration(labelText: 'Ingredients')),
              TextFormField(controller: _instructionsController, decoration: InputDecoration(labelText: 'Instructions')),
              TextFormField(controller: _imageNameController, decoration: InputDecoration(labelText: 'Image Name(without extension)')),
              TextFormField(controller: _imageUrlController, decoration: InputDecoration(labelText: 'Image URL')),
              TextFormField(controller: _cleanedIngredientsController, decoration: InputDecoration(labelText: 'Cleaned Ingredients')),
              TextFormField(controller: _cookTimeController, decoration: InputDecoration(labelText: 'Cook Time')),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _saveRecipe(
                  id: _idController.text,
                  title: _titleController.text,
                  ingredients: _ingredientsController.text,
                  instructions: _instructionsController.text,
                  imageName: _imageNameController.text,
                  imageUrl: _imageUrlController.text,
                  cleanedIngredients: _cleanedIngredientsController.text,
                  cookTime: _cookTimeController.text,
                );
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

Future<void> _saveRecipe({
  required String title,
  required String ingredients,
  required String instructions,
  required String imageName,
  required String imageUrl,
  required String cleanedIngredients,
  required String cookTime,
}) async {
  try {
    final directory = await getApplicationDocumentsDirectory();

    // ===== 1. Generate ID based on last row in recipes.csv =====
    final csvPath = '${directory.path}/recipes.csv';
    final csvFile = File(csvPath);
    int newId = 1;

    if (await csvFile.exists()) {
      final lines = await csvFile.readAsLines();
      if (lines.isNotEmpty) {
        final lastRow = lines.last.split(',');
        final lastId = int.tryParse(lastRow.first) ?? 0;
        newId = lastId + 1;
      }
    }

    // ===== 2. Download and save image =====
    final response = await http.get(Uri.parse(imageUrl));
    final imagePath = '${directory.path}/$imageName.jpg';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(response.bodyBytes);

    // ===== 3. Append recipe to CSV =====
    final List<List<String>> newRecipe = [
      [
        newId.toString(),
        title,
        ingredients,
        instructions,
        '$imageName.jpg',
        cleanedIngredients,
        cookTime
      ]
    ];

    if (await csvFile.exists()) {
      final sink = csvFile.openWrite(mode: FileMode.append);
      sink.write('\n' + const ListToCsvConverter().convert(newRecipe));
      await sink.close();
    } else {
      final csvContent = const ListToCsvConverter().convert(newRecipe);
      await csvFile.writeAsString(csvContent);
    }

    // ===== 4. Save to Firebase Realtime Database =====
    final recipeRef = _recipesRef.push();
    await recipeRef.set({
      'id': newId.toString(),
      'title': title,
      'ingredients': ingredients,
      'instructions': instructions,
      'image_name': '$imageName.jpg',
      'cleaned_ingredients': cleanedIngredients,
      'cook_time': cookTime,
      'image_url': imageUrl,
      'created_by': _auth.currentUser?.uid,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recipe added successfully!')));
  } catch (e) {
    print('Error saving recipe: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save recipe')));
  }
}

}

