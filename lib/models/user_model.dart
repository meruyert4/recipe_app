class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? status; // Optional user status (e.g., "active", "new user", etc.)

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.status,
  });

  // From Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      status: map['status'],
    );
  }

  // To Firestore document
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'status': status,
    };
  }
}
