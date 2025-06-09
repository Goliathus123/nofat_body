// lib/src/presentation/features/workout_session/screens/workout_session_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../domain/entities/ejercicio_log.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final List<EjercicioLog> rutinaInicial;
  const WorkoutSessionScreen({super.key, required this.rutinaInicial});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late List<EjercicioLog> _ejerciciosDeLaSesion;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _tiempoTranscurrido = '00:00:00';

  @override
  void initState() {
    super.initState();
    // Creamos una copia de la lista para poder modificarla (marcar como completados)
    _ejerciciosDeLaSesion = widget.rutinaInicial
        .map((e) => EjercicioLog.fromJson(e.toJson()))
        .toList();
    _iniciarCronometro();
  }

  @override
  void dispose() {
    _timer
        ?.cancel(); // Es crucial cancelar el timer para evitar fugas de memoria
    super.dispose();
  }

  void _iniciarCronometro() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final duration = _stopwatch.elapsed;
      final hours = duration.inHours.toString().padLeft(2, '0');
      final minutes = duration.inMinutes
          .remainder(60)
          .toString()
          .padLeft(2, '0');
      final seconds = duration.inSeconds
          .remainder(60)
          .toString()
          .padLeft(2, '0');
      if (mounted) {
        setState(() {
          _tiempoTranscurrido = '$hours:$minutes:$seconds';
        });
      }
    });
  }

  void _terminarRutina() {
    _stopwatch.stop();
    _timer?.cancel();
    // Devolvemos la lista de ejercicios actualizada (con los checkboxes marcados)
    Navigator.of(context).pop(_ejerciciosDeLaSesion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Sesión en Progreso'),
        automaticallyImplyLeading: false, // Quita la flecha de "atrás"
      ),
      body: Column(
        children: [
          // --- EL CRONÓMETRO ---
          Container(
            width: double.infinity,
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              _tiempoTranscurrido,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 56,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // --- EL CHECKLIST DE EJERCICIOS ---
          Expanded(
            child: ListView.builder(
              itemCount: _ejerciciosDeLaSesion.length,
              itemBuilder: (context, index) {
                final ejercicio = _ejerciciosDeLaSesion[index];
                return CheckboxListTile(
                  title: Text(ejercicio.nombre),
                  subtitle: Text(
                    '${ejercicio.series} Series x ${ejercicio.repeticiones} Reps',
                  ),
                  value: ejercicio.completado,
                  onChanged: (bool? newValue) {
                    if (newValue != null) {
                      setState(() {
                        ejercicio.completado = newValue;
                      });
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.stop_circle),
            label: const Text('TERMINAR RUTINA'),
            onPressed: _terminarRutina,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}
