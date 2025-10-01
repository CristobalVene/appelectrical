
class User {
  final String id;
  final String email;
  final String name;

  User({required this.id, required this.email, required this.name});

  factory User.fromFirestore(Map<String, dynamic> firestore) {
    return User(
      id: firestore['id'],
      name: firestore['name'],
      email: firestore['email'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
