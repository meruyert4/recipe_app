import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// Мок для firebase_auth.User
class MockFirebaseUser extends Mock implements fb_auth.User {
  @override
  final String uid;
  @override
  final String? email;

  MockFirebaseUser({required this.uid, this.email});
}