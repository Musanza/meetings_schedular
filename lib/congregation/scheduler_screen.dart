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
            mainAxisSize: MainAxisSize.min,
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
              const Text('Treasures from God’s Word',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                  controller: _treasuresFirstController,
                  decoration: const InputDecoration(
                      labelText: 'First Part', border: OutlineInputBorder())),
              TextField(
                  controller: _treasuresSecondController,
                  decoration: const InputDecoration(
                      labelText: 'Second Part', border: OutlineInputBorder())),
              TextField(
                  controller: _treasuresThirdController,
                  decoration: const InputDecoration(
                      labelText: 'Third Part', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              const Text('Apply Yourself to the Field Ministry',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                  controller: _ministryFourthController,
                  decoration: const InputDecoration(
                      labelText: 'Fourth Part', border: OutlineInputBorder())),
              TextField(
                  controller: _ministryFifthController,
                  decoration: const InputDecoration(
                      labelText: 'Fifth Part', border: OutlineInputBorder())),
              TextField(
                  controller: _ministrySixthController,
                  decoration: const InputDecoration(
                      labelText: 'Sixth Part', border: OutlineInputBorder())),
              TextField(
                  controller: _ministrySeventhController,
                  decoration: const InputDecoration(
                      labelText: 'Seventh Part', border: OutlineInputBorder())),
              TextField(
                  controller: _ministryEighthController,
                  decoration: const InputDecoration(
                      labelText: 'Eighth Part', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              const Text('Living as Christians',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                  controller: _livingSecondSongController,
                  decoration: const InputDecoration(
                      labelText: 'Second Song', border: OutlineInputBorder())),
              TextField(
                  controller: _livingNinthController,
                  decoration: const InputDecoration(
                      labelText: 'Ninth Part', border: OutlineInputBorder())),
              TextField(
                  controller: _livingTenthController,
                  decoration: const InputDecoration(
                      labelText: 'Tenth Part', border: OutlineInputBorder())),
              TextField(
                  controller: _livingEleventhController,
                  decoration: const InputDecoration(
                      labelText: 'Eleventh Part',
                      border: OutlineInputBorder())),
              TextField(
                  controller: _livingTwelfthController,
                  decoration: const InputDecoration(
                      labelText: 'Twelfth Part', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: _concludingCommentsController,
                  decoration: const InputDecoration(
                      labelText: 'Concluding Comments',
                      border: OutlineInputBorder())),
              TextField(
                  controller: _thirdSongController,
                  decoration: const InputDecoration(
                      labelText: 'Third Song', border: OutlineInputBorder())),
              TextField(
                  controller: _closingPrayerController,
                  decoration: const InputDecoration(
                      labelText: 'Closing Prayer',
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
                                    final data = snapshot.data!.docs[index]
                                        .data() as Map<String, dynamic>;

                                    // Populate basic fields
                                    _weekRangeController.text =
                                        data['weekRange'] ?? '';
                                    _scriptureController.text =
                                        data['scripture'] ?? '';
                                    _firstSongController.text =
                                        data['firstSong'] ?? '';
                                    _chairmanController.text =
                                        data['chairman'] ?? '';
                                    _openingPrayerController.text =
                                        data['openingPrayer'] ?? '';

                                    // Populate Treasures (Nested Map)
                                    final treasures = data['treasures']
                                            as Map<String, dynamic>? ??
                                        {};
                                    _treasuresFirstController.text =
                                        treasures['firstPart'] ?? '';
                                    _treasuresSecondController.text =
                                        treasures['secondPart'] ?? '';
                                    _treasuresThirdController.text =
                                        treasures['thirdPart'] ?? '';

                                    // Populate Field Ministry (Nested Map)
                                    final fieldMinistry = data['fieldMinistry']
                                            as Map<String, dynamic>? ??
                                        {};
                                    _ministryFourthController.text =
                                        fieldMinistry['fourthPart'] ?? '';
                                    _ministryFifthController.text =
                                        fieldMinistry['fifthPart'] ?? '';
                                    _ministrySixthController.text =
                                        fieldMinistry['sixthPart'] ?? '';
                                    _ministrySeventhController.text =
                                        fieldMinistry['seventhPart'] ?? '';
                                    _ministryEighthController.text =
                                        fieldMinistry['eighthPart'] ?? '';

                                    // Populate Living as Christians (Nested Map)
                                    final livingAsChristians =
                                        data['livingAsChristians']
                                                as Map<String, dynamic>? ??
                                            {};
                                    _livingSecondSongController.text =
                                        livingAsChristians['secondSong'] ?? '';
                                    _livingNinthController.text =
                                        livingAsChristians['ninthPart'] ?? '';
                                    _livingTenthController.text =
                                        livingAsChristians['tenthPart'] ?? '';
                                    _livingEleventhController.text =
                                        livingAsChristians['eleventhPart'] ??
                                            '';
                                    _livingTwelfthController.text =
                                        livingAsChristians['twelfthPart'] ?? '';

                                    // Populate Conclusion Fields
                                    _concludingCommentsController.text =
                                        data['concludingComments'] ?? '';
                                    _thirdSongController.text =
                                        data['thirdSong'] ?? '';
                                    _closingPrayerController.text =
                                        data['closingPrayer'] ?? '';
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
      'treasures': {
        'firstPart': _treasuresFirstController.text.trim(),
        'secondPart': _treasuresSecondController.text.trim(),
        'thirdPart': _treasuresThirdController.text.trim(),
      },
      'fieldMinistry': {
        'fourthPart': _ministryFourthController.text.trim(),
        'fifthPart': _ministryFifthController.text.trim(),
        'sixthPart': _ministrySixthController.text.trim(),
        'seventhPart': _ministrySeventhController.text.trim(),
        'eighthPart': _ministryEighthController.text.trim(),
      },
      'livingAsChristians': {
        'secondSong': _livingSecondSongController.text.trim(),
        'ninthPart': _livingNinthController.text.trim(),
        'tenthPart': _livingTenthController.text.trim(),
        'eleventhPart': _livingEleventhController.text.trim(),
        'twelfthPart': _livingTwelfthController.text.trim(),
      },
      'concludingComments': _concludingCommentsController.text.trim(),
      'thirdSong': _thirdSongController.text.trim(),
      'closingPrayer': _closingPrayerController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    _clearFields();
  }

  // Future<void> _updateSchedule() async {
  //   if (_selectedScheduleId == null) return;
  //   await schedulesCollection.doc(_selectedScheduleId).update({
  //     'weekRange': _weekRangeController.text.trim(),
  //     'scripture': _scriptureController.text.trim(),
  //   });
  //   _clearFields();
  // }

  Future<void> _updateSchedule() async {
    if (_selectedScheduleId == null) return;

    try {
      await schedulesCollection.doc(_selectedScheduleId).update({
        'weekRange': _weekRangeController.text.trim(),
        'scripture': _scriptureController.text.trim(),
        'firstSong': _firstSongController.text.trim(),
        'chairman': _chairmanController.text.trim(),
        'openingPrayer': _openingPrayerController.text.trim(),
        'treasures': {
          'firstPart': _treasuresFirstController.text.trim(),
          'secondPart': _treasuresSecondController.text.trim(),
          'thirdPart': _treasuresThirdController.text.trim(),
        },
        'fieldMinistry': {
          'fourthPart': _ministryFourthController.text.trim(),
          'fifthPart': _ministryFifthController.text.trim(),
          'sixthPart': _ministrySixthController.text.trim(),
          'seventhPart': _ministrySeventhController.text.trim(),
          'eighthPart': _ministryEighthController.text.trim(),
        },
        'livingAsChristians': {
          'secondSong': _livingSecondSongController.text.trim(),
          'ninthPart': _livingNinthController.text.trim(),
          'tenthPart': _livingTenthController.text.trim(),
          'eleventhPart': _livingEleventhController.text.trim(),
          'twelfthPart': _livingTwelfthController.text.trim(),
        },
        'concludingComments': _concludingCommentsController.text.trim(),
        'thirdSong': _thirdSongController.text.trim(),
        'closingPrayer': _closingPrayerController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule updated successfully!')));
      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update schedule: $e')));
    }
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
