import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchedulerScreen extends StatefulWidget {
  const SchedulerScreen({Key? key}) : super(key: key);

  @override
  _SchedulerScreenState createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  final CollectionReference schedulesCollection =
      FirebaseFirestore.instance.collection('schedules');

  final TextEditingController _weekRangeController = TextEditingController();
  final TextEditingController _scriptureController = TextEditingController();
  final TextEditingController _firstSongController = TextEditingController();
  final TextEditingController _chairmanController = TextEditingController();
  final TextEditingController _openingPrayerController =
      TextEditingController();
  final TextEditingController _treasuresFirstController =
      TextEditingController();
  final TextEditingController _treasuresSecondController =
      TextEditingController();
  final TextEditingController _treasuresThirdController =
      TextEditingController();
  final TextEditingController _ministryFourthController =
      TextEditingController();
  final TextEditingController _ministryFifthController =
      TextEditingController();
  final TextEditingController _ministrySixthController =
      TextEditingController();
  final TextEditingController _ministrySeventhController =
      TextEditingController();
  final TextEditingController _ministryEighthController =
      TextEditingController();
  final TextEditingController _livingSecondSongController =
      TextEditingController();
  final TextEditingController _livingNinthController = TextEditingController();
  final TextEditingController _livingTenthController = TextEditingController();
  final TextEditingController _livingEleventhController =
      TextEditingController();
  final TextEditingController _livingTwelfthController =
      TextEditingController();
  final TextEditingController _concludingCommentsController =
      TextEditingController();
  final TextEditingController _thirdSongController = TextEditingController();
  final TextEditingController _closingPrayerController =
      TextEditingController();

  String? _selectedScheduleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Manager')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Shrink-wrap content
            children: [
              TextField(
                  controller: _weekRangeController,
                  decoration: const InputDecoration(
                      labelText: 'Week Range', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: _scriptureController,
                  decoration: const InputDecoration(
                      labelText: 'Scripture', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: _firstSongController,
                  decoration: const InputDecoration(
                      labelText: 'First Song', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: _chairmanController,
                  decoration: const InputDecoration(
                      labelText: 'Chairman', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: _openingPrayerController,
                  decoration: const InputDecoration(
                      labelText: 'Opening Prayer',
                      border: OutlineInputBorder())),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selectedScheduleId == null
                    ? _submitSchedule
                    : _updateSchedule,
                child: Text(_selectedScheduleId == null ? 'Submit' : 'Update'),
              ),
              ElevatedButton(
                  onPressed: _clearFields, child: const Text('Clear')),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: schedulesCollection
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No schedules found.',
                            style: TextStyle(fontSize: 18)));
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Fixes RenderFlex issue
                    physics:
                        const NeverScrollableScrollPhysics(), // Allows scrolling in parent
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        child: ListTile(
                          title: Text(data['weekRange'] ?? 'No Week Range'),
                          subtitle: Text(
                              '${data['scripture'] ?? 'No Scripture'} • Chairman: ${data['chairman'] ?? 'N/A'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    _selectedScheduleId =
                                        snapshot.data!.docs[index].id;
                                    _weekRangeController.text =
                                        data['weekRange'] ?? '';
                                    _scriptureController.text =
                                        data['scripture'] ?? '';
                                  });
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteConfirmationDialog(
                                    snapshot.data!.docs[index].id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitSchedule() async {
    await schedulesCollection.add({
      'weekRange': _weekRangeController.text.trim(),
      'scripture': _scriptureController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    _clearFields();
  }

  Future<void> _updateSchedule() async {
    if (_selectedScheduleId == null) return;
    await schedulesCollection.doc(_selectedScheduleId).update({
      'weekRange': _weekRangeController.text.trim(),
      'scripture': _scriptureController.text.trim(),
    });
    _clearFields();
  }

  void _clearFields() {
    _weekRangeController.clear();
    _scriptureController.clear();
    setState(() {
      _selectedScheduleId = null;
    });
  }

  void _showDeleteConfirmationDialog(String scheduleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _deleteSchedule(scheduleId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    await schedulesCollection.doc(scheduleId).delete();
  }
}
