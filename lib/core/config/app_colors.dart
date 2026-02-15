import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color? primaryColor;
  final Color? light;
  final Color? dark;
  final Color? textColor;
  final Color? errorColor;

  const AppColors({
    required this.primaryColor,
    required this.light,
    required this.dark,
    required this.textColor,
    required this.errorColor,
  });

  @override
  AppColors copyWith({
    Color? primaryColor,
    Color? light,
    Color? dark,
    Color? textColor,
    Color? errorColor,
  }) {
    return AppColors(
      primaryColor: primaryColor ?? this.primaryColor,
      light: light ?? this.light,
      dark: dark ?? this.dark,
      textColor: textColor ?? this.textColor,
      errorColor: errorColor ?? this.errorColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t),
      light: Color.lerp(light, other.light, t),
      dark: Color.lerp(dark, other.dark, t),
      textColor: Color.lerp(textColor, other.textColor, t),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
    );
  }
}

class AppStaticColor {
  static const Color white = Color(0xFFFFFFFF);
  static const Color green = Color(0xFF168D4D);
  static const Color primary = Color(0xff0152A1);

  static const Color bg = Color(0xFFF5F5F5);
  static const Color red = Color(0xFFD20101);
  static const Color gray = Color(0xFFEEEFF1);
  static const Color darkGray = Color(0xFF464343);
  static const Color black = Color(0xFF0C0C0D);
  static const Color text = Color(0xFFA5A5A5);
}
