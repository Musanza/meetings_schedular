import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meetings_scheduler/auth/users_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method for email and password login
  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Method for user registration
  Future<User?> registerUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Create a UsersModel instance
        UsersModel newUser = UsersModel(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoURL,
        );

        // Store user information in Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }

      return user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Method for Google Sign-In
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled sign-in
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Authenticate with Firebase
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Get the signed-in user's data
      User? user = userCredential.user;

      if (user != null) {
        // Check if user data already exists in Firestore
        final userDoc = _firestore.collection('users').doc(user.uid);
        final userSnapshot = await userDoc.get();

        if (!userSnapshot.exists) {
          // Add user data to Firestore
          await userDoc.set({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Navigate to HomeScreen
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print("Error during Google sign-in: $e");
      // Handle errors (e.g., show a message to the user)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Google Login Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
