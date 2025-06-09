// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rutina_diaria.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RutinaDiaria _$RutinaDiariaFromJson(Map<String, dynamic> json) => RutinaDiaria(
  ejercicios: (json['ejercicios'] as List<dynamic>)
      .map((e) => EjercicioLog.fromJson(e as Map<String, dynamic>))
      .toList(),
  completada: json['completada'] as bool? ?? false,
);

Map<String, dynamic> _$RutinaDiariaToJson(RutinaDiaria instance) =>
    <String, dynamic>{
      'ejercicios': instance.ejercicios.map((e) => e.toJson()).toList(),
      'completada': instance.completada,
    };
