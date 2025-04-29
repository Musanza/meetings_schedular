import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetings_scheduler/auth/profile_screen.dart';

class CongregationScreen extends StatefulWidget {
  const CongregationScreen({Key? key}) : super(key: key);

  @override
  _CongregationScreenState createState() => _CongregationScreenState();
}

class _CongregationScreenState extends State<CongregationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _congregationNumberController =
      TextEditingController();
  final TextEditingController _congregationNameController =
      TextEditingController();
  final TextEditingController _coordinatorController = TextEditingController();
  final TextEditingController _secretaryController = TextEditingController();
  final TextEditingController _serviceOverseerController =
      TextEditingController();
  final TextEditingController _lifeMinistryOverseerController =
      TextEditingController();

  bool _isLoading = true; // Loading indicator
  String? _congregationDocId; // Store document ID for update

  @override
  void initState() {
    super.initState();
    _loadCongregationData();
  }

  Future<void> _loadCongregationData() async {
    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        // Fetch the user's data to get their congregation number
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final String userCongregationNumber = userDoc['congregationNumber'];

          // Fetch the congregation data that matches the congregation number
          final QuerySnapshot congregationSnapshot = await _firestore
              .collection('congregations')
              .where('congregationNumber', isEqualTo: userCongregationNumber)
              .get();

          if (congregationSnapshot.docs.isNotEmpty) {
            final DocumentSnapshot congregationDoc =
                congregationSnapshot.docs.first;
            final Map<String, dynamic> congregationData =
                congregationDoc.data() as Map<String, dynamic>;

            setState(() {
              _congregationDocId =
                  congregationDoc.id; // Store document ID for updating
              _congregationNumberController.text =
                  congregationData['congregationNumber'] ?? '';
              _congregationNameController.text =
                  congregationData['congregationName'] ?? '';
              _coordinatorController.text =
                  congregationData['coordinator'] ?? '';
              _secretaryController.text = congregationData['secretary'] ?? '';
              _serviceOverseerController.text =
                  congregationData['serviceOverseer'] ?? '';
              _lifeMinistryOverseerController.text =
                  congregationData['lifeMinistryOverseer'] ?? '';
              _isLoading = false; // Data loading completed
            });
          } else {
            setState(() {
              _congregationDocId = null; // No match found
              _isLoading = false; // Data loading completed
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching congregation data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $e')),
      );
      setState(() {
        _isLoading = false; // Stop loading if there's an error
      });
    }
  }

  Future<void> _addCongregationData() async {
    try {
      Map<String, dynamic> newCongregationData = {
        'congregationNumber': _congregationNumberController.text.trim(),
        'congregationName': _congregationNameController.text.trim(),
        'coordinator': _coordinatorController.text.trim(),
        'secretary': _secretaryController.text.trim(),
        'serviceOverseer': _serviceOverseerController.text.trim(),
        'lifeMinistryOverseer': _lifeMinistryOverseerController.text.trim(),
      };

      // Add new congregation to Firestore
      await _firestore.collection('congregations').add(newCongregationData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Congregation added successfully!')),
      );
    } catch (e) {
      print('Error adding congregation data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add data: $e')),
      );
    }
  }

  Future<void> _updateCongregationData() async {
    try {
      if (_congregationDocId != null) {
        Map<String, dynamic> updatedData = {
          'congregationNumber': _congregationNumberController.text.trim(),
          'congregationName': _congregationNameController.text.trim(),
          'coordinator': _coordinatorController.text.trim(),
          'secretary': _secretaryController.text.trim(),
          'serviceOverseer': _serviceOverseerController.text.trim(),
          'lifeMinistryOverseer': _lifeMinistryOverseerController.text.trim(),
        };

        // Update Firestore document
        await _firestore
            .collection('congregations')
            .doc(_congregationDocId)
            .update(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Congregation updated successfully!')),
        );
      }
    } catch (e) {
      print('Error updating congregation data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Enable back button
        title: const Text(
          'Congregation Details',
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Congregation Details',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _congregationNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Congregation Number',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true, // Read-only as this is unique
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _congregationNameController,
                      decoration: const InputDecoration(
                        labelText: 'Congregation Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _coordinatorController,
                      decoration: const InputDecoration(
                        labelText: 'Coordinator',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _secretaryController,
                      decoration: const InputDecoration(
                        labelText: 'Secretary',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _serviceOverseerController,
                      decoration: const InputDecoration(
                        labelText: 'Service Overseer',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _lifeMinistryOverseerController,
                      decoration: const InputDecoration(
                        labelText: 'Life Ministry Overseer',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _congregationDocId == null
                        ? ElevatedButton(
                            onPressed: _addCongregationData,
                            child: const Text('Add'),
                          )
                        : ElevatedButton(
                            onPressed: _updateCongregationData,
                            child: const Text('Update'),
                          ),
                  ],
                ),
              ),
      ),
    );
  }
}
