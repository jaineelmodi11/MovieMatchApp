import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bold dark design language for MovieMatch.
class AppColors {
  static const Color bg = Color(0xFF0B0B10);
  static const Color surface = Color(0xFF16161F);
  static const Color surfaceAlt = Color(0xFF1E1E2A);
  static const Color primary = Color(0xFFFF3B5C); // vivid pink-red
  static const Color secondary = Color(0xFF7C5CFF); // electric violet
  static const Color like = Color(0xFF2BD9A0);
  static const Color pass = Color(0xFFFF5470);
  static const Color textPrimary = Color(0xFFF5F5FA);
  static const Color textSecondary = Color(0xFF9A9AB0);

  static const LinearGradient brand = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient posterScrim = LinearGradient(
    colors: [Colors.transparent, Color(0xE6000000)],
    begin: Alignment.center,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}

/// Reusable rounded radii / spacing.
class AppRadii {
  static const double card = 22;
  static const double tile = 16;
  static const double chip = 10;
}
