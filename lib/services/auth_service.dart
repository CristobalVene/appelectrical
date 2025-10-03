import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    // 1. Create the user with Firebase Auth
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      // 2. Update the user's display name
      await user.updateDisplayName(name);
      await user.reload(); // Reload user to get the updated info

      // Define the user data to be stored
      final userData = {
        'uid': user.uid, // Storing uid is a good practice
        'name': name,
        'email': user.email,
        'photoUrl': user.photoURL ?? '',
      };

      // 3. Create a document for the user in the 'users' Firestore collection
      // This is the single, correct place to write user data.
      await _firestore.collection('users').doc(user.uid).set(userData);
    }

    return userCredential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
