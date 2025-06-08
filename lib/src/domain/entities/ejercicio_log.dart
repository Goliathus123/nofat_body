// lib/src/domain/entities/ejercicio_log.dart

import 'package:json_annotation/json_annotation.dart';

// PARTE 1: Esta línea es crucial y debe coincidir exactamente con el nombre del archivo.
part 'ejercicio_log.g.dart';

// PARTE 2: Esta anotación le dice al generador que procese esta clase.
@JsonSerializable()
class EjercicioLog {
  final String nombre;
  final int series;
  final int repeticiones;

  EjercicioLog({
    required this.nombre,
    required this.series,
    required this.repeticiones,
  });

  // PARTE 3: Esta línea llama a la función que será generada en 'ejercicio_log.g.dart'.
  // Aquí es donde tu editor marca el error porque la función aún no existe.
  factory EjercicioLog.fromJson(Map<String, dynamic> json) =>
      _$EjercicioLogFromJson(json);

  // PARTE 4: Esta línea también llama a una función generada.
  Map<String, dynamic> toJson() => _$EjercicioLogToJson(this);
}
