import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meetings_scheduler/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _congregationNumberController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  String? _photoURL; // Profile photo URL

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Get the currently signed-in user
      final User? user = _auth.currentUser;

      if (user != null) {
        // Fetch user information from Firestore
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;

          setState(() {
            _nameController.text = userData['displayName'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _congregationNumberController.text =
                userData['congregationNumber'] ?? '';
            _phoneNumberController.text = userData['phoneNumber'] ?? '';
            _photoURL =
                userData['photoURL'] ?? ''; // Get the photoURL from the model
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Update'),
        content: const Text('Are you sure you want to update your profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close the dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _updateUserData(); // Update user data
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserData() async {
    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        Map<String, dynamic> updatedData = {
          'displayName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'congregationNumber': _congregationNumberController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
        };

        // Update user data in Firestore
        await _firestore.collection('users').doc(user.uid).update(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      print('Error updating user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Add logout confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Close dialog
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _auth.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[400],
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _photoURL != null && _photoURL!.isNotEmpty
                    ? NetworkImage(_photoURL!)
                    : const NetworkImage(
                        'https://via.placeholder.com/150'), // Placeholder if no image
                backgroundColor: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'User Profile Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _congregationNumberController,
              decoration: const InputDecoration(
                labelText: 'Congregation Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showUpdateDialog(context),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
