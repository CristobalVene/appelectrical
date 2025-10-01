
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'tasks';
  Task? _editingTask;

  Task? get editingTask => _editingTask;

  final List<String> stages = [
    "Before concrete", "After concrete", "Before plaster", "After plaster",
    "First layer partitions", "Second layer partitions", "Wiring", "Devices",
    "Main supply", "Panels", "Functionality",
  ];

  Stream<List<Task>> getTasksStream() {
    return _firestore.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    });
  }

  // New method to get tasks for a specific project
  Stream<List<Task>> getTasksForProject(String projectId) {
    return _firestore
        .collection(_collectionPath)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    });
  }

  Future<void> saveTask({
    required String projectId,
    required String stage,
    required String zone,
    required String description,
  }) async {
    if (projectId.isEmpty || stage.isEmpty || zone.isEmpty || description.isEmpty) {
      return;
    }

    final task = Task(
      projectId: projectId,
      stage: stage,
      zone: zone,
      description: description,
    );

    if (_editingTask == null) {
      await _firestore.collection(_collectionPath).add(task.toMap());
    } else {
      await _firestore.collection(_collectionPath).doc(_editingTask!.id).update(task.toMap());
      _editingTask = null;
    }
    notifyListeners();
  }

  void setEditingTask(Task? task) {
    _editingTask = task;
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _firestore.collection(_collectionPath).doc(id).delete();
  }
}
