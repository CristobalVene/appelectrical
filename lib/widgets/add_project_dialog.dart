
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';

class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({super.key});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _projectNameController = TextEditingController();
  final List<String> _selectedUserIds = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Project'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _projectNameController,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            const SizedBox(height: 20),
            _buildUserSelectionList(),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _createProject,
          child: const Text('Create'),
        ),
      ],
    );
  }

  Widget _buildUserSelectionList() {
    final userProvider = context.watch<UserProvider>();
    return StreamBuilder<List<User>>(
      stream: userProvider.getUsersStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final users = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Users:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...users.map((user) {
              return CheckboxListTile(
                title: Text(user.email),
                value: _selectedUserIds.contains(user.id),
                onChanged: (isSelected) {
                  setState(() {
                    if (isSelected!) {
                      _selectedUserIds.add(user.id);
                    } else {
                      _selectedUserIds.remove(user.id);
                    }
                  });
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _createProject() {
    final projectName = _projectNameController.text;
    context.read<ProjectProvider>().createProject(projectName, _selectedUserIds);
    Navigator.pop(context);
  }
}
