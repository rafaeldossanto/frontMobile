import 'package:flutter/material.dart';

/// Cor do marcador pelo nivel de confianca do ponto: 1 (vermelho, pouca prova)
/// -> 5 (verde, bem confirmado). O nivel de confianca e o diferencial do app.
Color corPorNivel(int nivel) {
  switch (nivel) {
    case 5:
      return const Color(0xFF4CAF50);
    case 4:
      return const Color(0xFF8BC34A);
    case 3:
      return const Color(0xFFFFC107);
    case 2:
      return const Color(0xFFFF9800);
    default:
      return const Color(0xFFF44336);
  }
}
