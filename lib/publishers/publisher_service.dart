import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetings_scheduler/publishers/publishers_model.dart';
import 'package:meetings_scheduler/publishers/publishers_screen.dart';

class PublisherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Show Confirmation Dialog before performing actions
  Future<void> _showConfirmationDialog(
      BuildContext context, String action, VoidCallback onConfirm) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Publisher'),
        content: Text('Are you sure you want to $action this publisher?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // Add a new publisher
  Future<void> addPublisher(
      BuildContext context, PublishersModel publisher) async {
    _showConfirmationDialog(context, 'Add', () async {
      try {
        final QuerySnapshot query = await _firestore
            .collection('publishers')
            .where('name', isEqualTo: publisher.name)
            .where('congregationNumber',
                isEqualTo: publisher.congregationNumber)
            .get();

        if (query.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'A publisher with this name and congregation number already exists!')),
          );
          return;
        }

        await _firestore.collection('publishers').add(publisher.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publisher added successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PublishersScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add publisher: $e')),
        );
      }
    });
  }

  // Update an existing publisher
  Future<void> updatePublisher(BuildContext context, String publisherId,
      Map<String, dynamic> updatedData) async {
    _showConfirmationDialog(context, 'Update', () async {
      try {
        await _firestore
            .collection('publishers')
            .doc(publisherId)
            .update(updatedData);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publisher updated successfully!')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update publisher: $e')));
      }
    });
  }

  // Delete a publisher
  Future<void> deletePublisher(BuildContext context, String publisherId) async {
    _showConfirmationDialog(context, 'Delete', () async {
      try {
        await _firestore.collection('publishers').doc(publisherId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publisher deleted successfully!')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete publisher: $e')));
      }
    });
  }
}
