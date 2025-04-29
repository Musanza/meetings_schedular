import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetings_scheduler/publishers/publisher_service.dart';
import 'package:meetings_scheduler/publishers/publishers_model.dart';

class AddPublisherScreen extends StatefulWidget {
  final Map<String, dynamic>? publisherData;
  final String? publisherId;

  const AddPublisherScreen({Key? key, this.publisherData, this.publisherId})
      : super(key: key);

  @override
  _AddPublisherScreenState createState() => _AddPublisherScreenState();
}

class _AddPublisherScreenState extends State<AddPublisherScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _lastAssignmentController =
      TextEditingController();
  final TextEditingController _congregationNumberController =
      TextEditingController();

  String _selectedStatus = 'Single';
  String _selectedGender = 'Male';

  final List<String> _privileges = [
    'Elder',
    'Coordinator',
    'Secretary',
    'Life and Ministry Overseer',
    'Service Overseer',
    'Regular Pioneer',
    'Auxiliary Pioneer',
    'Publisher',
    'Unbaptized Publisher',
  ];
  final List<String> _selectedPrivileges = [];

  @override
  void initState() {
    super.initState();

    // Fetch congregation number and check if name exists in Firestore
    _fetchUserDetails();

    if (widget.publisherData != null) {
      _nameController.text = widget.publisherData!['name'] ?? '';
      _selectedStatus = widget.publisherData!['status'] ?? 'Single';
      _selectedGender = widget.publisherData!['gender'] ?? 'Male';
      _phoneNumberController.text = widget.publisherData!['phoneNumber'] ?? '';
      _lastAssignmentController.text =
          widget.publisherData!['lastAssignment'] ??
              DateTime.now().toIso8601String();
      _selectedPrivileges
          .addAll(List<String>.from(widget.publisherData!['privileges'] ?? []));
    }
  }

// Fetch congregation number & check name existence in Firestore
  Future<void> _fetchUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final String? congregationNumber = userDoc['congregationNumber'];
          final String? userName = userDoc['displayName'];

          if (congregationNumber != null) {
            setState(() {
              _congregationNumberController.text = congregationNumber;
            });

            // Check if the name & congregation number exist in publishers collection
            final QuerySnapshot query = await FirebaseFirestore.instance
                .collection('publishers')
                .where('name', isEqualTo: userName)
                .where('congregationNumber', isEqualTo: congregationNumber)
                .get();

            if (query.docs.isEmpty && userName != null) {
              setState(() {
                _nameController.text = userName;
              });
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user details: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Publisher Details',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Name', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              TextField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                      labelText: 'Phone Number', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              TextField(
                  controller: _congregationNumberController,
                  decoration: const InputDecoration(
                      labelText: 'Congregation Number',
                      border: OutlineInputBorder()),
                  readOnly: false),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: RadioListTile(
                          title: const Text('Married'),
                          value: 'Married',
                          groupValue: _selectedStatus,
                          onChanged: (value) =>
                              setState(() => _selectedStatus = value!))),
                  Expanded(
                      child: RadioListTile(
                          title: const Text('Single'),
                          value: 'Single',
                          groupValue: _selectedStatus,
                          onChanged: (value) =>
                              setState(() => _selectedStatus = value!))),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: RadioListTile(
                          title: const Text('Male'),
                          value: 'Male',
                          groupValue: _selectedGender,
                          onChanged: (value) =>
                              setState(() => _selectedGender = value!))),
                  Expanded(
                      child: RadioListTile(
                          title: const Text('Female'),
                          value: 'Female',
                          groupValue: _selectedGender,
                          onChanged: (value) =>
                              setState(() => _selectedGender = value!))),
                ],
              ),
              Column(
                  children: _privileges.map((privilege) {
                return CheckboxListTile(
                  title: Text(privilege),
                  value: _selectedPrivileges.contains(privilege),
                  onChanged: (bool? value) {
                    setState(() {
                      value == true
                          ? _selectedPrivileges.add(privilege)
                          : _selectedPrivileges.remove(privilege);
                    });
                  },
                );
              }).toList()),
              const SizedBox(height: 20),
              widget.publisherId == null
                  ? ElevatedButton(
                      onPressed: () => PublisherService().addPublisher(
                        context,
                        PublishersModel(
                          name: _nameController.text.trim(),
                          status: _selectedStatus,
                          gender: _selectedGender,
                          phoneNumber: _phoneNumberController.text.trim(),
                          lastAssignment: DateTime.now(),
                          privileges: _selectedPrivileges,
                          congregationNumber:
                              _congregationNumberController.text.trim(),
                        ),
                      ),
                      child: const Text('Save Publisher'),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => PublisherService().updatePublisher(
                            context,
                            widget.publisherId!,
                            {
                              'name': _nameController.text.trim(),
                              'status': _selectedStatus,
                              'gender': _selectedGender,
                              'phoneNumber': _phoneNumberController.text.trim(),
                              'lastAssignment':
                                  _lastAssignmentController.text.trim(),
                              'privileges': _selectedPrivileges,
                              'congregationNumber':
                                  _congregationNumberController.text.trim(),
                            },
                          ),
                          child: const Text('Update'),
                        ),
                        ElevatedButton(
                          onPressed: () => PublisherService()
                              .deletePublisher(context, widget.publisherId!),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
