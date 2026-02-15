import 'package:energya_ind/core/config/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/helper/providers/app_settings_provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      var sets = context.read<AppSettingsProvider>();
      await sets.autoLogIn(context);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              fit: BoxFit.fill,
              AppStrings.logo,
              scale: 4,
            ),
          ],
        ),
      ),
    );
  }
}
