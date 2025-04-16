import 'package:firebase_auth/firebase_auth.dart';

Future<User?> register(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  } on FirebaseAuthException catch (e) {
    print('Registration error: ${e.message}');
    return null;
  }
}
