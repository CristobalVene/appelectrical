import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');

  // Stream to get all users from Firestore
  Stream<List<User>> getUsersStream() {
    return _usersCollection.snapshots().map((snapshot) {
      try {
        if (snapshot.docs.isEmpty) {
          return [];
        }
        // Convert each DocumentSnapshot into a User object
        return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
      } catch (e) {
        // It's good practice to log the error
        print('Error mapping users from Firestore: $e');
        return []; // Return an empty list on error
      }
    });
  }
}
