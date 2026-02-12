class Cita {
  final String id;
  final String tipo;
  final String nombre;
  final String telefono;
  final String fecha;
  final String hora;
  final String recordatorio;

  Cita({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.telefono,
    required this.fecha,
    required this.hora,
    required this.recordatorio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'nombre': nombre,
      'telefono': telefono,
      'fecha': fecha,
      'hora': hora,
      'recordatorio': recordatorio,
    };
  }

  factory Cita.fromMap(Map<String, dynamic> map) {
    return Cita(
      id: map['id'] ?? '',
      tipo: map['tipo'] ?? '',
      nombre: map['nombre'] ?? '',
      telefono: map['telefono'] ?? '',
      fecha: map['fecha'] ?? '',
      hora: map['hora'] ?? '',
      recordatorio: map['recordatorio'] ?? '',
    );
  }
}





