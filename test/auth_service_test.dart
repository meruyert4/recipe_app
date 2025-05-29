import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  group('MockFirebaseAuth tests', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    test('getCurrentUser returns null when no user is signed in', () {
      final user = mockAuth.currentUser;
      expect(user, isNull);
    });

    test('isGuest returns false when no user is signed in', () {
      final isGuest = mockAuth.currentUser?.isAnonymous ?? false;
      expect(isGuest, isFalse);
    });

    test('signInAnonymously sets isAnonymous to true', () async {
      final userCred = await mockAuth.signInAnonymously();
      final user = userCred.user;
      expect(user, isNotNull);
      expect(user?.isAnonymous, isTrue);
    });
  });
}
