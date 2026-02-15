import 'dart:convert';
import 'package:energya_ind/core/config/app_strings.dart';
import 'package:energya_ind/core/utils/app_routers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../methods.dart';
import 'user_provider.dart';

class AppSettingsProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _load = false;
  bool get load => _load;

  bool _download = false;
  bool get download => _download;

  double _progress = 0.0;
  double get progress => _progress;
  //start loading into the page
  startLoad() {
    _load = true;
    notifyListeners();
  }

  //end loading from the page
  endLoad() {
    _load = false;
    notifyListeners();
  }

  //start loading into the page
  startDownload() {
    _download = true;
    notifyListeners();
  }

  //end loading from the page
  endDownload() {
    _download = false;
    notifyListeners();
  }

  loadProgress(prog) {
    _progress = prog * 100;
    _load = _progress != 100;
    notifyListeners();
  }

// Auto Login From Splash Screen -> direct to Home without authentication pages.
  Future<void> autoLogIn(BuildContext context) async {
    var prov = Provider.of<UserProvider>(context, listen: false);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String loginData = prefs.getString(AppStrings.userSavedKey) ?? '';

    pr('# user is logged before ? ${loginData != ''}');

    if (loginData != '') {
      _isLoggedIn = true;
      var body = jsonDecode(loginData);
      pr('login Data: $loginData');
      bool? shouldSign =
          await prov.loginUser(context, body['email'], body['password']);
      if (shouldSign == true) {
        Future.delayed(const Duration(seconds: 2), () {
          context.pushReplacement(AppRouters.kHomeView);
        });
      } else {
        Future.delayed(
          const Duration(seconds: 2),
          () {
            context.pushReplacement(AppRouters.kSignInPage);
          },
        );
      }

      return;
    } else {
      Future.delayed(
        const Duration(seconds: 2),
        () {
          if (context.mounted) {
            context.pushReplacement(AppRouters.kSignInPage);
          }
        },
      );
    }
  }
}
