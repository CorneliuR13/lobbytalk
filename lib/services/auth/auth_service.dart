import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  // Add this method for Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Begin the interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If the user cancels the sign-in flow
      if (googleUser == null) {
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Save user data in Firestore
      // Note: Google accounts won't be receptionists, so always save in Users collection
      await _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName,
          'photoURL': userCredential.user!.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  //sign out
  Future<void> signOut() async {
    try {
      // Sign out of Google if signed in with Google
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print("Google sign out failed: $e");
        // Continue with Firebase signout even if Google signout fails
      }

      await _auth.signOut();
      print("User signed out successfully");
    } catch (e) {
      print("Error signing out: $e");
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