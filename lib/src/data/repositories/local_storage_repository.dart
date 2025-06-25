// lib/src/data/repositories/local_storage_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/rutina_diaria.dart';
import '../../domain/entities/consumo_calorico.dart';

class LocalStorageRepository {
  static const String _rutinasKey = 'todas_las_rutinas_v2';
  static const String _consumosKey = 'todos_los_consumos_v1';

  // --- MÉTODOS PARA RUTINAS POR FECHA (IMPLEMENTACIÓN COMPLETA) ---

  /// Guarda el mapa completo de rutinas.
  Future<void> guardarTodasLasRutinas(Map<String, RutinaDiaria> rutinas) async {
    final prefs = await SharedPreferences.getInstance();
    // Convierte el mapa de objetos a un mapa de JSONs
    final Map<String, dynamic> data = rutinas.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    // Guarda el mapa como un único string
    await prefs.setString(_rutinasKey, jsonEncode(data));
  }

  /// Carga el mapa completo de rutinas.
  Future<Map<String, RutinaDiaria>> cargarTodasLasRutinas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_rutinasKey);

    // Si no hay datos guardados, devuelve un mapa vacío.
    if (jsonString == null) {
      return {};
    }

    // Decodifica el string a un mapa de JSONs
    final Map<String, dynamic> data = jsonDecode(jsonString);

    // Convierte el mapa de JSONs de vuelta a un mapa de objetos RutinaDiaria
    return data.map(
      (key, value) =>
          MapEntry(key, RutinaDiaria.fromJson(value as Map<String, dynamic>)),
    );
  }

  // --- MÉTODOS PARA CONSUMO DE CALORÍAS POR FECHA (IMPLEMENTACIÓN COMPLETA) ---

  /// Guarda el mapa completo de consumos.
  Future<void> guardarTodosLosConsumos(
    Map<String, List<ConsumoCalorico>> consumos,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = consumos.map(
      (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(_consumosKey, jsonEncode(data));
  }

  /// Carga el mapa completo de consumos.
  Future<Map<String, List<ConsumoCalorico>>> cargarTodosLosConsumos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_consumosKey);
    if (jsonString == null) {
      return {};
    }

    final Map<String, dynamic> data = jsonDecode(jsonString);
    return data.map((key, value) {
      final List<ConsumoCalorico> consumos = (value as List)
          .map((item) => ConsumoCalorico.fromJson(item as Map<String, dynamic>))
          .toList();
      return MapEntry(key, consumos);
    });
  }
}
