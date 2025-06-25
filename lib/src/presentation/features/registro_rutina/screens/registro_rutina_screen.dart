// lib/src/presentation/features/registro_rutina/screens/registro_rutina_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nofat_body/src/data/repositories/local_storage_repository.dart';
import 'package:nofat_body/src/domain/entities/ejercicio_definicion.dart';
import 'package:nofat_body/src/domain/entities/ejercicio_log.dart';
import 'package:nofat_body/src/domain/entities/rutina_diaria.dart';
import 'package:nofat_body/src/presentation/features/biblioteca_ejercicios/screens/biblioteca_screen.dart';
import 'package:nofat_body/src/presentation/features/registro_calorias/screens/calorias_screen.dart';
import 'package:nofat_body/src/presentation/features/workout_session/screens/workout_session_screen.dart';

class RegistroRutinaScreen extends StatefulWidget {
  const RegistroRutinaScreen({super.key});

  @override
  State<RegistroRutinaScreen> createState() => _RegistroRutinaScreenState();
}

class _RegistroRutinaScreenState extends State<RegistroRutinaScreen> {
  final LocalStorageRepository _repository = LocalStorageRepository();
  DateTime _fechaSeleccionada = DateTime.now();
  Map<String, RutinaDiaria> _todasLasRutinas = {};

  RutinaDiaria get _rutinaDelDiaSeleccionado =>
      _todasLasRutinas[_fechaComoString(_fechaSeleccionada)] ??
      RutinaDiaria(ejercicios: []);

  @override
  void initState() {
    super.initState();
    _cargarTodasLasRutinas();
  }

  String _fechaComoString(DateTime fecha) =>
      DateFormat('yyyy-MM-dd').format(fecha);

  void _cargarTodasLasRutinas() async {
    final rutinasGuardadas = await _repository.cargarTodasLasRutinas();
    if (mounted) {
      setState(() => _todasLasRutinas = rutinasGuardadas);
    }
  }

  Future<void> _guardarYRerefrescar() async {
    await _repository.guardarTodasLasRutinas(_todasLasRutinas);
  }

  void _seleccionarFecha(BuildContext context) async {
    final DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    );
    if (nuevaFecha != null) {
      setState(() => _fechaSeleccionada = nuevaFecha);
    }
  }

  void _iniciarRutina() async {
    final rutinaDelDia = _rutinaDelDiaSeleccionado;
    if (rutinaDelDia.ejercicios.isEmpty) return;

    final List<EjercicioLog>? ejerciciosActualizados =
        await Navigator.push<List<EjercicioLog>>(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WorkoutSessionScreen(rutinaInicial: rutinaDelDia.ejercicios),
          ),
        );

    if (ejerciciosActualizados != null && mounted) {
      final bool todosCompletados = ejerciciosActualizados.every(
        (e) => e.completado,
      );

      setState(() {
        final rutinaModificada =
            _todasLasRutinas[_fechaComoString(_fechaSeleccionada)] ??
            RutinaDiaria(ejercicios: []);
        rutinaModificada.ejercicios.clear();
        rutinaModificada.ejercicios.addAll(ejerciciosActualizados);
        rutinaModificada.completada = todosCompletados;
        _todasLasRutinas[_fechaComoString(_fechaSeleccionada)] =
            rutinaModificada;
      });
      _guardarYRerefrescar();
    }
  }

  void _accionCrearOAnadir() {
    _mostrarDialogoAgregarEjercicio();
  }

  void _mostrarDialogoAgregarEjercicio() {
    final nombreController = TextEditingController();
    final seriesController = TextEditingController();
    final repeticionesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    void seleccionarDeLaBiblioteca() async {
      final resultado = await Navigator.push<EjercicioDefinicion>(
        context,
        MaterialPageRoute(builder: (context) => const BibliotecaScreen()),
      );
      if (resultado != null) {
        nombreController.text = resultado.nombre;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Añadir Ejercicio'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Ejercicio',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.menu_book),
                      label: const Text("Elegir de la Biblioteca"),
                      onPressed: seleccionarDeLaBiblioteca,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: seriesController,
                    decoration: const InputDecoration(
                      labelText: 'Nº de Series',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: repeticionesController,
                    decoration: const InputDecoration(
                      labelText: 'Nº de Repeticiones',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final nuevoEjercicio = EjercicioLog(
                    nombre: nombreController.text,
                    series: int.tryParse(seriesController.text) ?? 0,
                    repeticiones:
                        int.tryParse(repeticionesController.text) ?? 0,
                  );
                  setState(() {
                    final rutinaActual = _rutinaDelDiaSeleccionado;
                    rutinaActual.ejercicios.add(nuevoEjercicio);
                    // Si la rutina estaba completada, al añadir un nuevo ejercicio, deja de estarlo.
                    rutinaActual.completada = false;
                    _todasLasRutinas[_fechaComoString(_fechaSeleccionada)] =
                        rutinaActual;
                  });
                  _guardarYRerefrescar();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rutinaDelDia = _rutinaDelDiaSeleccionado;
    final hayRutina = rutinaDelDia.ejercicios.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: () => _seleccionarFecha(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 8),
              Text(
                DateFormat(
                  'd \'de\' MMMM, yyyy',
                  'es_ES',
                ).format(_fechaSeleccionada),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_outlined),
            tooltip: 'Ir a Calorías',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CaloriasScreen()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          hayRutina
              ? ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: rutinaDelDia.ejercicios.length,
                  itemBuilder: (context, index) {
                    final ejercicio = rutinaDelDia.ejercicios[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(
                          ejercicio.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Series: ${ejercicio.series} - Repeticiones: ${ejercicio.repeticiones}',
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    'No hay rutina programada para este día.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
          if (hayRutina && rutinaDelDia.completada)
            Positioned.fill(
              child: Container(
                color: Colors.green.withOpacity(0.2),
                child: Center(
                  child: Transform.rotate(
                    angle: -0.4,
                    child: Text(
                      'COMPLETADA',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildBottomButtons(hayRutina, rutinaDelDia.completada),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(bool hayRutina, bool estaCompletada) {
    if (!hayRutina) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('CREAR RUTINA'),
              onPressed: _accionCrearOAnadir,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    } else if (hayRutina && !estaCompletada) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add_task),
              label: const Text('AÑADIR EJER.'),
              onPressed: _accionCrearOAnadir,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('INICIAR'),
              onPressed: _iniciarRutina,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    } else {
      // Rutina completada
      return Row(
        children: [
          Expanded(
            child: Text(
              'Rutina completada',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('MODIFICAR'),
              onPressed: _accionCrearOAnadir,
            ),
          ),
        ],
      );
    }
  }
}
