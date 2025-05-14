import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:recipe_app/provider/recipe_provider.dart';
import 'package:recipe_app/screens/recipe_detail_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';

class RecipesListScreen extends StatefulWidget {
  const RecipesListScreen({Key? key}) : super(key: key);

  @override
  State<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends State<RecipesListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _recipesRef = FirebaseDatabase.instance.ref('recipes');

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final allRecipes = recipeProvider.recipes;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : theme.colorScheme.background,
        title: Text(
          'Discover Recipes',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search recipes...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  prefixIcon: Icon(
                    UniconsLine.search,
                    size: 18.sp,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio: 0.8,
                ),
                itemCount: allRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = allRecipes[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecipeDetailScreen(),
                          settings: RouteSettings(arguments: recipe),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isDark ? Colors.grey[900] : Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.asset(
                                recipe.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.title,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  children: [
                                    Icon(
                                      UniconsLine.clock,
                                      size: 14.sp,
                                      color: theme.primaryColor,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      '${recipe.cookTime} min',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.favorite_border,
                                      size: 14.sp,
                                      color: theme.primaryColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: user != null && !user.isAnonymous
          ? FloatingActionButton(
              onPressed: _showAddRecipeDialog,
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddRecipeDialog() {
    final _formKey = GlobalKey<FormState>();
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
              TextFormField(controller: _imageNameController, decoration: InputDecoration(labelText: 'Image Name')),
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

      final response = await http.get(Uri.parse(imageUrl));
      final imagePath = '${directory.path}/$imageName.jpg';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(response.bodyBytes);

      final newRecipe = [
        [newId.toString(), title, ingredients, instructions, '$imageName.jpg', cleanedIngredients, cookTime]
      ];

      if (await csvFile.exists()) {
        final sink = csvFile.openWrite(mode: FileMode.append);
        sink.write('\n' + const ListToCsvConverter().convert(newRecipe));
        await sink.close();
      } else {
        final csvContent = const ListToCsvConverter().convert(newRecipe);
        await csvFile.writeAsString(csvContent);
      }

      await _recipesRef.push().set({
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

      // Reload UI (if provider supports reload)
      setState(() {
        // Add a method in RecipeProvider to reload recipes if needed
      });
    } catch (e) {
      print('Error saving recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save recipe')));
    }
  }
}
