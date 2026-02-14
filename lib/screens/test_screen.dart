import 'package:flutter/material.dart';
import 'package:sc_ventas/models/cita.dart';
import 'package:sc_ventas/data/citas_storage.dart';
import 'package:sc_ventas/services/notifications_service.dart';

class TestScreen extends StatefulWidget {
  final Cita? citaExistente;

  const TestScreen({
    super.key,
    this.citaExistente,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();

  String? _tipoCitaSeleccionado;
  String? _recordatorioSeleccionado;

  final List<String> tiposCita = [
    'Toma de medidas',
    'Rectificación',
    'Guía mecánica',
    'Verificación',
    'Visita servicio',
    'Muestra de diseño/presupuesto',
    'Firmas',
  ];

final List<String> recordatorios = [
  '1 minuto antes (prueba)',
  '5 minutos antes (prueba)',
  '1 hora antes',
  '2 horas antes',
  '8 horas antes',
  '1 día antes',
];

  @override
  void initState() {
    super.initState();

    // Si viene una cita para editar, precargamos todo
    if (widget.citaExistente != null) {
      final cita = widget.citaExistente!;

      _tipoCitaSeleccionado = cita.tipo;
      _recordatorioSeleccionado = cita.recordatorio;

      _nombreController.text = cita.nombre;
      _telefonoController.text = cita.telefono;
      _fechaController.text = cita.fecha;
      _horaController.text = cita.hora;
    }
  }

  // ---------------------------
  // CONVERTIR FECHA + HORA A DATETIME
  // ---------------------------
  DateTime _convertirAFechaHora(String fecha, String hora) {
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
  // ---------------------------
  // CALCULAR RECORDATORIO REAL
  // ---------------------------
DateTime _calcularRecordatorio(DateTime fechaCita, String recordatorio) {
  switch (recordatorio) {
    case '1 minuto antes (prueba)':
      return fechaCita.subtract(const Duration(minutes: 1));

    case '5 minutos antes (prueba)':
      return fechaCita.subtract(const Duration(minutes: 5));

    case '1 hora antes':
      return fechaCita.subtract(const Duration(hours: 1));

    case '2 horas antes':
      return fechaCita.subtract(const Duration(hours: 2));

    case '8 horas antes':
      return fechaCita.subtract(const Duration(hours: 8));

    case '1 día antes':
      return fechaCita.subtract(const Duration(days: 1));

    default:
      return fechaCita.subtract(const Duration(hours: 1));
  }
}

  // ---------------------------
  // GUARDAR CITA
  // ---------------------------
Future<void> _guardarCita() async {
  if (_tipoCitaSeleccionado == null ||
      _recordatorioSeleccionado == null ||
      _nombreController.text.trim().isEmpty ||
      _telefonoController.text.trim().isEmpty ||
      _fechaController.text.trim().isEmpty ||
      _horaController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Completa todos los campos')),
    );
    return;
  }

  // 1) Cargar lista actual
  final citasActuales = await CitasStorage.cargarCitas();

  // 2) Crear cita (si es edición conserva el mismo ID)
  final citaNueva = Cita(
    id: widget.citaExistente?.id ??
        DateTime.now().millisecondsSinceEpoch.toString(),
    tipo: _tipoCitaSeleccionado!,
    nombre: _nombreController.text.trim(),
    telefono: _telefonoController.text.trim(),
    fecha: _fechaController.text.trim(),
    hora: _horaController.text.trim(),
    recordatorio: _recordatorioSeleccionado!,
  );

  // 3) Si editamos: reemplazar por ID
  if (widget.citaExistente != null) {
    final index =
        citasActuales.indexWhere((c) => c.id == widget.citaExistente!.id);

    if (index != -1) {
      citasActuales[index] = citaNueva;
    } else {
      citasActuales.add(citaNueva);
    }

    // ✅ Cancelar notificación anterior (importantísimo)
    try {
      await NotificationsService.cancelarNotificacion(
        int.parse(widget.citaExistente!.id),
      );
    } catch (e) {
      debugPrint("Error cancelando notificación vieja: $e");
    }
  } else {
    // 4) Si es nueva: agregar
    citasActuales.add(citaNueva);
  }

  // 5) Guardar lista completa
  await CitasStorage.guardarCitas(citasActuales);

  // 6) Programar notificación REAL
  final fechaCita = _convertirAFechaHora(citaNueva.fecha, citaNueva.hora);
  final fechaRecordatorio =
      _calcularRecordatorio(fechaCita, citaNueva.recordatorio);

  if (fechaRecordatorio.isAfter(DateTime.now())) {
    try {
      await NotificationsService.programarNotificacion(
        notificationId: int.parse(citaNueva.id),
        titulo: "Recordatorio de cita",
        mensaje: "${citaNueva.tipo} - ${citaNueva.nombre}",
        fechaHora: fechaRecordatorio,
      );
    } catch (e) {
      debugPrint("Error al programar notificación: $e");
    }
  }

  // 7) Volver
  if (!mounted) return;
  Navigator.pop(context);
}
  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  // ---------------------------
  // UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.citaExistente == null ? 'Agendar cita' : 'Editar cita',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TIPO DE CITA
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tipo de cita',
                border: OutlineInputBorder(),
              ),
              value: _tipoCitaSeleccionado,
              items: tiposCita
                  .map(
                    (tipo) =>
                        DropdownMenuItem(value: tipo, child: Text(tipo)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _tipoCitaSeleccionado = value),
            ),

            const SizedBox(height: 16),

            // NOMBRE
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del cliente',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // TELÉFONO
            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // FECHA
            TextField(
              controller: _fechaController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Fecha',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final fecha = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );

                if (fecha != null) {
                  _fechaController.text =
                      '${fecha.day}/${fecha.month}/${fecha.year}';
                }
              },
            ),

            const SizedBox(height: 16),

            // HORA
            TextField(
              controller: _horaController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Hora',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final hora = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (hora != null) {
                  _horaController.text = hora.format(context);
                }
              },
            ),

            const SizedBox(height: 16),

            // RECORDATORIO
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Recordatorio',
                border: OutlineInputBorder(),
              ),
              value: _recordatorioSeleccionado,
              items: recordatorios
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _recordatorioSeleccionado = value),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _guardarCita,
              child: Text(
                widget.citaExistente == null
                    ? 'Guardar cita'
                    : 'Guardar cambios',
              ),
            ),
          ],
        ),
      ),
    );
  }
}







