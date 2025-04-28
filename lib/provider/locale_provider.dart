import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  final _database = FirebaseDatabase.instance;

  LocaleProvider() {
    _loadUserLanguagePreference();
  }

  void toggleLocale() {
    _locale = _locale.languageCode == 'en' ? const Locale('ru') : const Locale('en');
    notifyListeners();
    _saveUserLanguagePreference();
  }

  Future<void> _saveUserLanguagePreference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _database.ref('users/${user.uid}/language').set(_locale.languageCode);
    }
  }

  Future<void> _loadUserLanguagePreference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await _database.ref('users/${user.uid}/language').get();
      if (snapshot.exists) {
        final langCode = snapshot.value.toString();
        _locale = Locale(langCode);
        notifyListeners();
      }
    }
  }
}
