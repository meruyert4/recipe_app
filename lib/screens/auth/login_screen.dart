import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
// import 'package:google_sign_in/google_sign_in.dart';

import 'package:recipe_app/screens/home_screen.dart';
import 'package:recipe_app/screens/auth/register_screen.dart';
import 'package:recipe_app/screens/auth/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? error;

  Future<void> login() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> continueAsGuest() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final authService = AuthService();
    final user = await authService.signInAsGuest();

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      setState(() {
        error = 'Failed to sign in as guest.';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  // Future<void> loginWithGoogle() async {
  //   setState(() {
  //     isLoading = true;
  //     error = null;
  //   });

  //   final authService = AuthService();
  //   final user = await authService.signInWithGoogle();

  //   if (user != null) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const HomeScreen()),
  //     );
  //   } else {
  //     setState(() {
  //       error = 'Google sign-in failed.';
  //     });
  //   }

  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              SizedBox(height: 1.h),
              Text(
                'Login to continue',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 5.h),

              if (error != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Text(
                    error!,
                    style: GoogleFonts.openSans(
                      color: Colors.red,
                      fontSize: 12.sp,
                    ),
                  ),
                ),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 4.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Login",
                          style: GoogleFonts.openSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 2.h),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Register here",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              // Google Sign-In Button
              // Center(
              //   child: OutlinedButton.icon(
              //     icon: Image.asset(
              //       'assets/google_icon.png', // Make sure this icon exists
              //       height: 24,
              //       width: 24,
              //     ),
              //     label: Text("Sign in with Google"),
              //     onPressed: loginWithGoogle,
              //     style: OutlinedButton.styleFrom(
              //       padding:
              //           EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              //       side: BorderSide(color: Theme.of(context).primaryColor),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //     ),
              //   ),
              // ),
              // SizedBox(height: 2.h),

              // Guest Mode
              Center(
                child: TextButton(
                  onPressed: continueAsGuest,
                  child: Text(
                    "Continue as Guest",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
