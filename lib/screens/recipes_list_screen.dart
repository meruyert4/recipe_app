import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final allRecipes = recipeProvider.recipes;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                                recipe.imageUrl, // Assuming imageUrl is an asset path
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
                                      Icons.favorite_border, // This could be a toggleable favorite
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
      // FloatingActionButton and related logic have been removed
    );
  }
}