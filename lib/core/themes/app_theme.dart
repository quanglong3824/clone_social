import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors - Facebook inspired
  static const Color primaryBlue = Color(0xFF1877F2);
  static const Color darkBlue = Color(0xFF166FE5);
  static const Color lightBlue = Color(0xFFE7F3FF);
  
  static const Color backgroundLight = Color(0xFFF0F2F5);
  static const Color backgroundDark = Color(0xFF18191A);
  
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF242526);
  
  static const Color textPrimary = Color(0xFF050505);
  static const Color textSecondary = Color(0xFF65676B);
  static const Color textDark = Color(0xFFE4E6EB);
  
  static const Color dividerLight = Color(0xFFCED0D4);
  static const Color dividerDark = Color(0xFF3E4042);
  
  // Success, Warning, Error
  static const Color success = Color(0xFF42B72A);
  static const Color warning = Color(0xFFF7B928);
  static const Color error = Color(0xFFFA383E);
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: backgroundLight,
    
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: darkBlue,
      surface: surfaceLight,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onError: Colors.white,
    ),
    
    textTheme: GoogleFonts.robotoTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
        titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimary),
        bodySmall: TextStyle(fontSize: 12, color: textSecondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
      ),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceLight,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    cardTheme: CardTheme(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: error),
      ),
    ),
    
    dividerTheme: const DividerThemeData(
      color: dividerLight,
      thickness: 1,
    ),
  );
  
  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: backgroundDark,
    
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: darkBlue,
      surface: surfaceDark,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDark,
      onError: Colors.white,
    ),
    
    textTheme: GoogleFonts.robotoTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textDark),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textDark),
        titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textDark),
        bodyLarge: TextStyle(fontSize: 16, color: textDark),
        bodyMedium: TextStyle(fontSize: 14, color: textDark),
        bodySmall: TextStyle(fontSize: 12, color: textSecondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textDark),
      ),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDark,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textDark),
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    cardTheme: CardTheme(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: error),
      ),
    ),
    
    dividerTheme: const DividerThemeData(
      color: dividerDark,
      thickness: 1,
    ),
  );
}
