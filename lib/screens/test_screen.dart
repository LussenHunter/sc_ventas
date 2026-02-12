import 'package:flutter/material.dart';
import 'package:sc_ventas/models/cita.dart';
import 'package:sc_ventas/data/citas_storage.dart';

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
    '1 hora antes',
    '2 horas antes',
    '8 horas antes',
    '1 día antes',
  ];

  @override
  void initState() {
    super.initState();

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

  Future<void> _guardarCita() async {
    if (_tipoCitaSeleccionado == null ||
        _recordatorioSeleccionado == null ||
        _nombreController.text.isEmpty ||
        _telefonoController.text.isEmpty ||
        _fechaController.text.isEmpty ||
        _horaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final citasActuales = await CitasStorage.cargarCitas();

    final citaNueva = Cita(
      id: widget.citaExistente?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      tipo: _tipoCitaSeleccionado!,
      nombre: _nombreController.text,
      telefono: _telefonoController.text,
      fecha: _fechaController.text,
      hora: _horaController.text,
      recordatorio: _recordatorioSeleccionado!,
    );

    // Si editamos: reemplazar por ID
    if (widget.citaExistente != null) {
      final index =
          citasActuales.indexWhere((c) => c.id == widget.citaExistente!.id);

      if (index != -1) {
        citasActuales[index] = citaNueva;
      } else {
        citasActuales.add(citaNueva);
      }
    } else {
      // Si es nueva: agregar
      citasActuales.add(citaNueva);
    }

    await CitasStorage.guardarCitas(citasActuales);

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    super.dispose();
  }

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

            TextField(
              controller: _nombreController,
              decoration:
                  const InputDecoration(labelText: 'Nombre del cliente'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _fechaController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Fecha'),
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

            TextField(
              controller: _horaController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Hora'),
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

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Recordatorio',
                border: OutlineInputBorder(),
              ),
              value: _recordatorioSeleccionado,
              items: recordatorios
                  .map(
                    (r) => DropdownMenuItem(value: r, child: Text(r)),
                  )
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





