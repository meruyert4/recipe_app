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
      RecipesListScreen(),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(
            color: Colors.black.withOpacity(0.1),
            width: 0.5,
          )),
        ),
        child: BottomNavigationBar(
          backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
          elevation: 0, // Remove default shadow
          currentIndex: safeIndex,
          onTap: _onItemTapped,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 10.0.sp,
          unselectedFontSize: 9.0.sp,
          iconSize: 22.sp, // Slightly larger icons
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: theme.unselectedWidgetColor.withOpacity(0.7),
          type: BottomNavigationBarType.fixed,
          items: items.map((item) => BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              ),
              child: Icon(
                (item.icon as Icon).icon, // Preserve the original icon
                key: ValueKey(item.label), // Unique key for animation
                size: 20.sp, // Slightly smaller when inactive
              ),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                (item.icon as Icon).icon,
                size: 22.sp, // Slightly larger when active
              ),
            ),
            label: item.label,
          )).toList(),
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ),
      body: pages.elementAt(safeIndex),
    );
  }
}
