import 'package:flutter/material.dart';
import 'package:recipe_app/screens/screens.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomNavBarGuest extends StatefulWidget {
  const CustomNavBarGuest({Key? key}) : super(key: key);

  @override
  State<CustomNavBarGuest> createState() => _CustomNavBarGuestState();
}

class _CustomNavBarGuestState extends State<CustomNavBarGuest>
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

    // Pages for guest users (no fridge or saved tabs)
    final guestPages = [
      const HomeScreen(),
      const RecipesListScreen(),
      const ForumScreen(),
      const ProfileScreen(),
    ];

    final guestItems = [
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
      BottomNavigationBarItem(
        icon: const Icon(UniconsLine.user),
        label: localizations.profile,
      ),
    ];

    final safeIndex = selectedIndex >= guestPages.length ? 0 : selectedIndex;

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
        items: guestItems,
      ),
      body: guestPages.elementAt(safeIndex),
    );
  }
}
