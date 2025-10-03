import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final List<String> assignedUsers;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    this.description = '',
    this.assignedUsers = const [],
    required this.createdAt,
  });

  // Factory constructor to create a Project from a Firestore document
  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Project',
      description: data['description'] ?? '',
      // Ensure assignedUsers is a list of strings
      assignedUsers: List<String>.from(data['assignedUsers'] ?? []),
      // Convert Firestore Timestamp to DateTime
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Method to convert a Project object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'assignedUsers': assignedUsers,
      // Convert DateTime to Firestore Timestamp
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
