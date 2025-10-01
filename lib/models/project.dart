
import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;
  final List<String> userIds;

  Project({required this.id, required this.name, required this.userIds});

  factory Project.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      name: data['name'] ?? '',
      userIds: List<String>.from(data['userIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'userIds': userIds,
    };
  }
}
