import 'package:flutter/material.dart';
import 'package:sc_ventas/screens/test_screen.dart';
import 'package:sc_ventas/screens/citas_list_screen.dart';
import 'package:sc_ventas/services/notifications_service.dart';

class HomeScreenTemp extends StatelessWidget {
  const HomeScreenTemp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SC Ventas'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TestScreen(),
                  ),
                );
              },
              child: const Text('Agendar cita'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CitasListScreen(),
                  ),
                );
              },
              child: const Text('Ver citas'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                NotificationsService.showTestNotification();
              },
              child: const Text('Probar notificación'),
            ),
          ],
        ),
      ),
    );
  }
}




