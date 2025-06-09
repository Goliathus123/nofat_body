// lib/src/data/repositories/local_storage_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/rutina_diaria.dart';
import '../../domain/entities/consumo_calorico.dart';

class LocalStorageRepository {
  // Clave para las rutinas (v2 para el nuevo formato por fecha)
  static const String _rutinasKey = 'todas_las_rutinas_v2';
  // Clave para los consumos de calorías
  static const String _consumosKey = 'lista_consumos';

  // --- MÉTODOS PARA RUTINAS POR FECHA (YA EXISTENTES) ---

  Future<void> guardarTodasLasRutinas(Map<String, RutinaDiaria> rutinas) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = rutinas.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await prefs.setString(_rutinasKey, jsonEncode(data));
  }

  Future<Map<String, RutinaDiaria>> cargarTodasLasRutinas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_rutinasKey);
    if (jsonString == null) return {};
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return data.map(
      (key, value) => MapEntry(key, RutinaDiaria.fromJson(value)),
    );
  }

  // --- MÉTODOS PARA CONSUMO DE CALORÍAS (RESTAURADOS) ---

  /// Guarda la lista de consumos calóricos.
  Future<void> guardarConsumos(List<ConsumoCalorico> consumos) async {
    final prefs = await SharedPreferences.getInstance();
    // Convierte la lista de objetos a una lista de Mapas
    final List<Map<String, dynamic>> data = consumos
        .map((e) => e.toJson())
        .toList();
    // Convierte la lista a un String JSON y lo guarda.
    await prefs.setString(_consumosKey, jsonEncode(data));
  }

  /// Carga la lista de consumos calóricos.
  Future<List<ConsumoCalorico>> cargarConsumos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_consumosKey);
    if (jsonString == null) {
      return []; // Si no hay datos, devuelve una lista vacía.
    }
    // Decodifica el String JSON a una lista
    final List<dynamic> data = jsonDecode(jsonString);
    // Convierte cada elemento de la lista de vuelta a un objeto ConsumoCalorico.
    return data.map((json) => ConsumoCalorico.fromJson(json)).toList();
  }
}
