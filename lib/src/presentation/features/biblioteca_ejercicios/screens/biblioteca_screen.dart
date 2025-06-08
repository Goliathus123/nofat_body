import 'package:flutter/material.dart';
import '../../../../data/mock_data/ejercicios_mock.dart';

class BibliotecaScreen extends StatelessWidget {
  const BibliotecaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca de Ejercicios')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columnas
          crossAxisSpacing: 16.0, // Espacio horizontal
          mainAxisSpacing: 16.0, // Espacio vertical
          childAspectRatio: 0.8, // Relación de aspecto de cada tarjeta
        ),
        itemCount: ejerciciosMock.length,
        itemBuilder: (context, index) {
          final ejercicio = ejerciciosMock[index];
          return InkWell(
            // --- ACCIÓN CLAVE ---
            // Al tocar la tarjeta, regresamos a la pantalla anterior
            // y devolvemos el ejercicio que fue seleccionado.
            onTap: () {
              Navigator.of(context).pop(ejercicio);
            },
            child: Card(
              elevation: 4.0,
              clipBehavior: Clip
                  .antiAlias, // Para que el contenido respete los bordes redondeados
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.asset(
                      ejercicio.rutaGif,
                      fit: BoxFit
                          .cover, // La imagen cubre todo el espacio disponible
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      ejercicio.nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
