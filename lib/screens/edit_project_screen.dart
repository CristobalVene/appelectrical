
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../models/user.dart';
import '../providers/project_provider.dart';
import '../providers/user_provider.dart';

class EditProjectScreen extends StatefulWidget {
  final Project project;

  const EditProjectScreen({super.key, required this.project});

  @override
  _EditProjectScreenState createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  late TextEditingController _nameController;
  late List<String> _assignedUserIds;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _assignedUserIds = List.from(widget.project.userIds);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProject,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            const SizedBox(height: 20),
            const Text('Assigned Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<User>>(
                stream: userProvider.getUsersStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final allUsers = snapshot.data!;
                  return ListView.builder(
                    itemCount: allUsers.length,
                    itemBuilder: (context, index) {
                      final user = allUsers[index];
                      return CheckboxListTile(
                        title: Text(user.name), // Changed from user.email to user.name
                        value: _assignedUserIds.contains(user.id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _assignedUserIds.add(user.id);
                            } else {
                              _assignedUserIds.remove(user.id);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProject() async {
    final projectProvider = context.read<ProjectProvider>();
    final updatedProject = Project(
      id: widget.project.id,
      name: _nameController.text,
      userIds: _assignedUserIds,
    );
    await projectProvider.updateProject(updatedProject);
    Navigator.pop(context);
  }
}
