// lib/src/domain/entities/ejercicio_log.dart

import 'package:json_annotation/json_annotation.dart';
part 'ejercicio_log.g.dart';

@JsonSerializable()
class EjercicioLog {
  final String nombre;
  final int series;
  final int repeticiones;
  bool completado; // <--- CAMBIO: Añadimos esta propiedad

  EjercicioLog({
    required this.nombre,
    required this.series,
    required this.repeticiones,
    this.completado = false, // Valor por defecto
  });

  factory EjercicioLog.fromJson(Map<String, dynamic> json) =>
      _$EjercicioLogFromJson(json);
  Map<String, dynamic> toJson() => _$EjercicioLogToJson(this);
}
