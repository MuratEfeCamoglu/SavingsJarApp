import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF0047CC); // Bright blue from design
  static const Color primaryDark = Color(0xFF051C3F); // Dark blue for Add Money button
  static const Color accentGreen = Color(0xFF10B981); // Emerald Green
  static const Color accentOrange = Color(0xFFFFDAB9); // Peach orange for auto-save
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color tabActiveBg = Color(0xFFEBF0FF); // Light blue for active tab background


  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
      primaryColor: primary,
      cardColor: const Color(0xFF1E293B), // Slate 800
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accentGreen,
        surface: Color(0xFF1E293B),
        background: Color(0xFF0F172A),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: GoogleFonts.inter(color: Colors.white),
            bodyMedium: GoogleFonts.inter(color: const Color(0xFF94A3B8)), // Slate 400
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      cardColor: cardColor,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accentGreen,
        surface: cardColor,
        background: background,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.inter(
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: GoogleFonts.inter(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: GoogleFonts.inter(color: textPrimary),
            bodyMedium: GoogleFonts.inter(color: textSecondary),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
