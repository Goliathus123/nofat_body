import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/repositories/local_storage_repository.dart'; // Importa el repositorio
import '../../../../domain/entities/ejercicio_definicion.dart';
import '../../../../domain/entities/ejercicio_log.dart';
import '../../biblioteca_ejercicios/screens/biblioteca_screen.dart';
import '../../registro_calorias/screens/calorias_screen.dart';

class RegistroRutinaScreen extends StatefulWidget {
  const RegistroRutinaScreen({super.key});

  @override
  State<RegistroRutinaScreen> createState() => _RegistroRutinaScreenState();
}

class _RegistroRutinaScreenState extends State<RegistroRutinaScreen> {
  final List<EjercicioLog> _ejerciciosDelDia = [];
  // --- LÓGICA DE PERSISTENCIA ---
  // 1. Instancia del repositorio que se encargará de la comunicación con el almacenamiento.
  final LocalStorageRepository _repository = LocalStorageRepository();

  @override
  void initState() {
    super.initState();
    // --- LÓGICA DE PERSISTENCIA ---
    // 2. Llamamos al método para cargar los datos guardados en cuanto la pantalla se inicia.
    _cargarEjercicios();
  }

  /// Carga los ejercicios desde el almacenamiento local y actualiza el estado.
  void _cargarEjercicios() async {
    final ejerciciosGuardados = await _repository.cargarEjercicios();
    // Usamos setState para redibujar la pantalla con los datos cargados.
    setState(() {
      _ejerciciosDelDia.clear(); // Limpiamos la lista por si acaso
      _ejerciciosDelDia.addAll(ejerciciosGuardados);
    });
  }

  /// Guarda la lista actual de ejercicios en el almacenamiento local.
  void _guardarEjercicios() {
    _repository.guardarEjercicios(_ejerciciosDelDia);
  }

  void _mostrarDialogoAgregarEjercicio() async {
    final nombreController = TextEditingController();
    final seriesController = TextEditingController();
    final repeticionesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    void _seleccionarDeLaBiblioteca() async {
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Añadir Nuevo Ejercicio'),
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
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Campo requerido'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.menu_book),
                    label: const Text("Elegir de la Biblioteca"),
                    onPressed: _seleccionarDeLaBiblioteca,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: seriesController,
                    decoration: const InputDecoration(
                      labelText: 'Nº de Series',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Campo requerido'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: repeticionesController,
                    decoration: const InputDecoration(
                      labelText: 'Nº de Repeticiones',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Campo requerido'
                        : null,
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
                if (formKey.currentState!.validate()) {
                  final nuevoEjercicio = EjercicioLog(
                    nombre: nombreController.text,
                    series: int.tryParse(seriesController.text) ?? 0,
                    repeticiones:
                        int.tryParse(repeticionesController.text) ?? 0,
                  );

                  setState(() {
                    _ejerciciosDelDia.add(nuevoEjercicio);
                  });

                  // --- LÓGICA DE PERSISTENCIA ---
                  // 3. ¡ACCIÓN CLAVE DE GUARDADO!
                  // Justo después de añadir un ejercicio a la lista, guardamos la lista completa.
                  _guardarEjercicios();

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
    // El método build se mantiene exactamente igual que antes.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutina de Hoy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_outlined),
            tooltip: 'Ir a Calorías',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CaloriasScreen()),
              );
            },
          ),
        ],
      ),
      body: _ejerciciosDelDia.isEmpty
          ? const Center(
              child: Text(
                'Aún no has registrado ejercicios.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _ejerciciosDelDia.length,
              itemBuilder: (context, index) {
                final ejercicio = _ejerciciosDelDia[index];
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregarEjercicio,
        tooltip: 'Añadir Ejercicio',
        child: const Icon(Icons.add),
      ),
    );
  }
}
