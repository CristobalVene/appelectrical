import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../models/user.dart';
import '../providers/project_provider.dart';

class EditProjectScreen extends StatefulWidget {
  final Project project;

  const EditProjectScreen({super.key, required this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late List<String> _assignedUserIds;

  @override
  void initState() {
    super.initState();
    _name = widget.project.name;
    _description = widget.project.description;
    _assignedUserIds = List<String>.from(widget.project.assignedUsers);
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedProject = Project(
        id: widget.project.id,
        name: _name,
        description: _description,
        createdAt: widget.project.createdAt,
        assignedUsers: _assignedUserIds,
      );
      Provider.of<ProjectProvider>(context, listen: false).updateProject(
          updatedProject.id, updatedProject.name, updatedProject.description);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Proyecto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nombre del Proyecto'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, introduce un nombre' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Descripción'),
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 20),
              const Text('Asignar Usuarios',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Expanded(
                child: Consumer<List<User>>(
                  builder: (context, users, child) {
                    if (users.isEmpty) {
                      return const Center(
                          child: Text('No se encontraron usuarios.'));
                    }
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return CheckboxListTile(
                          secondary: CircleAvatar(
                            child: Text(user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?'),
                          ),
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          value: _assignedUserIds.contains(user.uid),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _assignedUserIds.add(user.uid);
                              } else {
                                _assignedUserIds.remove(user.uid);
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
      ),
    );
  }
}
