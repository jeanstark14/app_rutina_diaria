import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1E6AFF);
  static const Color backgroundGrey = Color(0xFFF8F9FB);
  static const Color textBlack = Color(0xFF1A1C1E);
  static const Color textGrey = Color(0xFF8E9199);
  static const Color surfaceWhite = Colors.white;
  
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1A1A1A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        surface: surfaceWhite,
      ),
      scaffoldBackgroundColor: backgroundGrey,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textBlack, fontSize: 28),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: textBlack),
        bodySmall: GoogleFonts.outfit(color: textGrey, fontSize: 12),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textBlack),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: surfaceWhite,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        surface: darkSurface,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 28),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
        bodySmall: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: darkSurface,
      ),
    );
  }
}
