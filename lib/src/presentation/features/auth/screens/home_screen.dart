import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nofat_body/src/presentation/features/registro_rutina/screens/registro_rutina_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos un Scaffold para la estructura básica de la pantalla.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 40, 40, 35),
        // Usamos SafeArea para evitar que nuestro contenido se superponga con la
        // barra de estado del sistema operativo o el 'notch' de los teléfonos.
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                // Centramos los elementos verticalmente en la pantalla.
                mainAxisAlignment: MainAxisAlignment.center,
                // Estiramos los elementos horizontalmente.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. EL LOGO
                  Image.asset(
                    'assets/images/logo_nofat.png', // Asegúrate de que el nombre coincida con tu archivo.
                    height: 250, // Ajusta la altura según el tamaño de tu logo.
                  ),
                  const SizedBox(
                    height: 48,
                  ), // Espacio vertical entre el logo y los botones.
                  // 2. BOTÓN DE INGRESO
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Centra los elementos del Row
                    children: [
                      // Envolvemos el primer botón en Expanded
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: const Color.fromARGB(
                              171,
                              136,
                              134,
                              134,
                            ),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RegistroRutinaScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'INGRESO',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Espacio entre los dos botones
                      const SizedBox(width: 16),

                      // Envolvemos el segundo botón en Expanded
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color.fromARGB(
                              255,
                              198,
                              198,
                              22,
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            print('Botón de Registro presionado');
                          },
                          child: const Text(
                            'REGISTRO',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
