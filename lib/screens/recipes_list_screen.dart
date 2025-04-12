import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/provider/provider.dart';
import 'package:recipe_app/screens/recipe_detail_screen.dart';
import 'package:recipe_app/widgets/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';

class RecipesListScreen extends StatelessWidget {
  const RecipesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryName = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.0.h),
              Text(
                categoryName,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              SizedBox(height: 4.0.h),
              const TabRow(),
              RecipesListView(categoryName: categoryName),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipesListView extends StatelessWidget {
  final String categoryName;
  const RecipesListView({Key? key, required this.categoryName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipesProvider = Provider.of<ListOfRecipes>(context);
    final recipeList = recipesProvider.findByCategory(categoryName);
    final savedProvider = Provider.of<SavedProvider>(context);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 1.2,
      child: ListView.builder(
        itemCount: recipeList.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final recipe = recipeList[index];
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecipeDetailScreen(),
                settings: RouteSettings(arguments: recipe),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                height: 20.0.h,
                child: Material(
                  color: Colors.white,
                  elevation: 2.0,
                  child: Row(
                    children: [
                      ReusableNetworkImage(
                        height: 20.0.h,
                        width: 18.0.h,
                        imageUrl: recipe.recipeImage,
                      ),
                      SizedBox(width: 2.0.h),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.recipeName,
                              style: Theme.of(context).textTheme.headlineMedium,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            SizedBox(height: 1.5.h),
                            Row(
                              children: [
                                Icon(UniconsLine.clock, size: 16.0, color: Colors.grey.shade500),
                                SizedBox(width: 1.5.w),
                                Text('${recipe.prepTime}M Prep', style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                            SizedBox(height: 1.0.h),
                            Row(
                              children: [
                                Icon(UniconsLine.clock, size: 16.0, color: Colors.grey.shade500),
                                SizedBox(width: 1.5.w),
                                Text('${recipe.cookTime}M Cook', style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: IconButton(
                          onPressed: () {
                            savedProvider.addAndRemoveFromSaved(
                              recipe.recipeId,
                              recipe.recipeCategory,
                              recipe.cookTime,
                              recipe.prepTime,
                              recipe.recipeImage,
                              recipe.recipeName,
                            );
                          },
                          icon: Icon(
                            savedProvider.getSaved.containsKey(recipe.recipeId)
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 22.0.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}