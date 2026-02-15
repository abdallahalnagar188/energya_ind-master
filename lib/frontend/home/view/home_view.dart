import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/user_provider.dart';
import 'package:energya_ind/frontend/home/widgets/drawar.dart';
import 'package:energya_ind/frontend/home/widgets/home_view_boby.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, result) async {
        exitFun(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppStaticColor.primary.withValues(alpha: 0.5),
          title: Text(
            'Welcome ${user.user?.name ?? ''}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        extendBody: true,
        body: const SafeArea(
          child: HomeViewBody(),
        ),
        endDrawer: const CustomDrawar(),
      ),
    );
  }
}
