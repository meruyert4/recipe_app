import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  final _database = FirebaseDatabase.instance;

  ThemeProvider() {
    _loadUserThemePreference();
  }

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _saveUserThemePreference();
  }

  Future<void> _saveUserThemePreference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _database.ref('users/${user.uid}/theme').set(isDarkMode ? 'dark' : 'light');
    }
  }

  Future<void> _loadUserThemePreference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await _database.ref('users/${user.uid}/theme').get();
      if (snapshot.exists) {
        final themeValue = snapshot.value.toString();
        _themeMode = themeValue == 'dark' ? ThemeMode.dark : ThemeMode.light;
        notifyListeners();
      }
    }
  }
}
