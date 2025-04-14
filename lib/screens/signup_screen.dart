import 'package:flutter/material.dart';
import '../viewmodels/auth_view_model.dart';
import '../widgets/custom_textfield.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthViewModel _auth = AuthViewModel();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(controller: nameController, hint: 'Name'),
            SizedBox(height: 10),
            CustomTextField(controller: emailController, hint: 'Email'),
            SizedBox(height: 10),
            CustomTextField(controller: passwordController, hint: 'Password', isPassword: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _auth.signUpUser(
                  nameController.text.trim(),
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
              },
              child: Text("Sign Up"),
            )
          ],
        ),
      ),
    );
  }
}
