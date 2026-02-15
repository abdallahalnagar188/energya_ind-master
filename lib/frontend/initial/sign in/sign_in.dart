import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/config/app_strings.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/user_provider.dart';
import 'package:energya_ind/core/utils/app_routers.dart';
import 'package:energya_ind/core/utils/extentions.dart';
import 'package:energya_ind/core/utils/styles.dart';
import 'package:energya_ind/core/widgets/custom_navigation_button.dart';
import 'package:energya_ind/core/widgets/progress.dart';
import 'package:energya_ind/frontend/home/widgets/text_feilds.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  TextEditingController passController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ListView(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Center(
                          child: Image.asset(
                            fit: BoxFit.fill,
                            AppStrings.logo,
                            scale: 4,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 48),
                        child: Row(
                          children: [
                            Text(
                              "Sign In",
                              style: TextStyle(
                                  fontSize: 26,
                                  color: AppStaticColor.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFeild(
                    prefixIcon: Icons.mail,
                    hintText: 'Email',
                    textInputType: TextInputType.emailAddress,
                    controller: emailController,
                  ),
                  const SizedBox(height: 12),
                  TextFeild(
                    suffixIcon: Icons.visibility_off,
                    prefixIcon: Icons.lock,
                    hintText: 'password',
                    controller: passController,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: const Text('Forgot Password ?',
                              style: Styles.textStyle16600),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: CustomNavigatorButton(
                      buttonName: 'Sign in',
                      nextRoutName: AppRouters.kHomeView,
                      borderRadius: 40,
                      onTap: () async {
                        bool shouldSign = await user.loginUser(
                            context, emailController.text, passController.text);
                        if (shouldSign == true) {
                          context.NavigatereplaceTo(AppRouters.kHomeView);
                        } else {
                          showTopSnackBar(context, 'Failed to Sign in !!');
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'don\'t have an account  ',
                        style: Styles.textStyle16600,
                      ),
                      GestureDetector(
                        onTap: () =>
                            context.NavigatePushTo(AppRouters.kregisterPage),
                        child: Text(
                          'SiGN UP',
                          style: Styles.textStyle16600.copyWith(
                              color:
                                  AppStaticColor.primary.withValues(alpha: 1)),
                        ),
                      )
                    ],
                  )
                ],
              ),
              if (user.load == true) progress(),
            ],
          ),
        ),
      ),
    );
  }
}
