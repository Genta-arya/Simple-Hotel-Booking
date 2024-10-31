import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/Views/Authentikasi/Login.dart'; // Import komponen login sesuai path
import 'src/Views/Dashboard/Dashboard.dart'; // Import komponen dashboard sesuai path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel K,one',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(), // Rute untuk halaman login
        '/dashboard': (context) => const DashboardScreen(), // Rute untuk halaman dashboard
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
    );
  }
}
