import 'package:flutter/material.dart';

/// Tokens de cor do FinFlow - Segue padrão Dark Mode Moderno com alto contraste e acessibilidade (WCAG AA).
class AppColors {
  AppColors._();

  // Backgrounds & Surfaces
  static const Color background = Color(0xFF0F172A); // Slate 900
  static const Color surface = Color(0xFF1E293B);    // Slate 800
  static const Color surfaceVariant = Color(0xFF334155); // Slate 700

  // Primaries & Accents
  static const Color primary = Color(0xFF10B981);    // Emerald 500 (Finanças/Crescimento)
  static const Color primaryDark = Color(0xFF059669);
  static const Color secondary = Color(0xFF6366F1);  // Indigo 500

  // Semantic Status
  static const Color income = Color(0xFF22C55E);     // Green 500 (Entradas)
  static const Color expense = Color(0xFFEF4444);    // Red 500 (Saídas)
  static const Color warning = Color(0xFFF59E0B);    // Amber 500
  static const Color info = Color(0xFF3B82F6);       // Blue 500

  // Typography & Borders
  static const Color textPrimary = Color(0xFFF8FAFC);   // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color border = Color(0xFF334155);
}

