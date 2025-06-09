import 'package:json_annotation/json_annotation.dart';
import 'ejercicio_log.dart';

part 'rutina_diaria.g.dart';

@JsonSerializable(
  explicitToJson: true,
) // explicitToJson es necesario porque contiene otra clase serializable
class RutinaDiaria {
  final List<EjercicioLog> ejercicios;
  bool completada;

  RutinaDiaria({required this.ejercicios, this.completada = false});

  factory RutinaDiaria.fromJson(Map<String, dynamic> json) =>
      _$RutinaDiariaFromJson(json);
  Map<String, dynamic> toJson() => _$RutinaDiariaToJson(this);
}
