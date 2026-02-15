import 'package:flutter/material.dart';

import 'app_colors.dart';

AppColors colors(context) => Theme.of(context).extension<AppColors>()!;
ThemeData getAppTheme({required BuildContext context}) {
  return ThemeData(
    useMaterial3: true,
    extensions: const <ThemeExtension<AppColors>>[
      AppColors(
        primaryColor: AppStaticColor.primary,
        dark: AppStaticColor.black,
        light: AppStaticColor.white,
        errorColor: AppStaticColor.red,
        textColor: AppStaticColor.black,
      ),
    ],
    scaffoldBackgroundColor: AppStaticColor.bg,
    
    unselectedWidgetColor: AppStaticColor.gray,
    expansionTileTheme: const ExpansionTileThemeData(),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppStaticColor.black,
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: AppStaticColor.bg,
    ),
  );
}
