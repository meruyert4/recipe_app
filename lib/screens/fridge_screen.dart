import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OpenFridgeScreen extends StatefulWidget {
  const OpenFridgeScreen({Key? key}) : super(key: key);

  @override
  _OpenFridgeScreenState createState() => _OpenFridgeScreenState();
}

class _OpenFridgeScreenState extends State<OpenFridgeScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _ingredients = "";
  List<Recipe> _recipes = [];
  bool _isLoadingIngredients = false;
  bool _isLoadingRecipes = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _ingredients = "";
        _recipes = [];
      });
      _animationController.reset();
      _animationController.forward();
      _sendImageToAPI(_image!);
    }
  }

  Future<void> _sendImageToAPI(File image) async {
    setState(() {
      _isLoadingIngredients = true;
    });

    try {
      final base64Image = base64Encode(image.readAsBytesSync());
      final apiUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=AIzaSyDv70E2lYv91HWljgc8r8m5PoXUZqSIRCw';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": "List the ingredients you see in this fridge. Answer in following format: Ingredient1, ingredient2, etc. Don't write anything besides ingredients names"},
                {
                  "inline_data": {
                    "mime_type": "image/jpeg",
                    "data": base64Image
                  }
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _ingredients = data['candidates'][0]['content']['parts'][0]['text'];
          _isLoadingIngredients = false;
        });
      } else {
        setState(() {
          _ingredients = "Failed to fetch ingredients. Please try again.";
          _isLoadingIngredients = false;
        });
      }
    } catch (e) {
      setState(() {
        _ingredients = "Error: $e";
        _isLoadingIngredients = false;
      });
    }
  }

  Future<void> _generateRecipes() async {
    if (_ingredients.isEmpty) return;

    setState(() {
      _isLoadingRecipes = true;
      _recipes = [];
    });

    try {
      final apiUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=AIzaSyDv70E2lYv91HWljgc8r8m5PoXUZqSIRCw';

      final prompt = '''
Generate 3 different recipes using these ingredients: $_ingredients

For each recipe, please format the response as follows:

Recipe: [Recipe Name]
Description: [Brief description]
Cooking Time: [Time needed]
Difficulty: [Easy/Medium/Hard]

Ingredients:
- [ingredient 1]
- [ingredient 2]
- [etc.]

Instructions:
1. [Step 1]
2. [Step 2]
3. [etc.]

---

Make sure to use as many of the available ingredients as possible in each recipe. If some common pantry items (salt, pepper, oil, etc.) are needed but not visible in the fridge, you can include them. Focus on practical, delicious recipes that can actually be made with these ingredients.
''';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recipeText = data['candidates'][0]['content']['parts'][0]['text'];

        final recipeStrings = <String>[];
        final parts = recipeText.split('---');
        for (String part in parts) {
          if (part.trim().isNotEmpty) {
            recipeStrings.add(part);
          }
        }

        setState(() {
          _recipes = recipeStrings.map((recipeString) => Recipe.fromString(recipeString)).toList();
          _isLoadingRecipes = false;
        });
      } else {
        setState(() {
          _isLoadingRecipes = false;
        });
        _showErrorDialog("Failed to generate recipes. Please try again.");
      }
    } catch (e) {
      setState(() {
        _isLoadingRecipes = false;
      });
      _showErrorDialog("Error generating recipes: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(
                  "Error",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK", style: TextStyle(fontSize: 16)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.red[50],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRecipeDetail(Recipe recipe) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                recipe.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (recipe.description.isNotEmpty) ...[
                      Text(
                        recipe.description,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.access_time, color: Colors.blue[800]),
                              SizedBox(height: 4),
                              Text(
                                recipe.cookingTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.bar_chart, color: Colors.blue[800]),
                              SizedBox(height: 4),
                              Text(
                                recipe.difficulty,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    if (recipe.ingredients.isNotEmpty) ...[
                      Text(
                        'Ingredients:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...recipe.ingredients.map((ingredient) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: Colors.green[600],
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ingredient,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      )),
                      SizedBox(height: 16),
                    ],
                    if (recipe.instructions.isNotEmpty) ...[
                      Text(
                        'Instructions:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...recipe.instructions.asMap().entries.map((entry) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${entry.key + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.openFridge,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColorDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Selection Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        '📸 Step 1: Take a photo of your fridge',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _PhotoButton(
                              icon: Icons.camera_alt,
                              label: AppLocalizations.of(context)!.takePhoto,
                              onPressed: _isLoadingIngredients ? null : () => _getImage(ImageSource.camera),
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _PhotoButton(
                              icon: Icons.photo_library,
                              label: AppLocalizations.of(context)!.chooseFromGallery,
                              onPressed: _isLoadingIngredients ? null : () => _getImage(ImageSource.gallery),
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Image Display
              if (_image != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Your Fridge Photo',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _image!,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 24),

              // Ingredients Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🥕 Step 2: Detected Ingredients',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      if (_isLoadingIngredients)
                        _LoadingIndicator(
                          message: 'Analyzing your fridge contents...',
                        )
                      else if (_ingredients.isEmpty)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.noIngredientsFound,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Found ingredients:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green[50]!,
                                    Colors.lightGreen[50]!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Text(
                                _ingredients,
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Generate Recipes Button
              if (_ingredients.isNotEmpty && !_isLoadingIngredients)
                AnimatedOpacity(
                  opacity: _ingredients.isNotEmpty ? 1 : 0,
                  duration: Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: _isLoadingRecipes ? null : _generateRecipes,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoadingRecipes)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else
                            Icon(Icons.restaurant_menu, size: 24),
                          SizedBox(width: 12),
                          Text(
                            _isLoadingRecipes
                                ? 'Generating Recipes...'
                                : '🍳 Step 3: Generate Recipes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                ),

              SizedBox(height: 24),

              // Recipes Section
              if (_recipes.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🍽️ Recommended Recipes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    ..._recipes.map((recipe) => _RecipeCard(
                      recipe: recipe,
                      onTap: () => _showRecipeDetail(recipe),
                    )).toList(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color color;

  const _PhotoButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 28),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: color, backgroundColor: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        elevation: 0,
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  final String message;

  const _LoadingIndicator({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const _RecipeCard({
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant,
                  color: Colors.orange[800],
                  size: 30,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (recipe.description.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        recipe.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          recipe.cookingTime,
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.bar_chart, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          recipe.difficulty,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Recipe {
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String cookingTime;
  final String difficulty;

  Recipe({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.difficulty,
  });

  factory Recipe.fromString(String recipeText) {
    final lines = <String>[];
    for (String line in recipeText.split('\n')) {
      if (line.trim().isNotEmpty) {
        lines.add(line);
      }
    }

    String name = "Delicious Recipe";
    String description = "";
    List<String> ingredients = <String>[];
    List<String> instructions = <String>[];
    String cookingTime = "30 minutes";
    String difficulty = "Medium";

    String currentSection = "";

    for (String line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.toLowerCase().startsWith('recipe:') ||
          trimmedLine.toLowerCase().startsWith('name:')) {
        name = trimmedLine.split(':').skip(1).join(':').trim();
      } else if (trimmedLine.toLowerCase().startsWith('description:')) {
        description = trimmedLine.split(':').skip(1).join(':').trim();
      } else if (trimmedLine.toLowerCase().startsWith('cooking time:') ||
          trimmedLine.toLowerCase().startsWith('time:')) {
        cookingTime = trimmedLine.split(':').skip(1).join(':').trim();
      } else if (trimmedLine.toLowerCase().startsWith('difficulty:')) {
        difficulty = trimmedLine.split(':').skip(1).join(':').trim();
      } else if (trimmedLine.toLowerCase().contains('ingredients:')) {
        currentSection = "ingredients";
      } else if (trimmedLine.toLowerCase().contains('instructions:') ||
          trimmedLine.toLowerCase().contains('steps:')) {
        currentSection = "instructions";
      } else if (currentSection == "ingredients" && trimmedLine.isNotEmpty) {
        ingredients.add(trimmedLine.replaceFirst(RegExp(r'^[-•*]\s*'), ''));
      } else if (currentSection == "instructions" && trimmedLine.isNotEmpty) {
        instructions.add(trimmedLine.replaceFirst(RegExp(r'^\d+\.\s*'), ''));
      } else if (currentSection.isEmpty && trimmedLine.isNotEmpty && name == "Delicious Recipe") {
        name = trimmedLine;
      }
    }

    // Fallback parsing if structured format isn't detected
    if (ingredients.isEmpty) {
      final allText = recipeText.toLowerCase();
      if (allText.contains('ingredients') || allText.contains('you need')) {
        final parts = recipeText.split(RegExp(r'(ingredients|you need)', caseSensitive: false));
        if (parts.length > 1) {
          final ingredientSection = parts[1].split(RegExp(r'(instructions|steps|method)', caseSensitive: false))[0];
          final ingredientLines = ingredientSection.split('\n');
          for (String line in ingredientLines) {
            final trimmed = line.trim().replaceFirst(RegExp(r'^[-•*]\s*'), '');
            if (trimmed.isNotEmpty) {
              ingredients.add(trimmed);
            }
          }
        }
      }
    }

    return Recipe(
      name: name.isNotEmpty ? name : "Delicious Recipe",
      description: description,
      ingredients: ingredients,
      instructions: instructions,
      cookingTime: cookingTime,
      difficulty: difficulty,
    );
  }
}
