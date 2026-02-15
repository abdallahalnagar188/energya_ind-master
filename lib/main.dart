import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/utils/global_functions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // تهيئة Firebase
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  await GlobalFunctions().checkFirstRunAndDeleteFolder();
  //SharedPreferences prefs = await SharedPreferences.getInstance();
  //prefs.remove('isFirstRun');
  runApp(const Energya());
}
/*
Future<void> checkFirstRunAndDeleteFolder() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isFirstRun = prefs.getBool('isFirstRun');

  if (isFirstRun == null) {
    print("🚀 التطبيق مثبت حديثًا أو بعد إلغاء التثبيت!");
    await requestStoragePermission();
    // حذف المجلد
    await deleteEnergyaFolderIfExists();

    // حفظ حالة التثبيت
    await prefs.setBool('isFirstRun', true);
  }
}

Future<void> deleteEnergyaFolderIfExists() async {
  String folderPath = "/storage/emulated/0/Energya";
  Directory directory = Directory(folderPath);

  if (directory.existsSync()) {
    try {
      directory.deleteSync(recursive: true);
      print("✔️ تم حذف المجلد بنجاح: $folderPath");
    } catch (e) {
      print("❌ خطأ أثناء حذف المجلد: $e");
    }
  } else {
    print("ℹ️ المجلد غير موجود، لا حاجة للحذف.");
  }
}
 */
