import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cita.dart';

class CitasStorage {
  static const String _key = 'citas_guardadas';

  static Future<void> guardarCitas(List<Cita> citas) async {
    final prefs = await SharedPreferences.getInstance();

    final citasJson = citas.map((c) => jsonEncode(c.toMap())).toList();

    await prefs.setStringList(_key, citasJson);
  }

  static Future<List<Cita>> cargarCitas() async {
    final prefs = await SharedPreferences.getInstance();

    final citasJson = prefs.getStringList(_key) ?? [];

    return citasJson
        .map((c) => Cita.fromMap(jsonDecode(c) as Map<String, dynamic>))
        .toList();
  }
}



