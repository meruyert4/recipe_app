export 'recipe_provider.dart';
export 'saved_provider.dart';
export 'theme_provider.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(User? firebaseUser) {
    if (firebaseUser != null) {
      _user = UserModel.fromFirebaseUser(firebaseUser.uid, firebaseUser.email ?? '');
    } else {
      _user = null;
    }
    notifyListeners();
  }
}
