import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1DA1F2);
  static const secondary = Color(0xFF228B22);
  static const accent = Color(0xFFFF8C00);
  static const success = Color(0xFF32CD32);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFE63946);

  static const gradientStart = Color(0xFF32CD32);
  static const gradientEnd = Color(0xFF228B22);

  static const lightBg = Color(0xFFFFFFFF);
  static const darkBg = Color(0xFF121212);
  static const lightCard = Color(0xFFFFFFFF);
  static const darkCard = Color(0xFF1E1E1E);
  static const lightBorder = Color(0xFFE8ECED);
  static const darkBorder = Color(0xFF2E3135);

  static const gradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF1DA1F2), Color(0xFF0D8BD9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
