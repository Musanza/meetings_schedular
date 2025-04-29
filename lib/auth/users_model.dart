import 'package:firebase_auth/firebase_auth.dart';

class UsersModel {
  final String uid; // Unique User ID (Firebase assigns this)
  final String? email; // User's email
  final String? displayName; // User's display name
  final String? photoURL; // URL to the user's profile photo
  final String? congregationNumber; // User's congregation number
  final String? phoneNumber;

  UsersModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.congregationNumber, // New field for congregation number
    this.phoneNumber,
  });

  // Convert UsersModel to a Map (for Firestore or Realtime Database)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'congregationNumber': congregationNumber, // Added to the map
      'phoneNumber': phoneNumber,
    };
  }

  // Create UsersModel from a Map
  factory UsersModel.fromMap(Map<String, dynamic> map) {
    return UsersModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      congregationNumber: map['congregationNumber'], // Added here
      phoneNumber: map['phoneNumber'],
    );
  }

  // Create UsersModel from a Firebase User (FirebaseAuth instance)
  factory UsersModel.fromFirebaseUser(User user,
      {String? congregationNumber, String? phoneNumber}) {
    return UsersModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      congregationNumber: congregationNumber, // Optional congregation number
      phoneNumber: phoneNumber,
    );
  }
}
