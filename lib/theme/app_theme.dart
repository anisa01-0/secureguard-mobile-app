import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds the Material 3 light and dark themes used across SecureGuard.
///
/// Keeping every visual decision in one file means the whole application can
/// be restyled from a single place, and every screen stays consistent.
class AppTheme {
  const AppTheme._();

  /// Corner radius used by cards, buttons, inputs and sheets.
  static const double radius = 18;
  static const double radiusSmall = 12;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final Color background = isDark
        ? AppColors.backgroundDark
        : AppColors.background;
    final Color surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final Color border = isDark ? AppColors.borderDark : AppColors.border;
    final Color textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final Color textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.blue : AppColors.navy,
      onPrimary: Colors.white,
      primaryContainer: isDark ? AppColors.navySoft : AppColors.blueSoft,
      onPrimaryContainer: isDark ? Colors.white : AppColors.navy,
      secondary: AppColors.blue,
      onSecondary: Colors.white,
      secondaryContainer: isDark
          ? AppColors.surfaceMutedDark
          : AppColors.blueSoft,
      onSecondaryContainer: isDark ? Colors.white : AppColors.navy,
      tertiary: AppColors.green,
      onTertiary: Colors.white,
      tertiaryContainer: isDark ? const Color(0xFF10402A) : AppColors.greenSoft,
      onTertiaryContainer: isDark ? Colors.white : const Color(0xFF0B5132),
      error: AppColors.red,
      onError: Colors.white,
      errorContainer: isDark ? const Color(0xFF4A1119) : AppColors.redSoft,
      onErrorContainer: isDark ? Colors.white : AppColors.redDark,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: isDark
          ? AppColors.surfaceMutedDark
          : AppColors.surfaceMuted,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: border,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: isDark ? AppColors.surface : AppColors.navy,
      onInverseSurface: isDark ? AppColors.textPrimary : Colors.white,
      inversePrimary: AppColors.blue,
    );

    final TextTheme textTheme = _textTheme(textPrimary, textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall + 2),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: scheme.primary,
          side: BorderSide(color: border, width: 1.4),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall + 2),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.secondary,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceMutedDark : AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.8)),
        labelStyle: TextStyle(color: textSecondary),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: _inputBorder(border),
        enabledBorder: _inputBorder(border),
        focusedBorder: _inputBorder(scheme.secondary, width: 1.8),
        errorBorder: _inputBorder(AppColors.red, width: 1.4),
        focusedErrorBorder: _inputBorder(AppColors.red, width: 1.8),
        errorStyle: const TextStyle(
          color: AppColors.red,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppColors.surfaceMutedDark
            : AppColors.surfaceMuted,
        side: BorderSide(color: border),
        labelStyle: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.surfaceMutedDark : AppColors.navy,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return isDark ? AppColors.textSecondaryDark : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) return AppColors.green;
          return isDark ? AppColors.borderDark : AppColors.surfaceMuted;
        }),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        textColor: textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: isDark ? AppColors.navySoft : AppColors.blueSoft,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
          final bool selected = s.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.primary : textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
          final bool selected = s.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? scheme.primary : textSecondary,
          );
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.secondary,
        linearTrackColor: border,
        circularTrackColor: border,
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          // iOS and macOS keep their native swipe-back transition.
          TargetPlatform.android: const FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: const FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: const FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1.2}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusSmall + 2),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -0.4,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: primary),
      bodyMedium: TextStyle(fontSize: 14.5, height: 1.5, color: secondary),
      bodySmall: TextStyle(fontSize: 13, height: 1.45, color: secondary),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: secondary,
        letterSpacing: 0.3,
      ),
    );
  }
}
