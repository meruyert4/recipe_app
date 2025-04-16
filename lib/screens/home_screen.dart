import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/provider/provider.dart';
import 'package:recipe_app/screens/recipe_detail_screen.dart';
import 'package:recipe_app/widgets/widgets.dart';
import 'package:unicons/unicons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: FutureBuilder(
          future: Provider.of<RecipeProvider>(context, listen: false).loadRecipes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading recipes'));
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24.0),
                      const HomeLogoText(),
                      const SizedBox(height: 16.0),
                      const HomeHeaderRow(),
                      const SizedBox(height: 24.0),
                      const SearchField(),
                      const SizedBox(height: 32.0),
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12.0),
                      const HomeGrid(),
                      const SizedBox(height: 32.0),
                      Text(
                        'Popular Recipes',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      const HomePopularGrid(),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class HomeHeaderRow extends StatelessWidget {
  const HomeHeaderRow({Key? key}) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    await FirebaseAuth.instance.signOut();
  },);
    return Row(
      children: [
        Text(
         'Good Morning, ${FirebaseAuth.instance.currentUser?.displayName ?? 'User'} 👋',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        const ProfileImage(
          height: 50.0,
          image: 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f',
        ),
      ],
    );
    
  }

}

class HomeGrid extends StatelessWidget {
  const HomeGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final recipes = recipeProvider.recipes;
    return SizedBox(
      height: 130.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final item = recipes[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipeDetailScreen(),
                  settings: RouteSettings(arguments: item),
                ),
              );
            },
            child: Container(
              width: 120.0,
              margin: const EdgeInsets.only(right: 12.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    item.imageUrl,
                    height: 40.0,
                    width: 40.0,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 40),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class HomePopularGrid extends StatelessWidget {
  const HomePopularGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final popularRecipes = recipeProvider.popularRecipes;

    return SizedBox(
      height: 350.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularRecipes.length,
        itemBuilder: (context, index) {
          final recipe = popularRecipes[index];
          
          // Check if image is a URL or local asset
          bool isNetworkImage = recipe.imageName.startsWith('http');

          return GestureDetector(
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
              padding: const EdgeInsets.only(right: 20.0),
              child: HomeStack(
                image: isNetworkImage
                    ? recipe.imageName // Network image
                    : 'assets/recipe_dataset/images/${recipe.imageName}.jpg', // Local asset image
                text: recipe.title,
                prepTime: 30.0,
                cookTime: 45.0,
                recipeReview: 4.5,
              ),
            ),
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
          ),
        ],
      ),
      child: Stack(
        children: [
          // Use BoxFit.cover for consistent image sizing
          Image.asset(
            image,
            height: 350.0,
            width: 200.0,
            fit: BoxFit.cover, // Ensures the image fills the space while preserving its aspect ratio
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.fastfood, size: 40);
            },
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
