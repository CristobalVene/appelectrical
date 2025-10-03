import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final CollectionReference _tasksCollection = FirebaseFirestore.instance.collection('tasks');

  Task? _editingTask;
  Task? get editingTask => _editingTask;

  final List<String> stages = [
    'Backlog',
    'To Do',
    'In Progress',
    'Done',
  ];

  // Stream to get all tasks for a specific project from Firestore
  Stream<List<Task>> getTasksForProject(String projectId) {
    return _tasksCollection
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    });
  }

  // Stream to get all tasks (could be used for an "All Tasks" view)
  Stream<List<Task>> getAllTasksStream() {
    return _tasksCollection.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    });
  }

  // Add a new task to Firestore
  Future<void> addTask(Task task) async {
    await _tasksCollection.add(task.toFirestore());
  }

  // Update an existing task in Firestore
  Future<void> updateTask(Task task) async {
    if (task.id.isEmpty) return; // Cannot update without an ID
    await _tasksCollection.doc(task.id).update(task.toFirestore());
  }

  // Update the stage of a specific task
  Future<void> updateTaskStage(String taskId, String newStage) async {
    await _tasksCollection.doc(taskId).update({'stage': newStage});
  }

  // Delete a task from Firestore
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  // Set the task to be edited
  void setEditingTask(Task? task) {
    _editingTask = task;
    notifyListeners();
  }
  
  // Clear the editing task state
  void clearEditingTask() {
    _editingTask = null;
    notifyListeners();
  }
}
