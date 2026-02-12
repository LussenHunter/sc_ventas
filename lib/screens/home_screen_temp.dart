import 'package:flutter/material.dart';
import 'package:sc_ventas/screens/test_screen.dart';
import 'package:sc_ventas/screens/citas_list_screen.dart';

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
            // 🟢 AGENDAR CITA → FORMULARIO
            ElevatedButton(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TestScreen()),
    );

    // Si regresó true, significa que guardó una cita
    if (result == true) {
      debugPrint("Se guardó una cita");
    }
  },
  child: const Text('Agendar cita'),
),
            const SizedBox(height: 20),

            // 🟢 VER CITAS → LISTA
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
          ],
        ),
      ),
    );
  }
}



