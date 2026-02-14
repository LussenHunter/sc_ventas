import 'package:flutter/material.dart';
import 'package:sc_ventas/models/cita.dart';
import 'package:sc_ventas/data/citas_storage.dart';
import 'package:sc_ventas/screens/test_screen.dart';
import 'package:sc_ventas/services/notifications_service.dart';

class CitasListScreen extends StatefulWidget {
  const CitasListScreen({super.key});

  @override
  State<CitasListScreen> createState() => _CitasListScreenState();
}

class _CitasListScreenState extends State<CitasListScreen> {
  List<Cita> citas = [];

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    final List<Cita> citasGuardadas = await CitasStorage.cargarCitas();

    // ORDENAR: las más próximas arriba
    citasGuardadas.sort((a, b) {
      final fechaA = _convertirAFecha(a.fecha, a.hora);
      final fechaB = _convertirAFecha(b.fecha, b.hora);
      return fechaA.compareTo(fechaB);
    });

    setState(() {
      citas = citasGuardadas;
    });
  }

  DateTime _convertirAFecha(String fecha, String hora) {
    // fecha: 12/8/2026
    final partesFecha = fecha.split('/');
    final dia = int.parse(partesFecha[0]);
    final mes = int.parse(partesFecha[1]);
    final anio = int.parse(partesFecha[2]);

    // hora: "3:30 PM"
    final partesHora = hora.split(' ');
    final horaMin = partesHora[0].split(':');

    int h = int.parse(horaMin[0]);
    final m = int.parse(horaMin[1]);
    final ampm = partesHora.length > 1 ? partesHora[1] : "AM";

    if (ampm == "PM" && h != 12) h += 12;
    if (ampm == "AM" && h == 12) h = 0;

    return DateTime(anio, mes, dia, h, m);
  }

  Future<void> _confirmarEliminarCita(Cita cita) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar cita'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar esta cita?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await _eliminarCitaPorId(cita.id);
    }
  }

Future<void> _eliminarCitaPorId(String id) async {
  final citaEliminada = citas.firstWhere((c) => c.id == id);

  // ✅ Cancelar notificación asociada
  try {
    await NotificationsService.cancelarNotificacion(int.parse(id));
  } catch (e) {
    debugPrint("Error cancelando notificación al eliminar: $e");
  }

  setState(() {
    citas.removeWhere((c) => c.id == id);
  });

  // ✅ Guardar cambios
  await CitasStorage.guardarCitas(citas);

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Cita eliminada: ${citaEliminada.nombre}')),
  );
}
  Future<void> _editarCita(Cita cita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestScreen(citaExistente: cita),
      ),
    );

    // al volver, refrescar
    await _cargarCitas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Citas guardadas"),
      ),
      body: citas.isEmpty
          ? const Center(
              child: Text(
                "No hay citas guardadas",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: citas.length,
              itemBuilder: (context, index) {
                final cita = citas[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text("${cita.tipo} - ${cita.nombre}"),
                    subtitle: Text(
                      "📞 ${cita.telefono}\n📅 ${cita.fecha}  ⏰ ${cita.hora}\n⏳ Recordatorio: ${cita.recordatorio}",
                    ),
                    isThreeLine: true,
                    onTap: () => _editarCita(cita),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmarEliminarCita(cita),
                    ),
                  ),
                );
              },
            ),
    );
  }
}






