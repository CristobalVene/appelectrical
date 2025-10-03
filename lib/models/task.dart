import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  final String projectId;
  final String stage;
  final String zone;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task({
    this.id = '',
    required this.projectId,
    required this.stage,
    required this.zone,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  // Factory constructor to create a Task from a Firestore DocumentSnapshot
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      stage: data['stage'] ?? 'Backlog',
      zone: data['zone'] ?? '',
      description: data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      // Convert Firestore Timestamp to DateTime
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Method to convert a Task object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'stage': stage,
      'zone': zone,
      'description': description,
      'isCompleted': isCompleted,
      // Convert DateTime to Firestore Timestamp
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
