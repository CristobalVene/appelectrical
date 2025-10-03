import 'package:flutter/material.dart';
import '../models/project.dart';
import '../widgets/task_list.dart';
import '../widgets/task_form.dart';

class ProjectScreen extends StatelessWidget {
  final Project project;

  const ProjectScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TaskList(projectId: project.id),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) =>
                Dialog(child: TaskForm(projectId: project.id)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
