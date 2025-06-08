// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ejercicio_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EjercicioLog _$EjercicioLogFromJson(Map<String, dynamic> json) => EjercicioLog(
  nombre: json['nombre'] as String,
  series: (json['series'] as num).toInt(),
  repeticiones: (json['repeticiones'] as num).toInt(),
);

Map<String, dynamic> _$EjercicioLogToJson(EjercicioLog instance) =>
    <String, dynamic>{
      'nombre': instance.nombre,
      'series': instance.series,
      'repeticiones': instance.repeticiones,
    };
