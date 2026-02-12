import 'package:flutter/material.dart';
import 'package:sc_ventas/models/cita.dart';
import 'package:sc_ventas/data/citas_storage.dart';
import 'package:sc_ventas/screens/test_screen.dart';

class CitasListScreen extends StatefulWidget {
  const CitasListScreen({super.key});

  @override
  State<CitasListScreen> createState() => _CitasListScreenState();
}

class _CitasListScreenState extends State<CitasListScreen> {
  List<Cita> citas = [];
  List<Cita> citasFiltradas = [];

  final TextEditingController _buscarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarCitas();

    _buscarController.addListener(() {
      _filtrarCitas(_buscarController.text);
    });
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
      citasFiltradas = citasGuardadas;
    });
  }

  void _filtrarCitas(String texto) {
    final query = texto.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        citasFiltradas = citas;
      });
      return;
    }

    final filtradas = citas.where((cita) {
      return cita.nombre.toLowerCase().contains(query) ||
          cita.telefono.toLowerCase().contains(query) ||
          cita.tipo.toLowerCase().contains(query);
    }).toList();

    setState(() {
      citasFiltradas = filtradas;
    });
  }

  DateTime _convertirAFecha(String fecha, String hora) {
    // fecha: 12/8/2026
    // hora: 3:30 PM

    final partesFecha = fecha.split('/');
    final dia = int.parse(partesFecha[0]);
    final mes = int.parse(partesFecha[1]);
    final anio = int.parse(partesFecha[2]);

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
          content: const Text('¿Estás seguro de que deseas eliminar esta cita?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
    setState(() {
      citas.removeWhere((c) => c.id == id);
      citasFiltradas.removeWhere((c) => c.id == id);
    });

    await CitasStorage.guardarCitas(citas);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita eliminada')),
      );
    }
  }

  Future<void> _editarCita(Cita cita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestScreen(citaExistente: cita),
      ),
    );

    // Al volver, refrescar lista
    await _cargarCitas();
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Citas guardadas"),
      ),
      body: Column(
        children: [
          // 🔎 Buscador
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _buscarController,
              decoration: const InputDecoration(
                labelText: "Buscar cita (nombre, tipo o teléfono)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Lista
          Expanded(
            child: citasFiltradas.isEmpty
                ? const Center(
                    child: Text(
                      "No hay citas guardadas",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: citasFiltradas.length,
                    itemBuilder: (context, index) {
                      final cita = citasFiltradas[index];

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
          ),
        ],
      ),
    );
  }
}





