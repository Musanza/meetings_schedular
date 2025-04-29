import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetings_scheduler/auth/login_screen.dart';
import 'package:meetings_scheduler/auth/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication(); // Check authentication when HomeScreen initializes
  }

  void _checkAuthentication() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Navigate to LoginScreen if the user is not authenticated
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: const Text(
          'Meetings Scheduler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              ),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Loading state
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[400], // Medium grey background
                      ),
                      padding:
                          const EdgeInsets.all(8.0), // Padding around the icon
                      child: const Icon(
                        Icons.person, // Default icon when no photo is available
                        color: Colors.white,
                        size: 24.0,
                      ),
                    );
                  }
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final photoURL = userData['photoURL'];
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[400], // Medium grey background
                    ),
                    padding:
                        const EdgeInsets.all(2.0), // Padding around the avatar
                    child: CircleAvatar(
                      radius: 20, // Profile photo size
                      backgroundImage: photoURL != null && photoURL.isNotEmpty
                          ? NetworkImage(photoURL)
                          : null, // Null if no photoURL is available
                      child: const Icon(
                        Icons
                            .person, // Icon shown inside CircleAvatar as fallback
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to the Home Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
