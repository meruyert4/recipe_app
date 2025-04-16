class UserModel {
  final String uid;
  final String email;
  final String? name;

  UserModel({required this.uid, required this.email, this.name});

  factory UserModel.fromFirebaseUser(String uid, String email, {String? name}) {
    return UserModel(uid: uid, email: email, name: name);
  }
}
