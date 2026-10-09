import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Premium Dark Color Palette
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkSurfaceVariant = Color(0xFF21262D);
  static const Color darkCard = Color(0xFF1B222D);
  static const Color darkBorder = Color(0xFF30363D);

  // Accent & Brand Colors
  static const Color primary = Color(0xFF3861FB); // CoinGecko/CoinMarketCap style vibrant blue
  static const Color primaryLight = Color(0xFF6C8CFF);
  static const Color secondary = Color(0xFF8DC63F); // Gecko green
  static const Color accentCyan = Color(0xFF00D2FF);

  // Financial Indicators
  static const Color gainGreen = Color(0xFF16C784); // Bullish green
  static const Color gainGreenSoft = Color(0x1F16C784);
  static const Color lossRed = Color(0xFFEA3943); // Bearish red
  static const Color lossRedSoft = Color(0x1FEA3943);
  static const Color neutralGray = Color(0xFF858CA2);

  // Text Colors
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF6E7681);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3861FB), Color(0xFF6C8CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C222C), Color(0xFF141922)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenChartGradient = LinearGradient(
    colors: [Color(0x5516C784), Color(0x0016C784)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient redChartGradient = LinearGradient(
    colors: [Color(0x55EA3943), Color(0x00EA3943)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: darkSurface,
        surfaceContainerHighest: darkSurfaceVariant,
        error: lossRed,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryLight,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
