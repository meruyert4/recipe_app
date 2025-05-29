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

class _CustomNavBarGuestState extends State<CustomNavBarGuest> {
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

    final guestPages = [
      const HomeScreen(),
      const RecipesListScreen(),
      const ForumScreen(),
      const ProfileScreen(),
    ];

    final guestItems = [
      BottomNavigationBarItem(
        icon: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(6),
          child: const Icon(UniconsLine.home),
        ),
        label: localizations.home,
      ),
      BottomNavigationBarItem(
        icon: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(6),
          child: const Icon(UniconsLine.restaurant),
        ),
        label: localizations.recipes,
      ),
      BottomNavigationBarItem(
        icon: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(6),
          child: const Icon(UniconsLine.comments),
        ),
        label: localizations.forum,
      ),
      BottomNavigationBarItem(
        icon: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(6),
          child: const Icon(UniconsLine.user),
        ),
        label: localizations.profile,
      ),
    ];

    final safeIndex = selectedIndex.clamp(0, guestPages.length - 1);

    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05).round()),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: ClipRRect(
          child: BottomNavigationBar(
            backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
            elevation: 0,
            currentIndex: safeIndex,
            onTap: _onItemTapped,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 10.0.sp,
            unselectedFontSize: 9.0.sp,
            iconSize: 22.sp,
            selectedItemColor: theme.primaryColor,
            unselectedItemColor: theme.unselectedWidgetColor.withAlpha((0.7 * 255).round()),
            type: BottomNavigationBarType.fixed,
            items: guestItems,
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
      ),
      body: guestPages[safeIndex],
    );
  }
}