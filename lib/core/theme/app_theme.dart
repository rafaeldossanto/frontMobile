import 'package:flutter/material.dart';

/// Tema escuro do Trilha. App de trilha/outdoor — fundo escuro, verde como cor
/// de marca. Centralizado aqui para todas as telas herdarem o mesmo visual.
class AppTheme {
  const AppTheme._();

  static const Color _verde = Color(0xFF4CAF7D);
  static const Color _fundo = Color(0xFF121512);
  static const Color _superficie = Color(0xFF1C201C);

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final colors = ColorScheme.fromSeed(
      seedColor: _verde,
      brightness: Brightness.dark,
    ).copyWith(
      surface: _superficie,
    );

    return base.copyWith(
      colorScheme: colors,
      scaffoldBackgroundColor: _fundo,
      appBarTheme: const AppBarTheme(
        backgroundColor: _fundo,
        elevation: 0,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _superficie,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      cardTheme: CardThemeData(
        color: _superficie,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
