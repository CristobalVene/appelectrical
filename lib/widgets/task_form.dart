import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
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
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.projectId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final editingTask = context.watch<TaskProvider>().editingTask;
      if (editingTask != null) {
        _selectedProjectId = editingTask.projectId;
        _zoneController.text = editingTask.zone;
        _descriptionController.text = editingTask.description;
        _selectedStage = editingTask.stage;
      }
    }
    _isInit = false;
  }

  Future<void> _submitForm() async {
    if (_selectedProjectId == null ||
        _selectedStage == null ||
        _descriptionController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Por favor, complete todos los campos obligatorios: proyecto, estado y descripción.')),
        );
      }
      return;
    }

    final taskProvider = context.read<TaskProvider>();
    final editingTask = taskProvider.editingTask;

    if (editingTask != null) {
      // Update existing task
      final updatedTask = Task(
        id: editingTask.id,
        projectId: _selectedProjectId!,
        stage: _selectedStage!,
        zone: _zoneController.text.trim(),
        description: _descriptionController.text.trim(),
        isCompleted: editingTask.isCompleted,
        createdAt: editingTask.createdAt, // Keep original creation date
        completedAt: editingTask.isCompleted ? (editingTask.completedAt ?? DateTime.now()) : null,
      );
      await taskProvider.updateTask(updatedTask);
    } else {
      // Add new task
      final newTask = Task(
        projectId: _selectedProjectId!,
        stage: _selectedStage!,
        zone: _zoneController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
      );
      await taskProvider.addTask(newTask);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _zoneController.dispose();
    _descriptionController.dispose();
    // IMPORTANT: Clear editing task from the provider when the form is closed
    // to prevent issues next time the form opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<TaskProvider>().clearEditingTask();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final projectProvider = context.watch<ProjectProvider>();

    return Container(
      padding: const EdgeInsets.all(24.0),
      constraints: const BoxConstraints(maxWidth: 500),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              taskProvider.editingTask == null
                  ? "Agregar nueva Tarea"
                  : "Editar Tarea",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            StreamBuilder<List<Project>>(
              stream: projectProvider.getProjectsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return DropdownButtonFormField<String>(
                  value: _selectedProjectId,
                  items: snapshot.data!.map((project) {
                    return DropdownMenuItem(
                      value: project.id,
                      child: Text(project.name),
                    );
                  }).toList(),
                  onChanged: widget.projectId != null
                      ? null // Disable if a project is pre-selected
                      : (value) => setState(() => _selectedProjectId = value),
                  decoration: InputDecoration(
                    labelText: "Projecto",
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStage,
              items: taskProvider.stages.map((stage) {
                return DropdownMenuItem(value: stage, child: Text(stage));
              }).toList(),
              onChanged: (value) => setState(() => _selectedStage = value),
              decoration: InputDecoration(
                labelText: "Estado",
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _zoneController,
              decoration: InputDecoration(
                labelText: "Zone",
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Descripción",
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                taskProvider.editingTask == null
                    ? "Agregar Tarea"
                    : "Actualizar Tarea",
              ),
            ),
            if (taskProvider.editingTask != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancelar"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
