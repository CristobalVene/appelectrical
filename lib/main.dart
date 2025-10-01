
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'widgets/app_drawer.dart';
import 'widgets/task_list.dart';
import 'widgets/task_form.dart';
import 'providers/project_provider.dart';
import 'providers/user_provider.dart';
import 'providers/task_provider.dart';
import 'services/auth_service.dart';
import 'screens/manage_projects_screen.dart';
import 'screens/auth_wrapper.dart';

// --- PROVIDERS / STATE MANAGEMENT ---
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => ProjectProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        Provider(create: (context) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Color(0xFFE53935);
    final appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
      bodyMedium: GoogleFonts.openSans(fontSize: 14, color: Colors.white),
      labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
    );

    final darkTheme = ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: primarySeedColor,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1F1F1F),
        textTheme: appTextTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1F1F1F),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1F1F1F),
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: primarySeedColor, foregroundColor: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          labelStyle: const TextStyle(color: Colors.grey),
        ));

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Admin Task CRUD',
          theme: darkTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthWrapper(),
          routes: {
            '/manage-projects': (context) => const ManageProjectsScreen(),
          },
        );
      },
    );
  }
}

// --- SCREENS AND WIDGETS ---
class AdminTaskScreen extends StatefulWidget {
  const AdminTaskScreen({super.key});

  @override
  State<AdminTaskScreen> createState() => _AdminTaskScreenState();
}

class _AdminTaskScreenState extends State<AdminTaskScreen> {
  int _currentIndex = 0; // Default to "Tareas"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tareas"),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      drawer: const AppDrawer(),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [TaskList()],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(context: context, builder: (context) => const Dialog(child: TaskForm())),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inbox_outlined), label: 'Tareas'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'Próximo'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explorar'),
        ],
      ),
    );
  }
}
