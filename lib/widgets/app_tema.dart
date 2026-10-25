import 'package:flutter/material.dart';

class AppColores {
  static const primario = Color(0xFF2456E5);
  static const fondo = Color(0xFFF7F4EE);
  static const texto = Color(0xFF17203A);
  static const textoSuave = Color(0xFF4B5563);
  static const borde = Color(0xFFD9D3C7);
  static const bordeTarjeta = Color(0xFFE6E0D4);
  static const azulSuave = Color(0xFFE8EEFD);
  static const error = Color(0xFFB42318);
  static const errorSuave = Color(0xFFFDF2F1);
  static const exito = Color(0xFF1F7A3D);

  static const morado = Color(0xFF5B45C8);
  static const rosa = Color(0xFFB8325F);
  static const verde = Color(0xFF1F7A3D);
  static const terracota = Color(0xFFB4532A);
}

class AppTema {
  static ThemeData get claro {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColores.borde, width: 1.5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColores.primario)
          .copyWith(primary: AppColores.primario),
      scaffoldBackgroundColor: AppColores.fondo,
      appBarTheme: const AppBarTheme(backgroundColor: AppColores.fondo),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: borde,
        enabledBorder: borde,
        focusedBorder: borde.copyWith(
          borderSide: const BorderSide(color: AppColores.primario, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF757575)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          foregroundColor: AppColores.primario,
          side: const BorderSide(color: AppColores.primario, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }
}
