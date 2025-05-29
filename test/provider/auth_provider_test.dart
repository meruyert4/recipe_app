import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/provider/provider.dart';
import 'package:recipe_app/models/user_model.dart';
import '../mocks/firebase_mocks.dart';


void main() {
  late AuthProvider authProvider;

  setUp(() {
    authProvider = AuthProvider();
  });

  group('AuthProvider Tests', () {
    test('Initial state is null', () {
      expect(authProvider.user, isNull);
    });

    group('setUser', () {
      test('sets user correctly when FirebaseUser is provided', () {
        final mockFirebaseUser = MockFirebaseUser(uid: '123', email: 'test@example.com');
        var listenerCalled = false;
        authProvider.addListener(() {
          listenerCalled = true;
        });

        authProvider.setUser(mockFirebaseUser);

        expect(authProvider.user, isA<UserModel>());
        expect(authProvider.user?.uid, '123');
        expect(authProvider.user?.email, 'test@example.com');
        expect(listenerCalled, isTrue);
      });

      test('sets user to null when FirebaseUser is null', () {
        final mockFirebaseUser = MockFirebaseUser(uid: '123', email: 'test@example.com');
        authProvider.setUser(mockFirebaseUser);
        expect(authProvider.user, isNotNull);

        var listenerCalled = false;
        authProvider.addListener(() {
          listenerCalled = true;
        });

        authProvider.setUser(null);

        expect(authProvider.user, isNull);
        expect(listenerCalled, isTrue);
      });

      test('handles null email from FirebaseUser by setting it to empty string in UserModel', () {
        final mockFirebaseUser = MockFirebaseUser(uid: '456', email: null);
         var listenerCalled = false;
        authProvider.addListener(() {
          listenerCalled = true;
        });

        authProvider.setUser(mockFirebaseUser);

        expect(authProvider.user, isA<UserModel>());
        expect(authProvider.user?.uid, '456');
        expect(authProvider.user?.email, '');
        expect(listenerCalled, isTrue);
      });
    });
  });
}