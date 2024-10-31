import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/Views/Authentikasi/Login.dart'; // Import komponen login sesuai path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }
}
