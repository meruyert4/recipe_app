import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/custom_navbar.dart';
import 'package:recipe_app/screens/auth/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          // If the user is logged in, navigate to CustomNavBar
          if (snapshot.hasData) {
            return const CustomNavBar();
          }
          // If the user is not logged in, show the login screen (or other UI)
          return const LoginScreen();
        }
        // Show loading spinner while checking auth state
        return const CircularProgressIndicator();
      },
    );
  }
}
