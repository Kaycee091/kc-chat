import 'package:flutter/material.dart';

class AppColors {
  // Brand Accents
  static const Color primary = Color(0xFF2563EB);      // Royal Blue
  static const Color secondary = Color(0xFF8B5CF6);    // Vibrant Purple
  static const Color destructive = Color(0xFFF43F5E);  // Rose / Alert
  static const Color success = Color(0xFF10B981);      // Emerald / Online
  static const Color warning = Color(0xFFF59E0B);      // Amber

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF0F2F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // Gradient Accents
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient storyGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFF8B5CF6), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassmorphicGradient = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x1AFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
