// lib/src/data/repositories/local_storage_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/ejercicio_log.dart';
import '../../domain/entities/consumo_calorico.dart';

class LocalStorageRepository {
  // Claves para guardar los datos en SharedPreferences
  static const String _ejerciciosKey = 'lista_ejercicios';
  static const String _consumosKey = 'lista_consumos';

  // --- Métodos para Ejercicios ---

  Future<void> guardarEjercicios(List<EjercicioLog> ejercicios) async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Convierte la lista de objetos a una lista de Mapas (usando toJson)
    final List<Map<String, dynamic>> data = ejercicios
        .map((e) => e.toJson())
        .toList();
    // 2. Convierte la lista de Mapas a un String en formato JSON
    final String jsonString = jsonEncode(data);
    // 3. Guarda el String
    await prefs.setString(_ejerciciosKey, jsonString);
  }

  Future<List<EjercicioLog>> cargarEjercicios() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_ejerciciosKey);

    if (jsonString == null) {
      return []; // Devuelve una lista vacía si no hay nada guardado
    }

    // 1. Convierte el String JSON a una lista de Mapas
    final List<dynamic> data = jsonDecode(jsonString);
    // 2. Convierte la lista de Mapas a una lista de objetos (usando fromJson)
    return data.map((json) => EjercicioLog.fromJson(json)).toList();
  }

  // --- Métodos para Consumo de Calorías ---

  Future<void> guardarConsumos(List<ConsumoCalorico> consumos) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> data = consumos
        .map((e) => e.toJson())
        .toList();
    await prefs.setString(_consumosKey, jsonEncode(data));
  }

  Future<List<ConsumoCalorico>> cargarConsumos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_consumosKey);
    if (jsonString == null) return [];
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((json) => ConsumoCalorico.fromJson(json)).toList();
  }
}
