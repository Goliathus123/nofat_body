import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../data/repositories/local_storage_repository.dart'; // Importa el repositorio
import '../../../../domain/entities/consumo_calorico.dart';

class CaloriasScreen extends StatefulWidget {
  const CaloriasScreen({super.key});

  @override
  State<CaloriasScreen> createState() => _CaloriasScreenState();
}

class _CaloriasScreenState extends State<CaloriasScreen> {
  final List<ConsumoCalorico> _consumosDelDia = [];
  // --- LÓGICA DE PERSISTENCIA ---
  final LocalStorageRepository _repository = LocalStorageRepository();
  final int _caloriasGastadas = 750;

  int get _caloriasConsumidas =>
      _consumosDelDia.fold(0, (sum, item) => sum + item.calorias);
  int get _balanceCalorico => _caloriasConsumidas - _caloriasGastadas;

  @override
  void initState() {
    super.initState();
    // --- LÓGICA DE PERSISTENCIA ---
    _cargarConsumos();
  }

  void _cargarConsumos() async {
    final consumosGuardados = await _repository.cargarConsumos();
    setState(() {
      _consumosDelDia.clear();
      _consumosDelDia.addAll(consumosGuardados);
    });
  }

  void _guardarConsumos() {
    _repository.guardarConsumos(_consumosDelDia);
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
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  validator: (value) => (value == null || value.isEmpty)
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
                if (formKey.currentState!.validate()) {
                  final nuevoConsumo = ConsumoCalorico(
                    id: DateTime.now().toIso8601String(),
                    descripcion: descripcionController.text,
                    calorias: int.tryParse(caloriasController.text) ?? 0,
                    fecha: DateTime.now(),
                  );
                  setState(() {
                    _consumosDelDia.add(nuevoConsumo);
                  });

                  // --- LÓGICA DE PERSISTENCIA ---
                  // ¡ACCIÓN CLAVE DE GUARDADO!
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
    // El método build se mantiene exactamente igual que antes.
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Calorías')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResumenCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Consumo Diario',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.green,
                    size: 30,
                  ),
                  onPressed: _mostrarDialogoAgregarConsumo,
                ),
              ],
            ),
            const Divider(),
            _buildListaConsumo(),
          ],
        ),
      ),
    );
  }

  // Los métodos _buildResumenCard, _buildInfoColumn y _buildListaConsumo se mantienen iguales.
  Widget _buildResumenCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoColumn('Consumidas', _caloriasConsumidas, Colors.blue),
            _buildInfoColumn('Gastadas', _caloriasGastadas, Colors.orange),
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
    if (_consumosDelDia.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Text(
            'No hay registros de consumo todavía.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _consumosDelDia.length,
      itemBuilder: (context, index) {
        final consumo = _consumosDelDia[index];
        final horaFormateada = DateFormat('hh:mm a').format(consumo.fecha);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: const Icon(
              Icons.restaurant_menu,
              color: Colors.blueAccent,
            ),
            title: Text(consumo.descripcion),
            subtitle: Text(horaFormateada),
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
