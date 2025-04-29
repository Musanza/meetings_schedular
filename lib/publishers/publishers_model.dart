class PublishersModel {
  final String name; // Publisher's name
  final String status; // Publisher's status (e.g., active, inactive)
  final String gender; // Publisher's gender (e.g., male, female)
  final String phoneNumber; // Publisher's phone number
  final DateTime lastAssignment; // Publisher's last assignment date
  final List<String>
      privileges; // Publisher's privileges (e.g., elder, pioneer, etc.)
  final String congregationNumber;

  PublishersModel({
    required this.name,
    required this.status,
    required this.gender,
    required this.phoneNumber,
    required this.lastAssignment,
    required this.privileges,
    required this.congregationNumber,
  });

  // Convert PublishersModel to a Map (for Firestore or other databases)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'lastAssignment':
          lastAssignment.toIso8601String(), // Convert DateTime to String
      'privileges': privileges,
      'congregationNumber': congregationNumber,
    };
  }

  // Create PublishersModel from a Map
  factory PublishersModel.fromMap(Map<String, dynamic> map) {
    return PublishersModel(
      name: map['name'] ?? '',
      status: map['status'] ?? '',
      gender: map['gender'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      congregationNumber: map['congregationNumber'] ?? '',
      lastAssignment:
          DateTime.parse(map['lastAssignment']), // Parse String to DateTime
      privileges: List<String>.from(
          map['privileges'] ?? []), // Parse List of privileges
    );
  }
}
