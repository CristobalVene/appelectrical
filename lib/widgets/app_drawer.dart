import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import '../screens/project_screen.dart';
import '../services/auth_service.dart';
import 'add_project_dialog.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Drawer(
      child: Container(
        color: const Color(0xFF1F1F1F),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            StreamBuilder<User?>(
              stream: authService.authStateChanges,
              builder: (context, snapshot) {
                final user = snapshot.data;
                final accountName = user?.displayName ?? 'Guest';
                final accountInitial = accountName.isNotEmpty
                    ? accountName[0].toUpperCase()
                    : 'G';

                return UserAccountsDrawerHeader(
                  accountName: Text(
                    accountName,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  accountEmail: Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.pink,
                    child: Text(
                      accountInitial,
                      style: const TextStyle(
                        fontSize: 24.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  decoration: const BoxDecoration(color: Color(0xFF1F1F1F)),
                  otherAccountsPictures: const [
                    Icon(Icons.notifications_none, color: Colors.white),
                    Icon(Icons.settings, color: Colors.white),
                  ],
                );
              },
            ),
            _createDrawerItem(icon: Icons.search, text: 'Buscar'),
            _createDrawerItem(icon: Icons.calendar_today_outlined, text: 'Hoy'),
            _createDrawerItem(
              icon: Icons.filter_list,
              text: 'Filtros y Etiquetas',
            ),
            _createDrawerItem(
              icon: Icons.check_circle_outline,
              text: 'Completado',
            ),
            const Divider(color: Colors.grey),
            _createProjectSection(context),
            _createDrawerItem(
              icon: Icons.edit_outlined,
              text: 'Gestionar proyectos',
              onTap: () => Navigator.pushNamed(context, '/manage-projects'),
            ),
            _createDrawerItem(
              icon: Icons.explore_outlined,
              text: 'Explorar plantillas',
            ),
            _createDrawerItem(
              icon: Icons.help_outline,
              text: 'Ayuda y Recursos',
            ),
            const Divider(color: Colors.grey),
            _createDrawerItem(
              icon: Icons.logout,
              text: 'Sign Out',
              onTap: () async {
                await authService.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    GestureTapCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _createProjectSection(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();

    return Column(
      children: [
        ListTile(
          title: const Text(
            'Mis Proyectos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const AddProjectDialog(),
                ),
              ),
              const Icon(Icons.expand_less, color: Colors.white),
            ],
          ),
        ),
        StreamBuilder<List<Project>>(
          stream: projectProvider.getProjectsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final projects = snapshot.data!;
            return Column(
              children: projects.map((project) {
                return _createProjectItem(context, project: project);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _createProjectItem(BuildContext context, {required Project project}) {
    return ListTile(
      leading: const Icon(Icons.tag, color: Colors.white),
      title: Text(project.name, style: const TextStyle(color: Colors.white)),
      trailing: Text(
        project.assignedUsers.length.toString(),
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectScreen(project: project),
          ),
        );
      },
    );
  }
}
