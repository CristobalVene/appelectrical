import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../models/project.dart';
import '../models/task.dart';
import 'edit_project_screen.dart';

class ManageProjectsScreen extends StatelessWidget {
  const ManageProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Proyectos')),
      body: StreamBuilder<List<Project>>(
        stream: projectProvider.getProjectsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final projects = snapshot.data!;

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return _ProjectExpansionTile(project: project);
            },
          );
        },
      ),
    );
  }
}

class _ProjectExpansionTile extends StatelessWidget {
  final Project project;

  const _ProjectExpansionTile({required this.project});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return ExpansionTile(
      title: Text(
        project.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProjectScreen(project: project),
            ),
          );
        },
      ),
      children: [
        StreamBuilder<List<Task>>(
          stream: taskProvider.getTasksForProject(project.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const ListTile(title: Text('Cargando Tareas...'));
            }
            final tasks = snapshot.data!;
            if (tasks.isEmpty) {
              return const ListTile(
                title: Text('No existen tareas asociadas a este proyecto.'),
              );
            }
            return Column(
              children: tasks.map((task) {
                return ListTile(
                  title: Text(task.description),
                  subtitle: Text('${task.stage} - ${task.zone}'),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
