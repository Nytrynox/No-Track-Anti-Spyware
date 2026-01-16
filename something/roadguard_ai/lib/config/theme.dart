import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// RoadGuard AI - Premium Design System
/// Solid Colors Only - Human-Made Professional Design

// ─────────────────────────────────────────────────────────────────────────────
// SOLID COLOR PALETTE
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();
  
  // ── Primary Brand (Solid) ──
  static const Color primary = Color(0xFF2563EB);        // Blue-600
  static const Color primaryLight = Color(0xFF3B82F6);   // Blue-500
  static const Color primaryDark = Color(0xFF1D4ED8);    // Blue-700
  static const Color primarySoft = Color(0xFFDBEAFE);    // Blue-100
  
  // ── Backgrounds (Solid) ──
  static const Color background = Color(0xFFFFFFFF);     // Pure white
  static const Color backgroundAlt = Color(0xFFF8FAFC);  // Slate-50
  static const Color surface = Color(0xFFFFFFFF);        // Pure white
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  
  // ── Text ──
  static const Color textPrimary = Color(0xFF0F172A);    // Slate-900
  static const Color textSecondary = Color(0xFF475569);  // Slate-600
  static const Color textMuted = Color(0xFF94A3B8);      // Slate-400
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // ── Borders & Dividers ──
  static const Color border = Color(0xFFE2E8F0);         // Slate-200
  static const Color borderLight = Color(0xFFF1F5F9);    // Slate-100
  static const Color divider = Color(0xFFE2E8F0);
  
  // ── Status Colors (Solid) ──
  static const Color success = Color(0xFF16A34A);        // Green-600
  static const Color successLight = Color(0xFFDCFCE7);   // Green-100
  static const Color successDark = Color(0xFF15803D);    // Green-700
  
  static const Color warning = Color(0xFFD97706);        // Amber-600
  static const Color warningLight = Color(0xFFFEF3C7);   // Amber-100
  static const Color warningDark = Color(0xFFB45309);    // Amber-700
  
  static const Color danger = Color(0xFFDC2626);         // Red-600
  static const Color dangerLight = Color(0xFFFEE2E2);    // Red-100
  static const Color dangerDark = Color(0xFFB91C1C);     // Red-700
  
  static const Color info = Color(0xFF2563EB);           // Blue-600
  static const Color infoLight = Color(0xFFDBEAFE);      // Blue-100
  
  // ── Detection Colors (Solid) ──
  static const Color detectionClose = Color(0xFFDC2626);    // Red - < 5m
  static const Color detectionMedium = Color(0xFFD97706);   // Amber - 5-15m
  static const Color detectionFar = Color(0xFF16A34A);      // Green - > 15m
  
  // ── NO GRADIENTS - Solid backgrounds only ──
  // Use solid primary color instead of gradients
  static const Color heroBackground = Color(0xFF2563EB);    // Solid blue
  static const Color splashBackground = Color(0xFF2563EB);  // Solid blue
}

// ─────────────────────────────────────────────────────────────────────────────
// SPACING SYSTEM (4px base grid)
// ─────────────────────────────────────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
}

// ─────────────────────────────────────────────────────────────────────────────
// BORDER RADIUS
// ─────────────────────────────────────────────────────────────────────────────

class AppRadius {
  AppRadius._();
  
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;
  
  static BorderRadius get cardRadius => BorderRadius.circular(lg);
  static BorderRadius get buttonRadius => BorderRadius.circular(md);
  static BorderRadius get chipRadius => BorderRadius.circular(full);
}

// ─────────────────────────────────────────────────────────────────────────────
// SHADOWS
// ─────────────────────────────────────────────────────────────────────────────

class AppShadows {
  AppShadows._();
  
  static List<BoxShadow> get sm => [
    const BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get md => [
    const BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get lg => [
    const BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> glow(Color color, {double opacity = 0.25}) => [
    BoxShadow(
      color: color.withAlpha((opacity * 255).round()),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPOGRAPHY
// ─────────────────────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();
  
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.1,
  );
  
  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static TextStyle get displaySmall => GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );
  
  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );
  
  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get headlineSmall => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get titleSmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );
  
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );
  
  static TextStyle get button => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get buttonSmall => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME DATA
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();
  
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primarySoft,
        secondary: AppColors.textSecondary,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
        outline: AppColors.border,
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineSmall,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundAlt,
        border: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
      ),
      
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primarySoft,
      ),
    );
  }
  
  static ThemeData get lightTheme => light;
  static ThemeData get darkTheme => light;
}
