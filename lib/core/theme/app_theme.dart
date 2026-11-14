import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import '../models/enums.dart' as enums;

class AppTheme {
  static ThemeData getTheme(enums.ThemeMode mode, enums.AccentColor accent) {
    final isDark = mode == enums.ThemeMode.dark;
    final accentColorData = _getAccentColor(accent);

    // Premium Slate Palette for Dark Mode
    const darkBackground = Color(0xFF0F172A); // Slate 900
    const darkSurface = Color(0xFF1E293B); // Slate 800
    const darkInputFill = Color(0xFF334155); // Slate 700
    const darkOnSurface = Color(0xFFF8FAFC); // Slate 50

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: accentColorData,
        onPrimary: Colors.white,
        secondary: accentColorData,
        onSecondary: Colors.white,
        error: Colors.red.shade400,
        onError: Colors.white,
        surface: isDark ? darkSurface : const Color(0xFFF3F4F6),
        onSurface: isDark ? darkOnSurface : const Color(0xFF111827),
      ),
      scaffoldBackgroundColor: isDark ? darkBackground : Colors.white,
      // iOS'ta yerel geri kaydırma hareketi ve yatay geçiş animasyonu
      // (Cupertino), Android'de ise platformun varsayılan geçişi kullanılır.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? darkBackground : Colors.white,
        foregroundColor:
            isDark ? darkOnSurface : const Color(0xFF111827),
        elevation: 0,
        surfaceTintColor: Colors.transparent, // Disable Material 3 tint
      ),
      cardTheme: CardThemeData(
        color: isDark ? darkSurface : const Color(0xFFF3F4F6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Increased radius
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColorData,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColorData,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkInputFill : const Color(0xFFE5E7EB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColorData, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  static Color _getAccentColor(enums.AccentColor accent) {
    switch (accent) {
      case enums.AccentColor.blue:
        return const Color(0xFF3B82F6);
      case enums.AccentColor.green:
        return const Color(0xFF22C55E);
      case enums.AccentColor.purple:
        return const Color(0xFFA855F7);
      case enums.AccentColor.orange:
        return const Color(0xFFF97316);
      case enums.AccentColor.teal:
        return const Color(0xFF14B8A6);
    }
  }
}
