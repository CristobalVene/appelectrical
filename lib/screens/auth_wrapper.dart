import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../providers/project_provider.dart';
import '../providers/user_provider.dart';
import '../providers/task_provider.dart';
import 'login_screen.dart';
import '../main.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          }
          // If the user is logged in, provide the data providers and show the main screen
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => TaskProvider()),
              ChangeNotifierProvider(create: (context) => ProjectProvider()),
              ChangeNotifierProvider(create: (context) => UserProvider()),
            ],
            child: const AdminTaskScreen(),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
