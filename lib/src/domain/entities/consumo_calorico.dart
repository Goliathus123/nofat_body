// lib/src/domain/entities/consumo_calorico.dart

import 'package:json_annotation/json_annotation.dart';

part 'consumo_calorico.g.dart';

@JsonSerializable()
class ConsumoCalorico {
  final String id;
  final String descripcion;
  final int calorias;
  final DateTime fecha;

  ConsumoCalorico({
    required this.id,
    required this.descripcion,
    required this.calorias,
    required this.fecha,
  });

  factory ConsumoCalorico.fromJson(Map<String, dynamic> json) =>
      _$ConsumoCaloricoFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumoCaloricoToJson(this);
}
