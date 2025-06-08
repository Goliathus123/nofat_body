// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumo_calorico.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsumoCalorico _$ConsumoCaloricoFromJson(Map<String, dynamic> json) =>
    ConsumoCalorico(
      id: json['id'] as String,
      descripcion: json['descripcion'] as String,
      calorias: (json['calorias'] as num).toInt(),
      fecha: DateTime.parse(json['fecha'] as String),
    );

Map<String, dynamic> _$ConsumoCaloricoToJson(ConsumoCalorico instance) =>
    <String, dynamic>{
      'id': instance.id,
      'descripcion': instance.descripcion,
      'calorias': instance.calorias,
      'fecha': instance.fecha.toIso8601String(),
    };
