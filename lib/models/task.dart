
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String? id;
  String projectId; // Changed from 'project' to reference the project ID
  String stage;
  String zone;
  String description;

  Task({
    this.id,
    required this.projectId,
    required this.stage,
    required this.zone,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'stage': stage,
      'zone': zone,
      'description': description,
    };
  }

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      projectId: data['projectId'] ?? '', // Updated to use projectId
      stage: data['stage'] ?? '',
      zone: data['zone'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
