import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/helper/providers/tag_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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
                color: Colors.black.withOpacity(0.1),
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

String getDate(Timestamp time) {
  DateTime dateTime = time.toDate();
  String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

  return formattedDate;
}

List<Map<String, dynamic>> searchFun(BuildContext context, String input,
    {bool filter = false}) {
  var tag = Provider.of<TagProvider>(context, listen: false);
  Map<String, dynamic> tags = filter ? tag.filteredTags : tag.tags;

  List<Map<String, dynamic>> allReleases = [];

  tags.forEach((projectName, orders) {
    orders.forEach((orderName, releases) {
      for (var release in releases) {
        String formattedRelease =
            "$projectName - $orderName - ${release['release']}";
        allReleases.add({'name': formattedRelease, 'file': release['file']});
      }
    });
  });

  var sugg = allReleases
      .where((release) =>
          release['name'].toLowerCase().contains(input.toLowerCase()))
      .toList();

  return sugg;
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

void pr(Object? object) {
  if (kDebugMode) {
    print(object);
  }
}

String generateFileName(
    String projectName, String orderName, String releaseName) {
  return "$projectName-$orderName-$releaseName.xlsx";
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
