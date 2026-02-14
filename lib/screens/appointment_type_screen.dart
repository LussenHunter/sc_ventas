import 'package:flutter/material.dart';

class AppointmentTypeScreen extends StatelessWidget {
  const AppointmentTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipo de cita'),
      ),
      body: const Center(
        child: Text(
          'Aquí irá el formulario',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
