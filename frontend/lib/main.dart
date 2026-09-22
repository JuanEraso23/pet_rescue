import 'package:flutter/material.dart';

import 'screens/registro_reporte_screen.dart';

void main() {
  runApp(const PetRescueApp());
}

class PetRescueApp extends StatelessWidget {
  const PetRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Rescue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F8FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF156B78)),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF183B4E),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 1,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Color(0xFFD5E1E6)),
          ),
        ),
      ),
      home: const RegistroReporteScreen(),
    );
  }
}
