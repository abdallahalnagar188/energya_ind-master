import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';

class GlobalFunctions {
//init functions at main
  Future<bool> _requestStoragePermission() async {
    if (await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      pr("Storage permission granted");
      return true;
    } else {
      pr("Storage permission denied");
      return false;
    }
  }

  Future<void> _deleteEnergyaFolderIfExists() async {
    String folderPath = "/storage/emulated/0/Energya";
    Directory directory = Directory(folderPath);

    if (directory.existsSync()) {
      try {
        directory.deleteSync(recursive: true);
        pr("✔️ تم حذف المجلد بنجاح: $folderPath");
      } catch (e) {
        pr("❌ خطأ أثناء حذف المجلد: $e");
      }
    } else {
      pr("ℹ️ المجلد غير موجود، لا حاجة للحذف.");
    }
  }

  Future<void> checkFirstRunAndDeleteFolder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstRun = prefs.getBool('isFirstRun');

    if (isFirstRun == null) {
      pr("🚀 التطبيق مثبت حديثًا أو بعد إلغاء التثبيت!");
      await _requestStoragePermission();
      // حذف المجلد
      await _deleteEnergyaFolderIfExists();
      // حفظ حالة التثبيت
      await prefs.setBool('isFirstRun', true);
    }
  }

  void showTopSnackBar(
    BuildContext context,
    String message, {
    bool error = true,
  }) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: error == false ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    // إضافة الـ OverlayEntry إلى أعلى الشاشة
    Overlay.of(context).insert(overlayEntry);

    // إزالة الـ Overlay بعد وقت معين
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  exitFun(context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "هل تريد الخروج من التطبيق؟",
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                  color: AppStaticColor.primary.withValues(alpha: .8),
                  border: Border.all(color: AppStaticColor.primary),
                  borderRadius: BorderRadius.circular(4)),
              alignment: Alignment.center,
              child: const Text(
                "لا",
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              exit(0);
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                  color: AppStaticColor.primary.withValues(alpha: .2),
                  border: Border.all(color: AppStaticColor.primary),
                  borderRadius: BorderRadius.circular(4)),
              alignment: Alignment.center,
              child: const Text(
                "إغلاق",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      pr("Storage permission granted");
      return true;
    } else {
      pr("Storage permission denied");
      return false;
    }
  }

  void showPermissionAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('الإذن مطلوب'),
          content: const Text(
            'هذا التطبيق يحتاج إلى إذن الوصول إلى التخزين لتتمكن من استخدام هذه الخاصية. '
            'يرجى السماح بالإذن من إعدادات الجهاز.',
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق التنبيه
              },
            ),
            TextButton(
              child: const Text('فتح الإعدادات'),
              onPressed: () {
                openAppSettings(); // فتح إعدادات التطبيق
                Navigator.of(context).pop(); // إغلاق التنبيه
              },
            ),
          ],
        );
      },
    );
  }

  String getAwesomeDate(Timestamp time) {
    DateTime dateTime = time.toDate();
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

    return formattedDate;
  }

  final TextStyle _positiveColorStyle =
      const TextStyle(color: Colors.red, fontSize: 18);
  final TextStyle _neg =
      TextStyle(color: Colors.black.withValues(alpha: .75), fontSize: 18);

  TextSpan searchMatch(String match, TextEditingController controller) {
    if (controller.text.toLowerCase().isEmpty) {
      return TextSpan(text: match, style: _neg);
    }
    var refinedMatch = match.toLowerCase();
    var refinedSearch = controller.text.toLowerCase();
    if (refinedMatch.contains(refinedSearch)) {
      if (refinedMatch.substring(0, refinedSearch.length) == refinedSearch) {
        return TextSpan(
          style: _positiveColorStyle,
          text: match.substring(0, refinedSearch.length),
          children: [
            searchMatch(
              match.substring(
                refinedSearch.length,
              ),
              controller,
            ),
          ],
        );
      } else if (refinedMatch.length == refinedSearch.length) {
        return TextSpan(text: match, style: _positiveColorStyle);
      } else {
        return TextSpan(
          style: _neg,
          text: match.substring(
            0,
            refinedMatch.indexOf(refinedSearch),
          ),
          children: [
            searchMatch(
              match.substring(
                refinedMatch.indexOf(refinedSearch),
              ),
              controller,
            ),
          ],
        );
      }
    } else if (!refinedMatch.contains(refinedSearch)) {
      return TextSpan(text: match, style: _neg);
    }
    return TextSpan(
      text: match.substring(0, refinedMatch.indexOf(refinedSearch)),
      style: _positiveColorStyle,
      children: [
        searchMatch(
          match.substring(refinedMatch.indexOf(refinedSearch)),
          controller,
        ),
      ],
    );
  }
}
