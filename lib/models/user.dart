import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;

  User({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl = '',
  });

  // Factory constructor to create a User from a Firestore DocumentSnapshot
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id, // The document ID is the user's UID
      name: data['name'] ?? 'No Name',
      email: data['email'] ?? 'No Email',
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  // Method to convert a User object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      // 'uid' is not included here because it's used as the document ID
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}
