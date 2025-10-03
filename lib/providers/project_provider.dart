import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';

class ProjectProvider with ChangeNotifier {
  // Reference to the 'projects' collection in Cloud Firestore
  final CollectionReference _projectsCollection = FirebaseFirestore.instance.collection('projects');

  // Stream to get all projects from Firestore
  Stream<List<Project>> getProjectsStream() {
    return _projectsCollection
        .orderBy('createdAt', descending: true) // Order by creation date
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList();
    });
  }

  // Add a new project to Firestore
  Future<void> addProject(String name, String description, List<String> assignedUsers) async {
    final newProject = Project(
      id: '', // Firestore generates the ID
      name: name,
      description: description,
      assignedUsers: assignedUsers,
      createdAt: DateTime.now(),
    );
    await _projectsCollection.add(newProject.toFirestore());
  }

  // Update an existing project in Firestore
  Future<void> updateProject(String projectId, String name, String description) async {
    await _projectsCollection.doc(projectId).update({
      'name': name,
      'description': description,
    });
  }

  // Delete a project from Firestore
  Future<void> deleteProject(String projectId) async {
    await _projectsCollection.doc(projectId).delete();
  }

  // Assign a user to a project using Firestore's arrayUnion
  Future<void> assignUserToProject(String projectId, String userId) async {
    await _projectsCollection.doc(projectId).update({
      'assignedUsers': FieldValue.arrayUnion([userId]),
    });
  }

  // Remove a user from a project using Firestore's arrayRemove
  Future<void> removeUserFromProject(String projectId, String userId) async {
    await _projectsCollection.doc(projectId).update({
      'assignedUsers': FieldValue.arrayRemove([userId]),
    });
  }
}
