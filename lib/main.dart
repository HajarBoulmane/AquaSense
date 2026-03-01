import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AquaSenseApp());
}

class AquaSenseApp extends StatelessWidget {
  const AquaSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077B6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}