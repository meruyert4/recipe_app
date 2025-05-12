import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _database.ref().child('users/${userCredential.user?.uid}').once();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Signin Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected Signin Error: $e');
      rethrow;
    }
  }

  Future<User?> signInAsGuest() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;

      if (user != null) {
        await _database.ref().child('users/${user.uid}').set({
          'isGuest': true,
          'profileImage': '',
          'createdAt': ServerValue.timestamp,
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print('Guest Signin Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected Guest Signin Error: $e');
      rethrow;
    }
  }
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Signout Error: $e');
      rethrow;
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  bool isGuest() {
    final user = _auth.currentUser;
    return user != null && user.isAnonymous;
  }
}