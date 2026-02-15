import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energya_ind/core/config/app_strings.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/models/user_model.dart';
import 'package:energya_ind/core/utils/app_routers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  bool load = false;
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel userModel) {
    _user = userModel;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  Future<bool> saveUser(String user) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(AppStrings.userSavedKey, user);
  }

  Future<void> removeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStrings.userSavedKey);
  }

  Future<bool> registerUser(context, UserModel userModel) async {
    load = true;
    notifyListeners();
    pr(userModel.toJson());

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userModel.email,
        password: userModel.password,
      );

      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .set(userModel.toMap());
      }
      pr("User registered successfully!");
      load = false;
      notifyListeners();
      setUser(userModel);
      showTopSnackBar(context, '${userModel.name} registered successfully!',
          error: false);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        pr('The password provided is too weak.');
        showTopSnackBar(context, 'The password provided is too weak.');
        load = false;
        notifyListeners();
      } else if (e.code == 'email-already-in-use') {
        pr('The account already exists for that email.');
        showTopSnackBar(context, 'The account already exists for that email.');
        load = false;
        notifyListeners();
      }
      load = false;
      notifyListeners();
      return false;
    } catch (e) {
      pr("Error: $e");
      load = false;
      notifyListeners();
      showTopSnackBar(context, 'Register Failed, Try Again !!');
      return false;
    }
  }

  Future<bool> loginUser(context, String email, String password) async {
    load = true;
    notifyListeners();

     try {
    // تسجيل الدخول في Firebase Authentication
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // الحصول على UID المستخدم
    String? userId = userCredential.user?.uid;
    if (userId == null) {
      load = false;
      notifyListeners();
      showTopSnackBar(context, 'No there user found !!');
    }

    // جلب بيانات المستخدم من Firestore
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      load = false;
      notifyListeners();
      showTopSnackBar(context, "User data not found in Firestore");
    }

    pr('🧰 ${userDoc.data()}');
    // تحويل البيانات إلى UserModel
    UserModel userModel =
        UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

    await saveUser(jsonEncode(userModel.toMap()));
    setUser(userModel);

    showTopSnackBar(context, 'signing successfully !!', error: false);

    load = false;
    notifyListeners();
    return true;
      } catch (e) {
      load = false;
      notifyListeners();
      pr("Error: $e");
      return false;
    } 
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await removeUser();
      clearUser();
      GoRouter.of(context).go(AppRouters.kSignInPage);
      pr("User logged out successfully!");
    } catch (e) {
      pr("Error during logout: $e");
    }
  }
}
