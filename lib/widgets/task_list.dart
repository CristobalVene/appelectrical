import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../services/auth_service.dart';
import 'task_form.dart';

class TaskList extends StatelessWidget {
  final String? projectId;

  const TaskList({super.key, this.projectId});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final authService = context.watch<AuthService>();

    final String? currentUserId = authService.currentUserId;

    return StreamBuilder<List<Project>>(
      stream: projectProvider.getProjectsStream(),
      builder: (context, projectSnapshot) {
        if (projectSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!projectSnapshot.hasData || projectSnapshot.data!.isEmpty) {
          return const Center(child: Text("No projects found."));
        }

        final allProjects = projectSnapshot.data!;
        List<String> projectIdsToFilter;

        if (projectId != null) {
          projectIdsToFilter = [projectId!];
        } else {
          projectIdsToFilter = allProjects
              .where((p) => p.assignedUsers.contains(currentUserId))
              .map((p) => p.id)
              .toList();
        }

        if (projectIdsToFilter.isEmpty) {
          return const Center(
            child: Text("You are not assigned to any projects."),
          );
        }

        return StreamBuilder<List<Task>>(
          stream: taskProvider.getAllTasksStream(),
          builder: (context, taskSnapshot) {
            if (taskSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!taskSnapshot.hasData || taskSnapshot.data!.isEmpty) {
              return const Center(
                child: Text("No tasks found for your projects."),
              );
            }

            final filteredTasks = taskSnapshot.data!
                .where((task) => projectIdsToFilter.contains(task.projectId))
                .toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                final projectName = allProjects
                    .firstWhere(
                      (p) => p.id == task.projectId,
                      orElse: () =>
                          Project(id: '', name: 'Unknown', createdAt: DateTime.now()),
                    )
                    .name;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      projectName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${task.stage} - ${task.zone}\n${task.description}",
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_note,
                            color: Colors.orangeAccent,
                          ),
                          onPressed: () {
                            taskProvider.setEditingTask(task);
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                child: TaskForm(projectId: task.projectId),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => taskProvider.deleteTask(task.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
