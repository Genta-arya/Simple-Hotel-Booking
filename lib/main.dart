import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/src/Views/CheckIn/CheckinForm.dart';
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
        '/login': (context) => LoginScreen(), // Rute untuk halaman login
        '/dashboard': (context) =>  DashboardScreen(), 
        '/checkin': (context) =>  CheckInForm(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
    );
  }
}
