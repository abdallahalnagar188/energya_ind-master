import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/config/app_strings.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/user_provider.dart';
import 'package:energya_ind/core/helper/validations.dart';
import 'package:energya_ind/core/models/authority_model.dart';
import 'package:energya_ind/core/models/user_model.dart';
import 'package:energya_ind/core/utils/app_routers.dart';
import 'package:energya_ind/core/utils/directions.dart';
import 'package:energya_ind/core/utils/extentions.dart';
import 'package:energya_ind/core/utils/styles.dart';
import 'package:energya_ind/core/widgets/custom_navigation_button.dart';
import 'package:energya_ind/core/widgets/progress.dart';
import 'package:energya_ind/frontend/home/widgets/text_feilds.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController authoController = TextEditingController();
  int dir = -1;
  Map<String, dynamic> selectedAutho = {};
  GlobalKey<FormState> key = GlobalKey();
  bool invalidAutho = false;
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 22,
            color: AppStaticColor.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ListView(
                children: [
                  //top design
                  Column(
                    children: [
                      SizedBox(
                        height: context.height * 0.03,
                      ),
                      Image.asset(
                        fit: BoxFit.fill,
                        AppStrings.logo,
                        scale: 5,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  //fields
                  Form(
                    key: key,
                    child: Column(
                      children: [
                        TextFeild(
                          prefixIcon: Icons.person,
                          hintText: 'Enter your full name',
                          controller: nameController,
                          onFieldSubmitted: (name) {
                            key.currentState!.validate();
                          },
                          onChanged: (name) {
                            key.currentState!.validate();
                          },
                          validator: (name) {
                            return AppValidator.requiredField(
                                context, name ?? '');
                          },
                        ),
                        const SizedBox(height: 8),
                        /*  popMeuItemsForPops(
                          context,
                          onSelected: (v) {
                            setState(() {
                              selectedAutho = v;
                              invalidAutho = false;
                            });
                          },
                          child: TextFeild(
                            prefixIcon: Icons.article,
                            hintText: selectedAutho.isEmpty
                                ? 'Choose Authority'
                                : selectedAutho['autho'],
                            enabled: false,
                            readOnly: true,
                            suffix: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.arrow_downward_rounded,
                              ),
                            ),
                            controller: authoController,
                          ),
                        ),
                        if (invalidAutho == true)
                          const Row(
                            children: [
                              Text(
                                'please select your authority',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ), */
                        const SizedBox(height: 8),
                        TextFeild(
                          textInputType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail,
                          hintText: 'Enter your Email',
                          controller: emailController,
                          onFieldSubmitted: (email) {
                            key.currentState!.validate();
                          },
                          onChanged: (email) {
                            key.currentState!.validate();
                          },
                          validator: (email) {
                            return AppValidator.emailVaidator(
                                context, email ?? '');
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFeild(
                          textInputType: TextInputType.phone,
                          prefixIcon: Icons.phone,
                          hintText: 'Enter your phone',
                          controller: phoneController,
                          onFieldSubmitted: (phone) {
                            key.currentState!.validate();
                          },
                          onChanged: (phone) {
                            key.currentState!.validate();
                          },
                          validator: (phone) {
                            return AppValidator.phoneVaidator(
                                context, phone ?? '');
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFeild(
                          suffixIcon: Icons.visibility_off,
                          prefixIcon: Icons.lock,
                          hintText: 'password',
                          controller: passController,
                          onFieldSubmitted: (ipt) {
                            key.currentState!.validate();
                          },
                          onChanged: (ipt) {
                            key.currentState!.validate();
                          },
                          validator: (ipt) {
                            return AppValidator.passFieldValidator(
                                context, ipt ?? '');
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFeild(
                          suffixIcon: Icons.visibility_off,
                          prefixIcon: Icons.lock,
                          hintText: 'Confirm password',
                          onFieldSubmitted: (ipt) {
                            key.currentState!.validate();
                          },
                          onChanged: (ipt) {
                            key.currentState!.validate();
                          },
                          validator: (ipt) {
                            if (ipt != passController.text) {
                              return 'Password is not match';
                            }
                            return AppValidator.passFieldValidator(
                                context, ipt ?? '');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: CustomNavigatorButton(
                      buttonName: 'Sign Up',
                      nextRoutName: AppRouters.kHomeView,
                      borderRadius: 40,
                      onTap: () async {
                        setState(() {
                          invalidAutho = false;
                        });
                        if (key.currentState!.validate()) {
                          UserModel newUser = UserModel(
                            name: nameController.text,
                            email: emailController.text,
                            password: passController.text,
                            phone: phoneController.text,
                            createdAt: Timestamp.now(),
                            authorities: AuthorityModel.authos
                                .map(
                                  (auth) => AuthorityModel(
                                    name: auth.name,
                                    dir: auth.dir,
                                    isActive: false,
                                  ),
                                )
                                .toList(),
                            type: 'user',
                          );
                          pr(newUser.toJson());
                          bool shouldRegister =
                              await user.registerUser(context, newUser);
                          if (shouldRegister) {
                            context.NavigatereplaceTo(AppRouters.kHomeView,
                                extra: newUser);
                          }
                        }
                        if (selectedAutho.isEmpty) {
                          setState(() {
                            invalidAutho = true;
                          });
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'already have an account ',
                        style: Styles.textStyle16600,
                      ),
                      GestureDetector(
                        onTap: () =>
                            context.NavigatePopTo(AppRouters.kSignInPage),
                        child: Text(
                          'SiGN IN',
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
