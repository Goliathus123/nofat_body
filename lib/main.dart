// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// 1. AÑADE ESTE IMPORT para la función de inicialización.
import 'package:intl/date_symbol_data_local.dart';
import 'package:nofat_body/src/presentation/features/auth/screens/home_screen.dart';

// 2. CONVIERTE LA FUNCIÓN main EN 'async'.
void main() async {
  // 3. ASEGURA QUE LOS BINDINGS DE FLUTTER ESTÉN LISTOS antes de cualquier 'await'.
  WidgetsFlutterBinding.ensureInitialized();

  // 4. ¡LÍNEA CLAVE! INICIALIZA LOS DATOS DE FORMATO PARA ESPAÑOL.
  await initializeDateFormatting('es_ES', null);

  // 5. Finalmente, ejecuta la aplicación.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoFat_Body',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // --- Localización que ya tenías ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // Español
        Locale('en', ''), // Inglés
      ],
      // ---------------------------------
      home: const HomeScreen(),
    );
  }
}
