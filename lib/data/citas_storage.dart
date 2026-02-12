import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cita.dart';

class CitasStorage {
  static const String _key = 'citas';

  static Future<void> guardarCitas(List<Cita> citas) async {
    final prefs = await SharedPreferences.getInstance();
    final citasJson =
        citas.map((cita) => cita.toMap()).toList();
    await prefs.setString(_key, jsonEncode(citasJson));
  }

  static Future<List<Cita>> cargarCitas() async {
    final prefs = await SharedPreferences.getInstance();
    final citasString = prefs.getString(_key);

    if (citasString == null) return [];

    final List decoded = jsonDecode(citasString);
    return decoded.map((e) => Cita.fromMap(e)).toList();
  }
}



