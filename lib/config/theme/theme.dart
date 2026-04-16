import 'package:efiling_balochistan/config/theme/app_bar_theme.dart';
import 'package:efiling_balochistan/config/theme/bottom_nav_bar_theme.dart';
import 'package:efiling_balochistan/config/theme/chip_theme.dart';
import 'package:efiling_balochistan/config/theme/elevated_button_theme.dart';
import 'package:efiling_balochistan/config/theme/outline_button_theme.dart';
import 'package:efiling_balochistan/config/theme/text_button_theme.dart';
import 'package:efiling_balochistan/config/theme/text_field_theme.dart';
import 'package:efiling_balochistan/config/theme/text_theme.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import 'check_box_theme.dart';

/// App-specific colors that don't map cleanly to Material 3's [ColorScheme].
/// Access via `context.appColors.<name>` (see extension below).
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.primaryLight,
    required this.primaryDark,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.accent,
    required this.cardColor,
    required this.cardColorLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.disabled,
    required this.success,
    required this.warning,
    required this.info,
    required this.gradientStart,
    required this.gradientEnd,
    required this.surfaceMuted,
    required this.border,
    required this.shadow,
  });

  final Color primaryLight;
  final Color primaryDark;
  final Color secondaryLight;
  final Color secondaryDark;
  final Color accent;
  final Color cardColor;
  final Color cardColorLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color disabled;
  final Color success;
  final Color warning;
  final Color info;
  final Color gradientStart;
  final Color gradientEnd;
  final Color surfaceMuted;
  final Color border;
  final Color shadow;

  @override
  AppColorsExtension copyWith({
    Color? primaryLight,
    Color? primaryDark,
    Color? secondaryLight,
    Color? secondaryDark,
    Color? accent,
    Color? cardColor,
    Color? cardColorLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? disabled,
    Color? success,
    Color? warning,
    Color? info,
    Color? gradientStart,
    Color? gradientEnd,
    Color? surfaceMuted,
    Color? border,
    Color? shadow,
  }) {
    return AppColorsExtension(
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      secondaryDark: secondaryDark ?? this.secondaryDark,
      accent: accent ?? this.accent,
      cardColor: cardColor ?? this.cardColor,
      cardColorLight: cardColorLight ?? this.cardColorLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      disabled: disabled ?? this.disabled,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColorsExtension lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      secondaryLight: Color.lerp(secondaryLight, other.secondaryLight, t)!,
      secondaryDark: Color.lerp(secondaryDark, other.secondaryDark, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      cardColorLight: Color.lerp(cardColorLight, other.cardColorLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}

class AppTheme {
  AppTheme._();

  static const fontFamily = 'Mako';

  // Dark-mode surface palette — deep navy tones. Each level gets slightly
  // lighter so bg < surface < card < cardLight reads but cards still feel
  // like a very dark navy blue rather than a washed-out blue.
  static const Color _darkBackground = Color(0xFF030812);
  static const Color _darkSurface = Color(0xFF061224);
  static const Color _darkCard = Color(0xFF0A1B36);
  static const Color _darkSurfaceHigh = Color(0xFF0F2446);
  static const Color _darkCardLight = Color(0xFF142D55);
  static const Color _darkBorder = Color(0xFF1E3D6B);
  static const Color _darkTextPrimary = Color(0xFFE5E7EB);
  static const Color _darkTextSecondary = Color(0xFF9CA3AF);
  static const Color _darkDisabled = Color(0xFF4B5563);

  // Shared semantic palette.
  static const Color _successLight = Color(0xFF2AC18C);
  static const Color _successDark = Color(0xFF34D399);
  static const Color _warningLight = Color(0xFFF59E0B);
  static const Color _warningDark = Color(0xFFFBBF24);
  static const Color _infoLight = AppColors.secondary;
  static const Color _infoDark = AppColors.secondaryLight;
  static const Color _lightBorder = Color(0xFFE5E7EB);
  // Neutral surface tones for light mode. Cards sit a step above the scaffold
  // background (#F5F8FA) so they stand out instead of merging.
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightCardHigh = Color(0xFFFAFBFD);

  static const AppColorsExtension _lightAppColors = AppColorsExtension(
    primaryLight: AppColors.primaryLight,
    primaryDark: AppColors.primaryDark,
    secondaryLight: AppColors.secondaryLight,
    secondaryDark: AppColors.secondaryDark,
    accent: AppColors.accent,
    cardColor: _lightCard,
    cardColorLight: _lightCardHigh,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    disabled: AppColors.disabled,
    success: _successLight,
    warning: _warningLight,
    info: _infoLight,
    gradientStart: AppColors.secondaryDark,
    gradientEnd: AppColors.secondaryLight,
    surfaceMuted: AppColors.appBarColor,
    border: _lightBorder,
    shadow: Color(0x22000000),
  );

  static const AppColorsExtension _darkAppColors = AppColorsExtension(
    primaryLight: AppColors.primaryLight,
    primaryDark: AppColors.primaryDark,
    secondaryLight: AppColors.secondaryLight,
    secondaryDark: AppColors.secondaryDark,
    accent: Colors.white,
    cardColor: _darkCard,
    cardColorLight: _darkCardLight,
    textPrimary: _darkTextPrimary,
    textSecondary: _darkTextSecondary,
    disabled: _darkDisabled,
    success: _successDark,
    warning: _warningDark,
    info: _infoDark,
    gradientStart: AppColors.secondaryDark,
    gradientEnd: _darkBackground,
    surfaceMuted: _darkSurface,
    border: _darkBorder,
    shadow: Color(0x66000000),
  );

  static ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.accent,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.accent,
      secondaryContainer: AppColors.secondaryLight,
      onSecondaryContainer: AppColors.secondaryDark,
      tertiary: AppColors.secondaryDark,
      onTertiary: AppColors.accent,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
      surfaceContainer: _lightCard,
      surfaceContainerHigh: _lightCardHigh,
      surfaceContainerHighest: AppColors.appBarColor,
      onSurfaceVariant: AppColors.textSecondary,
      outline: _lightBorder,
      outlineVariant: AppColors.disabled,
      error: AppColors.error,
      onError: AppColors.accent,
      inversePrimary: AppColors.accent,
      shadow: Colors.black26,
    ),
    primaryColorDark: AppColors.primaryDark,
    cardColor: _lightCard,
    dividerColor: _lightBorder,
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    textTheme: AppTextTheme.lightTextTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: AppOutlineButtonTheme.lightOutlinedButtonTheme,
    textButtonTheme: AppTextButtonTheme.lightTextButtonTheme,
    appBarTheme: AppAppBarTheme.lightAppBarTheme,
    checkboxTheme: AppCheckBoxTheme.lightCheckboxTheme,
    chipTheme: AppChipTheme.lightChipTheme,
    inputDecorationTheme: AppTextFieldTheme.inputDecorationTheme,
    bottomNavigationBarTheme: BottomNavBarTheme.lightNavbarTheme,
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _lightCard,
      surfaceTintColor: _lightCard,
      modalBackgroundColor: _lightCard,
      modalBarrierColor: Color(0x4D000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryDark,
    ),
    dividerTheme: const DividerThemeData(
      color: _lightBorder,
      thickness: 1,
      space: 1,
    ),
    extensions: const <ThemeExtension<dynamic>>[_lightAppColors],
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBackground,
    canvasColor: _darkBackground,
    dialogTheme: const DialogThemeData(backgroundColor: _darkSurface),
    cardColor: _darkCard,
    dividerColor: _darkBorder,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryDark,
      onSecondaryContainer: AppColors.secondaryLight,
      tertiary: AppColors.secondaryLight,
      onTertiary: Colors.white,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      surfaceContainer: _darkCard,
      surfaceContainerHigh: _darkSurfaceHigh,
      surfaceContainerHighest: _darkCardLight,
      onSurfaceVariant: _darkTextSecondary,
      outline: _darkBorder,
      outlineVariant: _darkDisabled,
      error: AppColors.error,
      onError: Colors.white,
      shadow: Colors.black,
    ),
    primaryColorDark: AppColors.primaryDark,
    textTheme: AppTextTheme.darkTextTheme,
    iconTheme: const IconThemeData(color: _darkTextPrimary),
    elevatedButtonTheme: AppElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: AppOutlineButtonTheme.darkOutlinedButtonTheme,
    textButtonTheme: AppTextButtonTheme.darkTextButtonTheme,
    appBarTheme: AppAppBarTheme.darkAppBarTheme.copyWith(
      backgroundColor: _darkBackground,
      foregroundColor: _darkTextPrimary,
      iconTheme: const IconThemeData(color: _darkTextPrimary, size: 24),
      actionsIconTheme:
          const IconThemeData(color: _darkTextPrimary, size: 24),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _darkTextPrimary,
      ),
      toolbarTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _darkTextPrimary,
      ),
    ),
    checkboxTheme: AppCheckBoxTheme.darkCheckboxTheme,
    chipTheme: AppChipTheme.darkChipTheme,
    inputDecorationTheme: AppTextFieldTheme.inputDecorationThemeDark.copyWith(
      fillColor: _darkSurface,
    ),
    bottomNavigationBarTheme: BottomNavBarTheme.darkNavbarTheme.copyWith(
      backgroundColor: _darkBackground,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _darkSurface,
      surfaceTintColor: _darkSurface,
      modalBackgroundColor: _darkSurface,
      modalBarrierColor: Color(0x99000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: _darkSurface,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: _darkTextSecondary,
      textColor: _darkTextPrimary,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
    dividerTheme: const DividerThemeData(
      color: _darkBorder,
      thickness: 1,
      space: 1,
    ),
    extensions: const <ThemeExtension<dynamic>>[_darkAppColors],
  );
}
