import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Email & Password Signup
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await _database.ref().child('users').child(user.uid).set({
          'email': email,
          'profileImage': '',
        });
      }

      return user;
    } catch (e) {
      print('Signup Error: $e');
      return null;
    }
  }

  // Email & Password Signin
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Signin Error: $e');
      return null;
    }
  }

  // Anonymous Guest Sign-in
  Future<User?> signInAsGuest() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;

      // Optional: Store guest user data
      if (user != null) {
        await _database.ref().child('users').child(user.uid).set({
          'isGuest': true,
          'profileImage': '',
        });
      }

      return user;
    } catch (e) {
      print('Guest Signin Error: $e');
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Google sign-in failed: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if current user is guest
  bool isGuest() {
    final user = _auth.currentUser;
    return user != null && user.isAnonymous;
  }
}
