import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  bool isReceptionist() {
    final user = getCurrentUser();
    if (user != null && user.email != null) {
      return user.email!.endsWith('@reception.com');
    }
    return false;
  }

  //sign in
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      bool isReceptionUser = email.endsWith('@reception.com');
      if (isReceptionUser) {
        await _firestore
            .collection("receptions")
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'email': email,
        }, SetOptions(merge: true));
      } else {
        _firestore.collection("Users").doc(userCredential.user!.uid).set(
          {
            'uid': userCredential.user!.uid,
            'email': email,
          },
          SetOptions(merge: true),
        );
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //sign up
  Future<UserCredential> signUpWithEmailPassword(String email, password) async {
    try {
      //sign user in
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      bool isReceptionUser = email.endsWith('@reception.com');

      if (isReceptionUser) {
        await _firestore
            .collection("receptions")
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'email': email,
        });
      } else {
        _firestore.collection("Users").doc(userCredential.user!.uid).set(
          {
            'uid': userCredential.user!.uid,
            'email': email,
          },
        );
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("User signed out successfully");
    } catch (e) {
      print("Error signing out: $e");
      // Re-throw the exception to be handled by the calling code
      throw Exception("Failed to sign out: $e");
    }
  }

  // Get user data based on type
  Future<DocumentSnapshot?> getUserData() async {
    final user = getCurrentUser();

    if (user != null) {
      if (isReceptionist()) {
        return await _firestore.collection("receptions").doc(user.uid).get();
      } else {
        return await _firestore.collection("Users").doc(user.uid).get();
      }
    }
    return null;
  }
}