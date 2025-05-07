import 'package:flutter/material.dart';
import 'package:recipe_app/screens/screens.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomNavBar extends StatefulWidget {
  final bool isGuest;

  const CustomNavBar({Key? key, required this.isGuest}) : super(key: key);

  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    // Common pages for all users (removed const)
    final commonPages = [
      const HomeScreen(),
      const RecipesListScreen(),
      const ForumScreen(),
    ];

    final commonItems = [
      BottomNavigationBarItem(
        icon: const Icon(UniconsLine.home),
        label: localizations.home,
      ),
      BottomNavigationBarItem(
        icon: const Icon(UniconsLine.restaurant),
        label: localizations.recipes,
      ),
      BottomNavigationBarItem(
        icon: const Icon(UniconsLine.comments),
        label: localizations.forum,
      ),
    ];

    final authPages = [
      ...commonPages,
      const OpenFridgeScreen(),
      const SavedScreen(),
      const ProfileScreen(),
    ];

    final authItems = [
      ...commonItems,
      BottomNavigationBarItem(
        icon: const Icon(UniconsLine.utensils),
        label: localizations.fridge,
      ),
      BottomNavigationBarItem(
        icon: const Icon(UniconsLine.heart),
        label: localizations.saved,
      ),
      BottomNavigationBarItem(
        icon: const Icon(UniconsLine.user),
        label: localizations.profile,
      ),
    ];

    // Pages and items based on user type
    final pages = widget.isGuest 
        ? [...commonPages, const ProfileScreen()] 
        : authPages;
        
    final items = widget.isGuest
        ? [
            ...commonItems,
            BottomNavigationBarItem(
              icon: const Icon(UniconsLine.user),
              label: localizations.profile,
            ),
          ]
        : authItems;

    // Safe index handling
    final safeIndex = selectedIndex >= pages.length ? 0 : selectedIndex;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        elevation: 4.0,
        currentIndex: safeIndex,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        selectedFontSize: 10.0.sp,
        iconSize: 18.sp,
        showUnselectedLabels: true,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: theme.unselectedWidgetColor,
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
      body: pages.elementAt(safeIndex),
    );
  }
}