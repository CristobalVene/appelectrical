
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';

class ProjectProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'projects';

  Stream<List<Project>> getProjectsStream() {
    return _firestore.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList();
    });
  }

  Future<void> createProject(String name, List<String> userIds) async {
    if (name.isEmpty) return;

    final newProject = {
      'name': name,
      'userIds': userIds,
    };

    await _firestore.collection(_collectionPath).add(newProject);
  }

  Future<void> updateProject(Project project) async {
    await _firestore.collection(_collectionPath).doc(project.id).update(project.toFirestore());
  }
}
