import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/provider/saved_provider.dart';
import 'package:recipe_app/widgets/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:recipe_app/custom_navbar.dart';
import 'package:recipe_app/screens/recipe_detail_screen.dart';


class SavedScreen extends StatelessWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final savedProvider = Provider.of<SavedProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: savedProvider.getSaved.isEmpty
              ? const EmptyRecipe()
              : const SavedRecipes(),
        ),
      ),
    );
  }
}

class SavedRecipes extends StatefulWidget {
  const SavedRecipes({Key? key}) : super(key: key);

  @override
  State<SavedRecipes> createState() => _SavedRecipesState();
}

class _SavedRecipesState extends State<SavedRecipes> {
  @override
  Widget build(BuildContext context) {
    final savedProvider = Provider.of<SavedProvider>(context);
    final savedList = savedProvider.getSaved.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 6.0.h),
        Text(
          'Saved',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        SizedBox(height: 4.0.h),
        const TabRow(),
        SizedBox(height: 2.0.h),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          separatorBuilder: (context, index) => const SizedBox(height: 15.0),
          itemCount: savedList.length,
          itemBuilder: (context, index) {
            final recipe = savedList[index];
            return Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                color: Colors.red,
                padding: const EdgeInsets.only(right: 15.0),
                child: Icon(
                  UniconsLine.trash,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              onDismissed: (_) {
                setState(() {
                  savedProvider.removeRecipe(recipe.title);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${recipe.title} deleted')),
                );
              },
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecipeDetailScreen(),
                      settings: RouteSettings(arguments: recipe.toRecipe()), // FIXED LINE
                    ),
                  );
                },
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
                          width: 20.0.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        ),
                        SizedBox(width: 2.0.h),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.title,
                                  style:
                                      Theme.of(context).textTheme.headlineMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 1.5.h),
                                Row(
                                  children: [
                                    Icon(UniconsLine.clock, size: 16.0, color: Colors.grey.shade500),
                                    SizedBox(width: 1.5.w),
                                    Text(
                                      '${recipe.cookTime.toStringAsFixed(0)} M Prep',
                                      style: Theme.of(context).textTheme.bodyMedium,
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
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class EmptyRecipe extends StatelessWidget {
  const EmptyRecipe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10.h),
          Image.asset('assets/recipebook.gif'),
          Text(
            'You haven\'t saved any recipes yet',
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontSize: 14.sp),
          ),
          const SizedBox(height: 5.0),
          Text(
            'Want to take a look?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 2.5.h),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomNavBar(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 45.0,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Explore',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: Colors.white, fontSize: 14.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
