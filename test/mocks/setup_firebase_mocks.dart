import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

class FakeFirebaseApp extends FirebaseAppPlatform {
  FakeFirebaseApp({
    required String name,
    required FirebaseOptions options,
  }) : super(name, options);
}

class FakeFirebaseCore extends FirebasePlatform {
  static final FirebasePlatform _instance = FakeFirebaseCore._();

  FakeFirebaseCore._();

  static void registerWith() {
    FirebasePlatform.instance = _instance;
  }

  static const FirebaseOptions _defaultOptions = FirebaseOptions(
    apiKey: 'fake',
    appId: 'fake',
    messagingSenderId: 'fake',
    projectId: 'fake',
  );

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return FakeFirebaseApp(
      name: name ?? defaultFirebaseAppName,
      options: options ?? _defaultOptions,
    );
  }

  @override
  FirebaseAppPlatform app([String? name]) {
    return FakeFirebaseApp(
      name: name ?? defaultFirebaseAppName,
      options: _defaultOptions,
    );
  }

  @override
  List<FirebaseAppPlatform> get apps => [
        FakeFirebaseApp(
          name: defaultFirebaseAppName,
          options: _defaultOptions,
        )
      ];
}
