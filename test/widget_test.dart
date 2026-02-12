import 'package:flutter/material.dart';

void main() {
  runApp(const SCVentasApp());
}

class SCVentasApp extends StatelessWidget {
  const SCVentasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SC Ventas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SC Ventas'),
      ),
      body: const Center(
        child: Text(
          '¡Bienvenido a SC Ventas!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
