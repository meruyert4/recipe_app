import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/provider/saved_provider.dart';
import 'package:recipe_app/widgets/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:recipe_app/custom_navbar.dart';
import 'package:recipe_app/screens/recipe_detail_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final savedProvider = Provider.of<SavedProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: savedProvider.getSaved.isEmpty
            ? const EmptyRecipe()
            : const SavedRecipes(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                Text(
                  AppLocalizations.of(context)!.saved,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 2.h),
                const TabRowRedesigned(),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final recipe = savedList[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.only(right: 4.w),
                    child: Icon(
                      UniconsLine.trash,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      savedProvider.removeRecipe(recipe.title);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.recipeDeleted(recipe.title),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        action: SnackBarAction(
                          label: 'UNDO',
                          textColor: Theme.of(context).primaryColor,
                          onPressed: () {
                            // Add back recipe logic here
                            // savedProvider.addRecipe(recipe);
                          },
                        ),
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecipeDetailScreen(),
                          settings: RouteSettings(arguments: recipe.toRecipe()),
                        ),
                      );
                    },
                    child: Container(
                      height: 14.h,
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
                              height: 14.h,
                              width: 14.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 14.h,
                                width: 14.h,
                                color: isDark ? Colors.grey[800] : Colors.grey[200],
                                child: Icon(
                                  Icons.broken_image,
                                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                                  size: 24.sp,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(3.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    recipe.title,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
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
                                        color: isDark ? Colors.white70 : Colors.grey[600],
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        '${recipe.cookTime.toStringAsFixed(0)} min',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: isDark ? Colors.white70 : Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Icon(
                                        UniconsLine.star,
                                        size: 14.sp,
                                        color: Colors.amber,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        '4.5',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: isDark ? Colors.white70 : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 14.h,
                            width: 12.w,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
                            ),
                            child: Center(
                              child: Icon(
                                UniconsLine.bookmark,
                                color: Theme.of(context).primaryColor,
                                size: 18.sp,
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
            childCount: savedList.length,
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 2.h),
        ),
      ],
    );
  }
}

class TabRowRedesigned extends StatefulWidget {
  const TabRowRedesigned({Key? key}) : super(key: key);

  @override
  State<TabRowRedesigned> createState() => _TabRowRedesignedState();
}

class _TabRowRedesignedState extends State<TabRowRedesigned> {
  int selectedIndex = 0;
  final List<String> categories = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Dessert'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 5.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 3.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : isDark ? Colors.grey[900] : Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : isDark ? Colors.white70 : Colors.black54,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12.sp,
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

class EmptyRecipe extends StatelessWidget {
  const EmptyRecipe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 4.h),
            Image.asset(
              'assets/recipebook.gif',
              height: 30.h,
            ),
            SizedBox(height: 3.h),
            Text(
              AppLocalizations.of(context)!.noSavedRecipes,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              AppLocalizations.of(context)!.wantToTakeALook,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomNavBar(isGuest: false),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 6.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.explore,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
