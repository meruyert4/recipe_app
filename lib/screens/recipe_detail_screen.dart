import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/models/models.dart';
import 'package:recipe_app/provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:recipe_app/models/recipe.dart' as recipe_model;

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipe = ModalRoute.of(context)!.settings.arguments as recipe_model.Recipe;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                recipe.imageUrl, // Use the getter we added
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.title, style: Theme.of(context).textTheme.headline4),
                    // Add more recipe details here
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

extension on TextTheme {
  get headline4 => null;
}
class RecipeMethod extends StatelessWidget {
  const RecipeMethod({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final popularRecipes = ModalRoute.of(context)!.settings.arguments as Recipe;
    return Material(
      color: Colors.white,
      elevation: 2.0,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Method',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                const Icon(UniconsLine.label),
                const SizedBox(width: 5.0),
                Expanded(
                  child: Text(
                    popularRecipes.recipeMethod,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}

class RecipeAbout extends StatelessWidget {
  const RecipeAbout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final popularRecipes = ModalRoute.of(context)!.settings.arguments as Recipe;
    final savedProvider = Provider.of<SavedProvider>(context);
    return Material(
      color: Colors.white,
      elevation: 2.0,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  popularRecipes.recipeName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Row(
                  children: const [
                    Icon(UniconsLine.share, size: 26.0),
                    SizedBox(width: 5.0),
                    Icon(UniconsLine.bookmark, size: 26.0)
                  ],
                )
              ],
            ),
            OutlinedButton(
              onPressed: () {},
              child: Text(
                popularRecipes.recipeCategory,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ),
            const SizedBox(height: 10.0),
            Divider(
              thickness: 0.2,
              color: Theme.of(context).primaryColor,
              indent: 10.0,
              endIndent: 10.0,
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(UniconsLine.clock),
                    const SizedBox(width: 5.0),
                    Text(
                      '${popularRecipes.prepTime.toStringAsFixed(0)} M Prep Time',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(UniconsLine.clock),
                    const SizedBox(width: 5.0),
                    Text(
                      '${popularRecipes.cookTime.toStringAsFixed(0)} M Cook Time',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                const Icon(UniconsLine.users_alt),
                const SizedBox(width: 5.0),
                Text(
                  '${popularRecipes.recipeServing} People Serving',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}

class RecipeIngredient extends StatelessWidget {
  const RecipeIngredient({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final popularRecipes = ModalRoute.of(context)!.settings.arguments as Recipe;
    return Material(
      color: Colors.white,
      elevation: 2.0,
      child: Container(
        height: 130.0,
        width: MediaQuery.of(context).size.width / 1.1,
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(UniconsLine.check),
                      const SizedBox(width: 5.0),
                      Text(
                        popularRecipes.recipeIngredients[0],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(UniconsLine.check),
                      const SizedBox(width: 5.0),
                      Text(
                        popularRecipes.recipeIngredients[1],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(UniconsLine.check),
                      const SizedBox(width: 5.0),
                      Text(
                        popularRecipes.recipeIngredients[2],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}