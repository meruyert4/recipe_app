import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/provider/provider.dart';
import 'package:recipe_app/screens/recipe_detail_screen.dart';
import 'package:recipe_app/widgets/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Theme.of(context).colorScheme.background, 
      body: SafeArea(
        child: FutureBuilder(
          future: Provider.of<RecipeProvider>(context, listen: false).loadRecipes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.errorLoadingData,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            } else {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HomeLogoText(),
                          SizedBox(height: 2.h),
                          const HomeHeaderRow(),
                          SizedBox(height: 3.h),
                          const SearchField(),
                          SizedBox(height: 4.h),
                          // Первая секция - Quick Recipes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Quick & Easy Recipes",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              InkWell(
                                onTap: () {
                                  // TODO: Navigate to all quick recipes
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: EdgeInsets.all(1.w),
                                  child: Text(
                                    "See All",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: QuickRecipesList()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 3.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.popularRecipes ?? "Popular Recipes",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          InkWell(
                            onTap: () {
                              // TODO: Navigate to all popular recipes
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: EdgeInsets.all(1.w),
                              child: Text(
                                "See All",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: HomePopularGrid()),
                  SliverToBoxAdapter(child: SizedBox(height: 2.h)),
                ],
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
    final userName = FirebaseAuth.instance.currentUser?.displayName ??
        AppLocalizations.of(context)!.user;

    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.greeting(userName),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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

class HomePopularGrid extends StatelessWidget {
  const HomePopularGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final popularRecipes = recipeProvider.popularRecipes;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: popularRecipes.length > 4 ? 4 : popularRecipes.length, // Limit to 4 items
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 2.h,
          crossAxisSpacing: 4.w,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final recipe = popularRecipes[index];
          final isNetworkImage = recipe.imageName.startsWith('http');

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
            child: HomeStack(
              image: isNetworkImage
                  ? recipe.imageName
                  : 'assets/recipe_dataset/images/${recipe.imageName}.jpg',
              text: recipe.title,
              prepTime: 30,
              cookTime: 45,
              recipeReview: 4.5,
            ),
          );
        },
      ),
    );
  }
}

class QuickRecipesList extends StatelessWidget {
  const QuickRecipesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    // Assuming you have a method to get quick recipes or you filter them here
    final quickRecipes = recipeProvider.recipes
        .where((recipe) => recipe.cookTime <= 20) // Filter recipes that cook in 20 min or less
        .toList()
      ..sort((a, b) => a.cookTime.compareTo(b.cookTime)); // Sort by cook time (fastest first)
    
    final quickestRecipes = quickRecipes.take(5).toList(); // Take only the 5 fastest recipes
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 20.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        scrollDirection: Axis.horizontal,
        itemCount: quickestRecipes.length,
        itemBuilder: (context, index) {
          final recipe = quickestRecipes[index];
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
            child: Container(
              width: 45.w,
              margin: EdgeInsets.only(right: 3.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                    child: Image.asset(
                      recipe.imageUrl,
                      width: 15.w,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 15.w,
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: Icon(Icons.broken_image, 
                            color: isDark ? Colors.grey[600] : Colors.grey[400]),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "${recipe.cookTime} min",
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            recipe.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Icon(UniconsLine.star, size: 12, color: Colors.amber),
                              SizedBox(width: 1.w),
                              Text(
                                "4.5",
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: image.startsWith('http')
                ? Image.network(
                    image,
                    height: 12.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 12.h,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: Icon(Icons.broken_image, 
                          color: isDark ? Colors.grey[600] : Colors.grey[400]),
                    ),
                  )
                : Image.asset(
                    image,
                    height: 12.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 12.h,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: Icon(Icons.broken_image, 
                          color: isDark ? Colors.grey[600] : Colors.grey[400]),
                    ),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : null,
                      ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Icon(
                      UniconsLine.clock, 
                      size: 14, 
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${(prepTime + cookTime).toStringAsFixed(0)} min',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Icon(UniconsLine.star, size: 14, color: Colors.amber),
                    SizedBox(width: 1.w),
                    Text(
                      recipeReview.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
