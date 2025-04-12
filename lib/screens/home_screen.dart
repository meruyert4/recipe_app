import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/provider/provider.dart';
import 'package:recipe_app/screens/recipe_detail_screen.dart';
import 'package:recipe_app/screens/recipes_list_screen.dart';
import 'package:recipe_app/utils/utils.dart';
import 'package:recipe_app/widgets/widgets.dart';
import 'package:unicons/unicons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40.0),
              const HomeLogoText(),
              const SizedBox(height: 10.0),
              const HomeHeaderRow(),
              const SizedBox(height: 20.0),
              const SearchField(),
              const SizedBox(height: 40.0),
              const HomeGrid(),
              const SizedBox(height: 40.0),
              Text(
                'Popular Recipes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20.0),
              const HomePopularGrid(),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeHeaderRow extends StatelessWidget {
  const HomeHeaderRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Good Morning, User',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Spacer(flex: 3),
        const Expanded(
          child: ProfileImage(
            height: 50.0,
            image: 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f',
          ),
        ),
      ],
    );
  }
}

class HomePopularGrid extends StatelessWidget {
  const HomePopularGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipes = Provider.of<ListOfRecipes>(context);
    final popularRecipes = recipes.popularRecipes;
    return SizedBox(
      height: 350.0,
      child: ListView.builder(
        itemCount: popularRecipes.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: HomeStack(
                image: popularRecipes[index].recipeImage,
                text: popularRecipes[index].recipeName,
                prepTime: popularRecipes[index].prepTime,
                cookTime: popularRecipes[index].cookTime,
                recipeReview: popularRecipes[index].recipeReview,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipeDetailScreen(),
                  settings: RouteSettings(arguments: popularRecipes[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class HomeStack extends StatelessWidget {
  final String image;
  final String text;
  final double prepTime;
  final double cookTime;
  final double recipeReview;

  const HomeStack({
    Key? key,
    required this.image,
    required this.text,
    required this.prepTime,
    required this.cookTime,
    required this.recipeReview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black87.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ), // Added missing closing parenthesis here
        ],
      ),
      child: Stack(
        children: [
          ReusableNetworkImage(
            imageUrl: image,
            height: 350.0,
            width: 200.0,
          ),
          Positioned(
            bottom: 10.0,
            right: 12.0,
            child: Container(
              width: 180.0,
              height: 110.0,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: Theme.of(context).textTheme.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5.0),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(UniconsLine.clock, size: 16),
                        const SizedBox(width: 5.0),
                        Text(
                          '${(prepTime + cookTime).toStringAsFixed(0)} M Total',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(UniconsLine.star, size: 16),
                        const SizedBox(width: 5.0),
                        Text(
                          recipeReview.toStringAsFixed(1),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class HomeGrid extends StatelessWidget {
  const HomeGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.0,
      child: ListView.builder(
        itemCount: iconList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = iconList[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipesListScreen(),
                  settings: RouteSettings(arguments: item.category),
                ),
              );
            },
            child: Container(
              width: 120.0,
              padding: const EdgeInsets.all(5.0),
              child: Material(
                color: Colors.white,
                elevation: 2.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      item.icon,
                      height: 40,
                      width: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.fastfood, size: 40);
                      },
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      item.text,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}