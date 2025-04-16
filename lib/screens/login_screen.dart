import 'package:flutter/material.dart';
import '../viewmodels/auth_view_model.dart';
import '../widgets/custom_textfield.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthViewModel _auth = AuthViewModel();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(controller: emailController, hint: 'Email'),
            SizedBox(height: 10),
            CustomTextField(controller: passwordController, hint: 'Password', isPassword: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _auth.signInUser(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
              },
              child: Text("Login"),
            )
          ],
        ),
      ),
    );
  }
}
