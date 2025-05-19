import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:recipe_app/provider/provider.dart';
import 'package:recipe_app/provider/locale_provider.dart';
import 'package:recipe_app/provider/connectivity_provider.dart';
import 'package:recipe_app/firebase_options.dart';
import 'package:recipe_app/screens/auth/login_screen.dart';
import 'package:recipe_app/custom_navbar.dart';
import 'package:recipe_app/screens/auth/auth.dart';
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
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
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'FairyFridge',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: CustomTheme.lightTheme,
          darkTheme: CustomTheme.darkTheme,
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const AuthGate(),
        );
      },
    );
  }
}



class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Just trigger the check, the StreamBuilder will handle the actual state
      setState(() {
        _isCheckingAuth = false;
      });
    } catch (e) {
      print('Auth check error: $e');
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking initial auth state
        if (_isCheckingAuth) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle connection state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle errors
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Authentication error: ${snapshot.error}')),
          );
        }

        final user = snapshot.data;
        
        if (user != null) {
          // User is signed in
          if (user.isAnonymous) {
            // Guest user
            return const CustomNavBar(isGuest: true);
          } else {
            // Regular authenticated user
            return FutureBuilder<DataSnapshot>(
              future: FirebaseDatabase.instance
                  .ref()
                  .child('users/${user.uid}')
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (userSnapshot.hasError) {
                  return Scaffold(
                    body: Center(
                        child: Text('Error loading user data: ${userSnapshot.error}')),
                  );
                }

                // User data exists, proceed to home
                if (userSnapshot.hasData && userSnapshot.data!.value != null) {
                  return const CustomNavBar(isGuest: false);
                }

                // This shouldn't normally happen for authenticated users
                return const LoginScreen();
              },
            );
          }
        } else {
          // No user is signed in
          return const LoginScreen();
        }
      },
    );
  }
}
