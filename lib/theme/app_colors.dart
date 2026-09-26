import 'package:flutter/material.dart';

/// Central colour palette for SecureGuard.
///
/// The palette follows the branding rules of the project:
///  * Deep navy  -> trust, security, general branding
///  * Red        -> emergency actions ONLY (never used as a page background)
///  * Green      -> safe / confirmed states
///  * Amber      -> warnings and "attention needed" states
///  * Light grey -> page backgrounds and secondary surfaces
class AppColors {
  const AppColors._();

  // ---------------------------------------------------------------- Brand
  static const Color navy = Color(0xFF0D1B39);
  static const Color navyDeep = Color(0xFF07122A);
  static const Color navySoft = Color(0xFF1B2F57);
  static const Color blue = Color(0xFF2563EB);
  static const Color blueSoft = Color(0xFFE8EFFC);

  // ------------------------------------------------------------ Emergency
  static const Color red = Color(0xFFE11D2E);
  static const Color redDark = Color(0xFFA5101D);
  static const Color redSoft = Color(0xFFFDECEE);

  // ----------------------------------------------------------------- Safe
  static const Color green = Color(0xFF15A05A);
  static const Color greenSoft = Color(0xFFE6F6ED);

  // -------------------------------------------------------------- Warning
  static const Color amber = Color(0xFFC77700);
  static const Color amberSoft = Color(0xFFFDF2E2);

  // ------------------------------------------------------- Light neutrals
  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEFF2F7);
  static const Color border = Color(0xFFE1E6EF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF5B6478);

  // -------------------------------------------------------- Dark neutrals
  static const Color backgroundDark = Color(0xFF080F20);
  static const Color surfaceDark = Color(0xFF111C33);
  static const Color surfaceMutedDark = Color(0xFF17243F);
  static const Color borderDark = Color(0xFF26344F);
  static const Color textPrimaryDark = Color(0xFFF2F5FA);
  static const Color textSecondaryDark = Color(0xFFA3AEC4);

  /// Keeps an accent colour readable on whichever surface it is drawn on.
  ///
  /// Several accents (navy above all) are deliberately dark so they stand out
  /// on the light theme, but they disappear against the dark theme's almost
  /// black surfaces. In dark mode this lightens any accent that is too dark,
  /// leaving colours that already have enough contrast untouched.
  static Color adaptive(BuildContext context, Color color) {
    if (Theme.of(context).brightness == Brightness.light) return color;
    final HSLColor hsl = HSLColor.fromColor(color);
    if (hsl.lightness >= 0.42) return color;
    return hsl
        .withLightness(0.62)
        .withSaturation(hsl.saturation.clamp(0.35, 1.0))
        .toColor();
  }

  /// Gradient used by the splash screen, the SOS button and brand headers.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[navySoft, navyDeep],
  );

  /// Gradient used exclusively for emergency (SOS) surfaces.
  static const LinearGradient emergencyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[red, redDark],
  );
}
