import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const DulshopApp());
}

class DulshopApp extends StatelessWidget {
  const DulshopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dulshop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}

