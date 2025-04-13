import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/provider/recipe_provider.dart';
import 'package:recipe_app/screens/recipe_detail_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';

class RecipesListScreen extends StatelessWidget {
  const RecipesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final allRecipes = recipeProvider.recipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'All Recipes',
                style: TextStyle(fontSize: 24),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = allRecipes[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecipeDetailScreen(),
                          settings: RouteSettings(arguments: recipe),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: SizedBox(
                        height: 20.0.h,
                        child: Material(
                          color: Colors.white,
                          elevation: 2.0,
                          child: Row(
                            children: [
                              Image.asset(
                                recipe.imageUrl,
                                height: 20.0.h,
                                width: 18.0.h,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 2.0.h),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    SizedBox(height: 1.5.h),
                                    Row(
                                      children: [
                                        Icon(UniconsLine.clock,
                                            size: 16.0,
                                            color: Colors.grey.shade500),
                                        SizedBox(width: 1.5.w),
                                        Text('30M Prep',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium),
                                      ],
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }
}
