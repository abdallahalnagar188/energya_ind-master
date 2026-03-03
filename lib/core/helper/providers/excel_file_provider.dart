import 'dart:async';
import 'dart:io';
import 'package:energya_ind/core/helper/providers/tag_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class ExcelFileProvider with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool load = false;
  double prog = 0.0;
  bool startDown = false;

  Future<String> _createFolderIfNeeded(String path) async {
    final folder = Directory(path);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder.path;
  }

  //to save file in local storage locally or from server.
  Future<String> saveFileLocaly(
    context, {
    required String projectName,
    required String orderName,
    required String releaseName,
    FilePickerResult? result,
    String? firebasePath,
  }) async {
    projectName = projectName.replaceAll(' ', '');
    orderName = orderName.replaceAll(' ', '');
    releaseName = releaseName.replaceAll(' ', '');

    const String appFolderPath = '/storage/emulated/0/Energya';
    await _createFolderIfNeeded(appFolderPath);

    final projectFolderPath = '$appFolderPath/$projectName';
    await _createFolderIfNeeded(projectFolderPath);

    final orderFolderPath = '$projectFolderPath/$orderName';
    await _createFolderIfNeeded(orderFolderPath);

    final releaseFilePath =
        '$orderFolderPath/${generateFileName(projectName, orderName, releaseName)}';
    final releaseFile = File(releaseFilePath);

    if (await releaseFile.exists()) {
      pr('الفايل موجود بالفعل محلياََ:✅  $releaseFilePath');
      return releaseFilePath;
    }

    if (result != null) {
      final file = File(result.files.single.path!);
      await file.copy(releaseFilePath);
      pr('تم حفظ الملف محليًا من FilePicker: $releaseFilePath');
    } else if (firebasePath != null) {
      pr('⬇ الملف غير موجود محليًا، جارٍ تحميله من Firebase...');
      prog = 0.1;
      load = true;
      notifyListeners();

      String sanitizedPath = releaseFile.path.split('?').first;
      await downloadFileWithProgress(
        firebasePath: firebasePath,
        savePath: sanitizedPath,
        onProgress: (double progr) {
          pr("Download Progress: ${prog.toStringAsFixed(2)}%");
          notifyListeners();
        },
      );
    }
    return releaseFilePath;
  }

  Future<void> downloadFileWithProgress({
    required String firebasePath,
    required String savePath,
    required Function(double) onProgress,
    bool withProgress = true,
  }) async {
    if (withProgress) startDown = true;
    var httpClient = HttpClient();
    var request = await httpClient.getUrl(Uri.parse(firebasePath));
    var response = await request.close();

    int totalBytes = response.contentLength; // حجم الملف بالكامل
    int receivedBytes = 0; // حجم البيانات التي تم تحميلها

    List<int> bytes = [];
    var completer = Completer<void>();

    response.listen(
      (List<int> chunk) {
        bytes.addAll(chunk);
        receivedBytes += chunk.length;

        // حساب نسبة التقدم
        double progress = (receivedBytes / totalBytes) * 100;
        onProgress(progress);
      },
      onDone: () async {
        await File(savePath).writeAsBytes(bytes);
        completer.complete();
        if (withProgress) startDown = false;
      },
      onError: (error) {
        completer.completeError(error);
        if (withProgress) startDown = false;
      },
      cancelOnError: true,
    );
    load = false;
    notifyListeners();
    return completer.future;
  }

  Future<List<Map<String, dynamic>>> checkFilesIfinLocal(
    Map<String, dynamic> filteredTags,
  ) async {
    List<Map<String, dynamic>> fileStatusList = [];

    for (var projectEntry in filteredTags.entries) {
      String projectName = projectEntry.key;
      Map<String, List<Map<String, dynamic>>> ordersMap = projectEntry.value;

      for (var orderEntry in ordersMap.entries) {
        String orderName = orderEntry.key;
        List<Map<String, dynamic>> releases = orderEntry.value;

        for (var release in releases) {
          String releaseName = release['release'];
          String firebasePath =
              release['file']['filePath']; // المسار في Firebase

          String safeProjectName = projectName.replaceAll(' ', '');
          String safeOrderName = orderName.replaceAll(' ', '');
          String safeReleaseName = releaseName.replaceAll(' ', '');

          // تحديد المسار المحلي للفايل مع الامتداد
          String localFilePath =
              "/storage/emulated/0/Energya/$safeProjectName/$safeOrderName/$safeProjectName-$safeOrderName-$safeReleaseName.xlsx";

          File localFile = File(localFilePath);
          bool isLocal = await localFile.exists();

          pr(isLocal
              ? '✅ الملف موجود محليًا: $localFilePath'
              : '⬇️ الملف غير موجود، يحتاج إلى تحميل: $localFilePath');

          // إضافة بيانات الملف إلى القائمة
          fileStatusList.add({
            "isLocal": isLocal,
            "projectName": projectName,
            "orderName": orderName,
            "releaseName": releaseName,
            "firebasePath": firebasePath,
            "localFilePath": localFilePath, // إضافة المسار المحلي بعد التصحيح
          });
        }
      }
    }

    return fileStatusList;
  }

  //if local uploaded.
  Future<void> uploadAndSaveFile(
    context, {
    required String projectName,
    required String orderName,
    required String releaseName,
    required Function() init,
  }) async {
    try {
      if (await requestStoragePermission()) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );

        if (result != null) {
          String releaseFilePath = await saveFileLocaly(
            context,
            projectName: projectName,
            orderName: orderName,
            releaseName: releaseName,
            result: result,
          );
          pr('File saved successfully at: $releaseFilePath');

          String finalFileName =
              generateFileName(projectName, orderName, releaseName)
                  .replaceAll(' ', '');

          await _addFileToFirestore(
            project: projectName,
            order: orderName,
            release: releaseName,
            fileName: finalFileName, // تأكد أن الاسم يحتوي على الامتداد
            filePath: releaseFilePath,
          ).then((_) async {
            var tag = Provider.of<TagProvider>(context, listen: false);
            init();
            await tag.getAllTagsData();
            showTopSnackBar(context, 'تم رفع الفايل بنجاح', error: false);
          });
        } else {
          pr('لم يتم اختيار أي فايل.');
          showTopSnackBar(context, 'لم يتم اختيار أي فايل.', error: true);
        }
      } else {
        showPermissionAlert(context);
      }
      // اختيار الفايل من الجهاز
    } catch (e) {
      pr('حدث خطأ أثناء رفع الفايل: $e');
      showTopSnackBar(context, 'حدث خطأ أثناء رفع الفايل: $e', error: true);
    }
  }

  Future<void> _addFileToFirestore({
    required String project,
    required String order,
    required String release,
    required String fileName,
    required String filePath,
    bool allowReplace = false,
  }) async {
    load = true;
    notifyListeners();
    if (!fileName.endsWith(".xlsx")) {
      pr("❌ الملف ليس بصيغة xlsx");
      load = false;
      notifyListeners();
      return;
    }
    try {
      // الحصول على المرجعية للمشروع والـ order
      CollectionReference tagsCollection =
          FirebaseFirestore.instance.collection('tags');

      QuerySnapshot tagsSnapshot = await tagsCollection.get();
      String actualProjectId = tagsSnapshot.docs
          .firstWhere((doc) =>
              doc.id.replaceAll(' ', '') == project.replaceAll(' ', ''))
          .id;

      DocumentReference projectDoc = tagsCollection.doc(actualProjectId);

      QuerySnapshot ordersSnapshot =
          await projectDoc.collection('orders').get();
      String actualOrderId = ordersSnapshot.docs
          .firstWhere(
              (doc) => doc.id.replaceAll(' ', '') == order.replaceAll(' ', ''))
          .id;

      DocumentReference orderDoc =
          projectDoc.collection('orders').doc(actualOrderId);
      DocumentSnapshot orderSnapshot = await orderDoc.get();

      // Step 1: Upload file to Firebase Storage
      File file = File(filePath);
      String storagePath = 'files/$actualProjectId/$actualOrderId/$fileName';

      final fileUrl = await _uploadFileToFirebase(file, storagePath);
      pr('File uploaded successfully. File URL: $fileUrl');

      // استرجاع قائمة releases
      List<dynamic> releases = List.from(orderSnapshot['releases']);
      pr('rels: ${orderSnapshot['releases']}');
      pr('rels: $releases');

      Map<String, dynamic>? existingRelease;

      // التحقق إذا كان الـ release موجودًا
      for (var r in releases) {
        if (r['release'] == release) {
          existingRelease = Map<String, dynamic>.from(r);
          break;
        }
      }
      pr('existing: $existingRelease');

      // الحصول على الوقت الحالي
      var currentTime = Timestamp.now();

      if (existingRelease != null &&
          (existingRelease['file'] as Map).isNotEmpty) {
        if (!allowReplace) {
          pr('❌ هذا الإصدار يحتوي بالفعل على ملف، والاستبدال غير مسموح!');
          load = false;
          notifyListeners();
          return;
        }
        pr('⚠️ استبدال الملف القديم بملف جديد...');
      }
      if (existingRelease != null) {
        existingRelease['file'] = {
          'fileName': fileName,
          'filePath': fileUrl,
          'uploadedAt': currentTime,
        };
        _updateReleaseInFirestore(releases, existingRelease, orderDoc);
      } else {
        releases.add({
          'release': release,
          'file': {
            'fileName': fileName,
            'filePath': fileUrl,
            'uploadedAt': currentTime,
          },
        });
        _updateReleaseInFirestore(releases, null, orderDoc);
      }
      load = false;
      notifyListeners();
    } catch (e) {
      load = false;
      notifyListeners();
      pr('Error adding file to Firestore: $e');
    }
  }

  Future<String> _uploadFileToFirebase(File file, String storagePath) async {
    storage.FirebaseStorage stg = storage.FirebaseStorage.instance;
    final ref = stg.ref().child(storagePath);
    final uploadTask = ref.putFile(file);

    uploadTask.snapshotEvents.listen((event) {
      prog = (event.bytesTransferred.toDouble() / event.totalBytes.toDouble()) *
          100;
      load = prog != 100;
      notifyListeners();
    });

    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _updateReleaseInFirestore(
    List<dynamic> releases,
    Map<String, dynamic>? existingRelease,
    DocumentReference orderDoc,
  ) async {
    if (existingRelease != null) {
      for (int i = 0; i < releases.length; i++) {
        if (releases[i]['release'] == existingRelease['release']) {
          releases[i] = existingRelease;
          notifyListeners();
          break;
        }
      }
    }

    await orderDoc.update({'releases': releases});
    notifyListeners();
    pr('File added to the release successfully!');
  }
}
