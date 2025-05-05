import 'package:flutter/material.dart';
import 'package:recipe_app/screens/screens.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({Key? key}) : super(key: key);

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

  static List<Widget> pages = [
    const HomeScreen(),
    const RecipesListScreen(),
    const SavedScreen(),
    const ForumScreen(),
    const OpenFridgeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
       backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        elevation: 4.0,
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        selectedFontSize: 10.0.sp,
        iconSize: 18.sp,
        showUnselectedLabels: true,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: theme.unselectedWidgetColor,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(UniconsLine.home),
            label: localizations.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(UniconsLine.restaurant),
            label: localizations.recipes,
          ),
          BottomNavigationBarItem(
            icon: const Icon(UniconsLine.bookmark),
            label: localizations.saved,
          ),
          BottomNavigationBarItem(
            icon: const Icon(UniconsLine.comments),
            label: localizations.forum,
          ),
          BottomNavigationBarItem(
            icon: const Icon(UniconsLine.utensils),
            label: localizations.fridge,
          ),
          BottomNavigationBarItem(
            icon: const Icon(UniconsLine.user),
            label: localizations.profile,
          ),
        ],
      ),
      body: pages.elementAt(selectedIndex),
    );
  }
}
