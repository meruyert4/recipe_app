import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sizer/sizer.dart';

import 'package:recipe_app/provider/provider.dart';
import 'package:recipe_app/provider/theme_provider.dart';
import 'package:recipe_app/firebase_options.dart';
import 'package:recipe_app/screens/auth/login_screen.dart';
import 'package:recipe_app/custom_navbar.dart';
import 'custom_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()..loadRecipes()),
        ChangeNotifierProvider(create: (_) => SavedProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // <- here
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'FairyFridge',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode, // <- dynamic mode
          theme: CustomTheme.lightTheme,
          darkTheme: CustomTheme.darkTheme,
          home: const AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const CustomNavBar();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
