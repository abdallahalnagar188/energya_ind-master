import 'package:energya_ind/core/config/app_theme.dart';
import 'package:energya_ind/core/helper/providers/app_settings_provider.dart';
import 'package:energya_ind/core/helper/providers/excel_file_provider.dart';
import 'package:energya_ind/core/helper/providers/excel_provider.dart';
import 'package:energya_ind/export.dart';
import 'package:flutter/material.dart';

class Energya extends StatelessWidget {
  const Energya({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<TagProvider>(create: (_) => TagProvider()),
        ChangeNotifierProvider<ExcelProvider>(create: (_) => ExcelProvider()),
        ChangeNotifierProvider<AppSettingsProvider>(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider<ExcelFileProvider>(
            create: (_) => ExcelFileProvider()),
      ],
      child: MaterialApp.router(
        title: 'Energya',
        routerConfig: AppRouters.router,
        debugShowCheckedModeBanner: false,
        theme: getAppTheme(context: context),
      ),
    );
  }
}
