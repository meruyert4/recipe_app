import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    // Тест конструктора и свойств
    test('UserModel object should be created with correct properties (with name)', () {
      final user = UserModel(
        uid: '123xyz',
        email: 'test@example.com',
        name: 'Test User',
      );

      expect(user.uid, '123xyz');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
    });

    test('UserModel object should be created with correct properties (without name)', () {
      final user = UserModel(
        uid: '456abc',
        email: 'another@example.com',
      );

      expect(user.uid, '456abc');
      expect(user.email, 'another@example.com');
      expect(user.name, isNull);
    });

    // Тест factory UserModel.fromFirebaseUser
    test('UserModel.fromFirebaseUser should create UserModel correctly', () {
      final userWithName = UserModel.fromFirebaseUser('fbUid1', 'firebase@example.com', name: 'Firebase User');
      expect(userWithName.uid, 'fbUid1');
      expect(userWithName.email, 'firebase@example.com');
      expect(userWithName.name, 'Firebase User');

      final userWithoutName = UserModel.fromFirebaseUser('fbUid2', 'firebase2@example.com');
      expect(userWithoutName.uid, 'fbUid2');
      expect(userWithoutName.email, 'firebase2@example.com');
      expect(userWithoutName.name, isNull);
    });

    // Тест метода toJson
    test('toJson should return correct Map representation', () {
      final userWithName = UserModel(
        uid: 'jsonUid1',
        email: 'json@example.com',
        name: 'Json User',
      );
      final expectedJsonWithName = {
        'uid': 'jsonUid1',
        'email': 'json@example.com',
        'name': 'Json User',
      };
      expect(userWithName.toJson(), equals(expectedJsonWithName));

      final userWithoutName = UserModel(
        uid: 'jsonUid2',
        email: 'json2@example.com',
      );
      final expectedJsonWithoutName = {
        'uid': 'jsonUid2',
        'email': 'json2@example.com',
        'name': null, // или может отсутствовать, в зависимости от того, как вы хотите обрабатывать null в toJson
      };
      expect(userWithoutName.toJson(), equals(expectedJsonWithoutName));
    });
  });
}