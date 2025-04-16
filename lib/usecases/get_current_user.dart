import 'package:firebase_auth/firebase_auth.dart';

User? getCurrentUser() {
  return FirebaseAuth.instance.currentUser;
}
