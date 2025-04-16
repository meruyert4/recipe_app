import 'package:firebase_auth/firebase_auth.dart';

Future<User?> login(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  } on FirebaseAuthException catch (e) {
    print('Login error: ${e.message}');
    return null;
  }
}
