
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';

class TaskForm extends StatefulWidget {
  final String? projectId;
  const TaskForm({super.key, this.projectId});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _zoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedProjectId;
  String? _selectedStage;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.projectId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final taskProvider = context.read<TaskProvider>();
    if (taskProvider.editingTask != null) {
      final task = taskProvider.editingTask!;
      _selectedProjectId = task.projectId;
      _zoneController.text = task.zone;
      _descriptionController.text = task.description;
      _selectedStage = task.stage;
    } else if (widget.projectId == null) {
      _clearForm();
    }
  }

  void _clearForm() {
    _selectedProjectId = null;
    _zoneController.clear();
    _descriptionController.clear();
    _selectedStage = null;
  }

  void _submitForm() {
    if (_selectedProjectId == null || _selectedStage == null) return;

    context.read<TaskProvider>().saveTask(
          projectId: _selectedProjectId!,
          stage: _selectedStage!,
          zone: _zoneController.text,
          description: _descriptionController.text,
        );
    setState(() {
      _clearForm();
      context.read<TaskProvider>().setEditingTask(null);
    });
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final projectProvider = context.watch<ProjectProvider>();

    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Theme.of(context).cardColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(taskProvider.editingTask == null ? "Add New Task" : "Edit Task", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          StreamBuilder<List<Project>>(
            stream: projectProvider.getProjectsStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              return DropdownButtonFormField<String>(
                initialValue: _selectedProjectId,
                items: snapshot.data!.map((project) {
                  return DropdownMenuItem(value: project.id, child: Text(project.name));
                }).toList(),
                onChanged: widget.projectId != null ? null : (value) => setState(() => _selectedProjectId = value),
                decoration: const InputDecoration(labelText: "Project"),
              );
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedStage,
            items: taskProvider.stages.map((stage) {
              return DropdownMenuItem(value: stage, child: Text(stage));
            }).toList(),
            onChanged: (value) => setState(() => _selectedStage = value),
            decoration: const InputDecoration(labelText: "Stage"),
          ),
          const SizedBox(height: 12),
          TextField(controller: _zoneController, decoration: const InputDecoration(labelText: "Zone")),
          const SizedBox(height: 12),
          TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: "Task Description")),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
            child: Text(taskProvider.editingTask == null ? "Add Task" : "Update Task"),
          ),
          if (taskProvider.editingTask != null) TextButton(onPressed: () => taskProvider.setEditingTask(null), child: const Text("Cancel Edit"))
        ],
      ),
    );
  }
}
