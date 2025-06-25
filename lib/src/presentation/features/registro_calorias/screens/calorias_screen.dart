// lib/src/presentation/features/registro_calorias/screens/calorias_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nofat_body/src/data/repositories/local_storage_repository.dart';
import 'package:nofat_body/src/domain/entities/consumo_calorico.dart';
import 'package:nofat_body/src/presentation/features/analytics/screens/calorias_chart_screen.dart';

class CaloriasScreen extends StatefulWidget {
  const CaloriasScreen({super.key});

  @override
  State<CaloriasScreen> createState() => _CaloriasScreenState();
}

class _CaloriasScreenState extends State<CaloriasScreen> {
  final LocalStorageRepository _repository = LocalStorageRepository();
  DateTime _fechaSeleccionada = DateTime.now();
  Map<String, List<ConsumoCalorico>> _todosLosConsumos = {};

  // Getters para cálculos automáticos
  List<ConsumoCalorico> get _consumosDelDiaSeleccionado =>
      _todosLosConsumos[_fechaComoString(_fechaSeleccionada)] ?? [];
  int get _caloriasConsumidasDelDia =>
      _consumosDelDiaSeleccionado.fold(0, (sum, item) => sum + item.calorias);
  final int _caloriasGastadasFijas =
      750; // Este valor sigue siendo fijo por ahora
  int get _balanceCalorico =>
      _caloriasConsumidasDelDia - _caloriasGastadasFijas;

  @override
  void initState() {
    super.initState();
    _cargarTodosLosConsumos();
  }

  String _fechaComoString(DateTime fecha) =>
      DateFormat('yyyy-MM-dd').format(fecha);

  void _cargarTodosLosConsumos() async {
    final consumosGuardados = await _repository.cargarTodosLosConsumos();
    if (mounted) {
      setState(() => _todosLosConsumos = consumosGuardados);
    }
  }

  Future<void> _guardarConsumos() async {
    await _repository.guardarTodosLosConsumos(_todosLosConsumos);
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

  void _mostrarDialogoAgregarConsumo() {
    final formKey = GlobalKey<FormState>();
    final descripcionController = TextEditingController();
    final caloriasController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Consumo'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Ej: Almuerzo...',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Campo requerido'
                      : null,
                ),
                TextFormField(
                  controller: caloriasController,
                  decoration: const InputDecoration(
                    labelText: 'Calorías (kcal)',
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final nuevoConsumo = ConsumoCalorico(
                    id: DateTime.now().toIso8601String(),
                    descripcion: descripcionController.text,
                    calorias: int.tryParse(caloriasController.text) ?? 0,
                    fecha: _fechaSeleccionada, // Usamos la fecha seleccionada
                  );

                  setState(() {
                    // Obtenemos la lista actual para la fecha, o una nueva si no existe
                    final consumosActuales = List<ConsumoCalorico>.from(
                      _consumosDelDiaSeleccionado,
                    );
                    consumosActuales.add(nuevoConsumo);
                    // Actualizamos el mapa principal con la nueva lista de consumos
                    _todosLosConsumos[_fechaComoString(_fechaSeleccionada)] =
                        consumosActuales;
                  });

                  // Guardamos el mapa completo en el almacenamiento local
                  _guardarConsumos();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Ver Gráfico de Consumo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CaloriasChartScreen(todosLosConsumos: _todosLosConsumos),
                ),
              );
            },
          ),
        ],
      ),
      // --- CUERPO DE LA PANTALLA RECONSTRUIDO ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResumenCard(),
            const SizedBox(height: 24),
            Text(
              'Registros del Día',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            _buildListaConsumo(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregarConsumo,
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- WIDGETS AUXILIARES RECONSTRUIDOS ---

  Widget _buildResumenCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoColumn(
              'Consumidas',
              _caloriasConsumidasDelDia,
              Colors.blue,
            ),
            _buildInfoColumn('Gastadas', _caloriasGastadasFijas, Colors.orange),
            _buildInfoColumn(
              'Balance',
              _balanceCalorico,
              _balanceCalorico >= 0 ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, int value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const Text('kcal', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildListaConsumo() {
    final consumos = _consumosDelDiaSeleccionado;
    if (consumos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Text(
            'No hay registros de consumo para este día.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: consumos.length,
      itemBuilder: (context, index) {
        final consumo = consumos[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: const Icon(
              Icons.restaurant_menu,
              color: Colors.blueAccent,
            ),
            title: Text(consumo.descripcion),
            subtitle: Text(DateFormat('hh:mm a').format(consumo.fecha)),
            trailing: Text(
              '${consumo.calorias} kcal',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
