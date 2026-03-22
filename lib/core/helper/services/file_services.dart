import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energya_ind/core/config/app_strings.dart';
import 'package:energya_ind/core/utils/global_functions.dart';
import 'package:energya_ind/export.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:path_provider/path_provider.dart';
import 'package:energya_ind/core/models/authority_model.dart';
import '../methods.dart';

class FileServices {
  String generateFileName(
      String projectName, String orderName, String releaseName) {
    return "$projectName-$orderName-$releaseName.xlsx";
  }

  Future<String> getStoragePath(String projectName, String orderName) async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String folderPath = "${appDirectory.path}/$projectName/$orderName";
    return await createFolderIfNeeded(folderPath);
  }

  Future<String> createFolderIfNeeded(String path) async {
    final folder = Directory(path);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    print(folder.path);
    return folder.path;
  }

  Future<String?> uploadFileToFirebaseWithProgress(
    File file,
    String storagePath, {
    required Function(double) loadProgress,
  }) async {
    storage.FirebaseStorage stg = storage.FirebaseStorage.instance;
    final ref = stg.ref().child(storagePath);
    print('#$storagePath');
    if (!file.existsSync()) {
      pr('❌ الملف غير موجود محليًا: ${file.path}');
      return null;
    }

    final uploadTask = ref.putFile(file);

    uploadTask.snapshotEvents.listen((event) {
      loadProgress(
          (event.bytesTransferred.toDouble() / event.totalBytes.toDouble()));
    });

    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> downloadFileWithProgress({
    required String firebasePath,
    required String savePath,
    required Function(double) onProgress,
    bool withProgress = true,
    required Function() startDownLoad,
    required Function() endDownLoad,
  }) async {
    if (withProgress) {
      startDownLoad();
    }
    print(firebasePath);
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
        if (withProgress) {
          endDownLoad();
        }
      },
      onError: (error) {
        completer.completeError(error);
        if (withProgress) {
          endDownLoad();
        }
      },
      cancelOnError: true,
    );
    return completer.future;
  }

  String generateLocalFilePath(String project, String order, String release) {
    String safeProjectName = project.replaceAll(' ', '');
    String safeOrderName = order.replaceAll(' ', '');
    String safeReleaseName = release.replaceAll(' ', '');

    return '${AppStrings.appFolderPath}/$safeProjectName/$safeOrderName/${generateFileName(safeProjectName, safeOrderName, safeReleaseName)}';
  }

  Future<List<List<String>>> readExcelFile({
    required File? updatedFile,
    required String selectedFileLocalPath,
  }) async {
    if (updatedFile == null) {
      print("❌ فشل تحميل الملف، تأكدي من مساره.");
      return [];
    }

    if (!updatedFile.path.endsWith('.xlsx')) {
      print('❌ الملف ليس بصيغة .xlsx: ${updatedFile.path}');
      return [];
    }

    List<List<String>> tempData = [];

    var bytes = await updatedFile.readAsBytes();
    print('📂 حجم الملف: ${bytes.length} بايت');

    if (bytes.length < 100) {
      print('❌ الملف صغير جدًا وقد يكون غير صالح.');
      return [];
    }

    var excel = Excel.decodeBytes(bytes);
    try {
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];

        // تحويل الصفوف إلى List<List<String>>
        List<List<String>> rows = sheet!.rows.map((row) {
          return row.map((cell) {
            if (cell == null || cell.value == null) return "-";
            String value = cell.value.toString().trim();
            return value.isEmpty ? "-" : value;
          }).toList();
        }).toList();

        // تحديد الأعمدة الفارغة
        Set<int> columnsToRemove = {};
        for (int col = 0; col < rows[0].length; col++) {
          bool isColumnEmpty = true;
          for (int row = 0; row < rows.length; row++) {
            if (rows[row][col] != "-") {
              isColumnEmpty = false;
              break;
            }
          }
          if (isColumnEmpty) {
            columnsToRemove.add(col);
          }
        }

        // حذف الأعمدة الفارغة من الشيت
        for (int col in columnsToRemove.toList().reversed) {
          sheet.removeColumn(col);
        }

        // تحديث tempData بعد حذف الأعمدة الفارغة
        tempData = sheet.rows.map((row) {
          return row.map((cell) {
            if (cell == null || cell.value == null) return "-";
            String value = cell.value.toString().trim();
            return value.isEmpty ? "-" : value;
          }).toList();
        }).toList();
      }

      return tempData;
    } catch (e) {
      print('❌ خطأ أثناء تحليل ملف Excel: $e');
      return [];
    } finally {
      // حفظ التغييرات في الملف المحلي
      final file = File(selectedFileLocalPath);
      final bytes = excel.encode();
      file.writeAsBytesSync(bytes!);
      pr("🗣 fileRows ${tempData[0]} - ${tempData[0].length}");
      pr('✔︎ Changes saved to local file');
    }
  }

  Future<List<List<String>>> readReportExcelFile({
    required File? updatedFile,
    required String selectedFileLocalPath,
  }) async {
    if (updatedFile == null) {
      print("❌ فشل تحميل الملف، تأكدي من مساره.");
      return [];
    }

    if (!updatedFile.path.endsWith('.xlsx')) {
      print('❌ الملف ليس بصيغة .xlsx: ${updatedFile.path}');
      return [];
    }
    List<List<String>> tempData = [];

    var bytes = await updatedFile.readAsBytes();
    print('📂 حجم الملف: ${bytes.length} بايت');

    if (bytes.length < 100) {
      print('❌ الملف صغير جدًا وقد يكون غير صالح.');
      return [];
    }

    var excel = Excel.decodeBytes(bytes);

    try {
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];

        // تحويل الصفوف إلى List<List<String>>
        List<List<String>> rows = sheet!.rows.map((row) {
          return row.map((cell) {
            if (cell == null || cell.value == null) return "-";
            String value = cell.value.toString().trim();
            return value.isEmpty ? "-" : value;
          }).toList();
        }).toList();

        // تحديد الأعمدة الفارغة
        Set<int> columnsToRemove = {};
        for (int col = 0; col < rows[0].length; col++) {
          bool isColumnEmpty = true;
          for (int row = 0; row < rows.length; row++) {
            if (rows[row][col] != "-") {
              isColumnEmpty = false;
              break;
            }
          }
          if (isColumnEmpty) {
            columnsToRemove.add(col);
          }
        }

        // حذف الأعمدة الفارغة من الشيت
        for (int col in columnsToRemove.toList().reversed) {
          sheet.removeColumn(col);
        }

        // تحديث tempData بعد حذف الأعمدة الفارغة
        tempData = sheet.rows.map((row) {
          return row.map((cell) {
            if (cell == null || cell.value == null) return "-";
            String value = cell.value.toString().trim();
            return value.isEmpty ? "-" : value;
          }).toList();
        }).toList();
      }
      
      if (AuthorityModel.isTLProject(selectedFileLocalPath)) {
        return tempData;
      }
      int markColumnIndex = tempData[0].indexWhere(
          (col) => col.toUpperCase() == AppStrings.markColumn.toUpperCase());
      int weightColumnIndex = tempData[0].indexWhere(
          (col) => col.toUpperCase() == AppStrings.markColumnWeight.toUpperCase());
      int column1Index = tempData[0].indexWhere(
          (col) => col.toUpperCase() == AppStrings.markColumnPrep1Weight.toUpperCase());
      int column2Index = tempData[0].indexWhere(
          (col) => col.toUpperCase() == AppStrings.markColumnPrep2Weight.toUpperCase());

      if (markColumnIndex == -1) markColumnIndex = 0; // fallback just in case to prevent crash

      if (weightColumnIndex == -1) {
        weightColumnIndex = tempData[0].length; // الفهرس الجديد
        for (var row in tempData) {
          row.add("0.0"); // إضافة قيمة افتراضية
        }
        tempData[0][weightColumnIndex] =
            AppStrings.markColumnWeight; // تحديث العنوان
      }
      // Map لتجميع الصفوف بناءً على قيمة عمود "Mark"
      Map<String, List<List<String>>> groupedRows = {};
      for (int i = 1; i < tempData.length; i++) {
        String markValue = tempData[i][markColumnIndex];
        if (!groupedRows.containsKey(markValue)) {
          groupedRows[markValue] = [];
        }
        groupedRows[markValue]!.add(tempData[i]);
      }
      // List لتخزين النتيجة النهائية
      List<List<String>> mergedData = [];
      mergedData.add(tempData[0]); // إضافة الصف الأول (العناوين)

      // التكرار على كل مجموعة من الصفوف
      for (final entry in groupedRows.entries) {
        final rows = entry.value;

        // حساب إجمالي الوزن
        double totalWeight = 0.0;
        bool needsMerge = false;
        for (final row in rows) {
          final value1 = column1Index != -1 ? (double.tryParse(row[column1Index]) ?? 0.0) : 0.0;
          final value2 = column2Index != -1 ? (double.tryParse(row[column2Index]) ?? 0.0) : 0.0;
          totalWeight += value1 * value2;
          if (rows.length > 1) {
            needsMerge = true;
          }
        }

        // دمج الصفوف
        List<String> mergedRow = List.from(rows.first); // نسخ الصف الأول
        for (int i = 1; i < rows.length; i++) {
          for (int col = 0; col < rows[i].length; col++) {
            if (mergedRow[col] == "-" && rows[i][col] != "-") {
              mergedRow[col] = rows[i][col];
            }
          }
        }

        if (needsMerge) {
          if (column1Index != -1 && column2Index != -1) {
            mergedRow[weightColumnIndex] = totalWeight.toString();
          } else {
            // If we don't have the columns to calculate totalWeight, keep the sum of existing weights
            double existingWeightSum = 0.0;
            // Also try looking for "WEIGHT" or similar unit weight if "T.WEIGHT" is 0
            int fallbackWeightCol = tempData[0].indexWhere((col) => col.toUpperCase() == 'WEIGHT');
            for (final r in rows) {
              double parsedWeight = 0.0;
              if (weightColumnIndex < r.length) {
                parsedWeight = double.tryParse(r[weightColumnIndex]) ?? 0.0;
              }
              if (parsedWeight == 0.0 && fallbackWeightCol != -1 && fallbackWeightCol < r.length) {
                parsedWeight = double.tryParse(r[fallbackWeightCol]) ?? 0.0;
              }
              existingWeightSum += parsedWeight;
            }
            mergedRow[weightColumnIndex] = existingWeightSum.toStringAsFixed(2);
          }
        } else {
          // إذا كانت الصفوف لا تحتاج إلى دمج، نترك قيمة T.Weight كما هي
          double singleRowWeight = 0.0;
          if (weightColumnIndex < rows.first.length) {
            singleRowWeight = double.tryParse(rows.first[weightColumnIndex]) ?? 0.0;
          }
          if (singleRowWeight == 0.0) {
              int fallbackWeightCol = tempData[0].indexWhere((col) => col.toUpperCase() == 'WEIGHT');
              if (fallbackWeightCol != -1 && fallbackWeightCol < rows.first.length) {
                singleRowWeight = double.tryParse(rows.first[fallbackWeightCol]) ?? 0.0;
             }
          }
          mergedRow[weightColumnIndex] = singleRowWeight.toString();
        }

        // إضافة الصف المدمج إلى النتيجة
        mergedData.add(mergedRow);
      }

      pr("تم دمج البيانات");
      log("mergedData: $mergedData");
      List<List<String>> filteredData = filterColumns(mergedData, [
        AppStrings.markColumn,
        AppStrings.qtyColum,
        AppStrings.stateColumn,
        AppStrings.markColumnWeight,
        AppStrings.holdColum,
        AppStrings.reMarksColum,
      ]);

      log("filteredData: ${filteredData[0]}");
      log("filterDtat: $filteredData");
      return filteredData;
    } catch (e) {
      print('❌ خطأ أثناء تحليل ملف Excel: $e');
      return [];
    } finally {
      pr("🗣 fileRows ${tempData[0]} - ${tempData[0].length}");
      pr('✔︎ Changes saved to local file');
    }
  }

  List<List<String>> filterColumns(
    List<List<String>> data,
    List<String> requiredColumns,
  ) {
    if (data.isEmpty) return [];

    // تحويل عناوين الأعمدة إلى lowercase لمطابقة غير حساسة لحالة الأحرف
    List<String> headerRow =
        data[0].map((header) => header.toLowerCase()).toList();

    // استخراج الأعمدة المطلوبة الموجودة فعليًا في الـ data
    List<int> requiredColumnIndexes = [];
    List<String> actualHeaderNames = [];

    for (String column in requiredColumns) {
      int index = headerRow.indexOf(column.toLowerCase());
      if (index != -1) {
        requiredColumnIndexes.add(index);
        actualHeaderNames.add(data[0][index]); // الاحتفاظ بالاسم الحقيقي للعمود
      }
    }

    if (requiredColumnIndexes.isEmpty) return [];

    // إنشاء البيانات المفلترة مع العناوين الموجودة فعليًا
    List<List<String>> filteredData = [];
    filteredData.add(actualHeaderNames); // إضافة العناوين الموجودة فقط

    for (int i = 1; i < data.length; i++) {
      List<String> filteredRow = [];
      for (int colIndex in requiredColumnIndexes) {
        filteredRow.add(data[i][colIndex]);
      }
      filteredData.add(filteredRow);
    }

    return filteredData;
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
              "${AppStrings.appFolderPath}/$safeProjectName/$safeOrderName/$safeProjectName-$safeOrderName-$safeReleaseName.xlsx";

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

  //to save file in local storage locally or from server.
  Future<String> saveFileLocaly(
    context, {
    required String projectName,
    required String orderName,
    required String releaseName,
    FilePickerResult? result,
    String? firebasePath,
    required dynamic Function(double) onProgress,
    required dynamic Function() startDownLoad,
    required dynamic Function() endDownLoad,
    required dynamic Function() startProgress,
  }) async {
    projectName = projectName.replaceAll(' ', '');
    orderName = orderName.replaceAll(' ', '');
    releaseName = releaseName.replaceAll(' ', '');

    await GlobalFunctions().requestStoragePermission();
    const String appFolderPath = AppStrings.appFolderPath;
    await createFolderIfNeeded(appFolderPath);

    final projectFolderPath = '$appFolderPath/$projectName';
    await createFolderIfNeeded(projectFolderPath);

    final orderFolderPath = '$projectFolderPath/$orderName';
    await createFolderIfNeeded(orderFolderPath);

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
      startProgress();
      String sanitizedPath = releaseFile.path.split('?').first;
      await downloadFileWithProgress(
        firebasePath: firebasePath,
        savePath: sanitizedPath,
        onProgress: onProgress,
        startDownLoad: startDownLoad,
        endDownLoad: endDownLoad,
      );
    }
    return releaseFilePath;
  }

  Future<void> deleteFileCompletely(
      context, Function() init, String path) async {
    List<String> pathSegments = path.split('/');
    String fileName = pathSegments.last; // اسم الملف
    String order = pathSegments[pathSegments.length - 2]; // اسم الأوردر
    String project = pathSegments[pathSegments.length - 3]; // اسم المشروع
    String release = fileName.split('.').first.split('-').last;

    try {
      // حذف من Firestore
      CollectionReference tagsCollection =
          FirebaseFirestore.instance.collection('tags');

      // We need to find the correct project ID because the 'project' passed here
      // might be locally sanitized (spaces removed), while the Firestore ID has spaces.
      QuerySnapshot tagsSnapshot = await tagsCollection.get();
      String actualProjectId = tagsSnapshot.docs
          .firstWhere((doc) =>
              doc.id.replaceAll(' ', '') == project.replaceAll(' ', ''))
          .id;

      DocumentReference projectDoc = tagsCollection.doc(actualProjectId);

      // We need to find the correct order ID because the 'order' passed here
      // might be locally sanitized (spaces removed), while the Firestore ID has spaces.
      QuerySnapshot ordersSnapshot =
          await projectDoc.collection('orders').get();
      String actualOrderId = ordersSnapshot.docs
          .firstWhere(
              (doc) => doc.id.replaceAll(' ', '') == order.replaceAll(' ', ''))
          .id;

      DocumentReference orderDoc =
          projectDoc.collection('orders').doc(actualOrderId);
      DocumentSnapshot orderSnapshot = await orderDoc.get();

      String storagePath = 'files/$actualProjectId/$actualOrderId/$fileName';
      pr('$storagePath\n$actualProjectId\n$actualOrderId\n$fileName\n$release');

      // 1️⃣ حذف الملف من Storage
      await _deleteFileFromFirebaseStorage(storagePath);
      pr("🔥 تم حذف الملف من Firebase Storage: $storagePath");

      if (orderSnapshot.exists) {
        List<dynamic> releases = List.from(orderSnapshot['releases']);
        pr('releases: -----> $releases');
        // تحديث الـ `releases` بحذف الملف
        for (var r in releases) {
          if (r['release'] == release && r['file']['fileName'] == fileName) {
            r['file'] = {}; // مسح بيانات الملف

            break;
          }
        }

        await orderDoc.update({'releases': releases});
        pr('✅ الملف تم حذفه من Firestore');
      } else {
        pr('⚠️ لم يتم العثور على الوثيقة في Firestore');
      }

      // 3️⃣ حذف الملف محليًا
      String safeProjectName = project.replaceAll(' ', '');
      String safeOrderName = order.replaceAll(' ', '');
      String safeReleaseName = release.replaceAll(' ', '');

      String localPath =
          '${AppStrings.appFolderPath}/$safeProjectName/$safeOrderName/${generateFileName(safeProjectName, safeOrderName, safeReleaseName)}';
      File localFile = File(localPath);

      if (await localFile.exists()) {
        await localFile.delete();
        pr("🗑️ تم حذف الملف محليًا: $localPath");
      } else {
        pr("⚠️ الملف غير موجود محليًا: $localPath");
      }

      pr("✅ تم حذف الملف نهائيًا من جميع الأماكن بنجاح!");
      var tag = Provider.of<TagProvider>(context, listen: false);
      init();
      await tag.getAllTagsData();
    } catch (e) {
      pr("❌ خطأ أثناء حذف الملف: $e");
    }
  }

  Future<void> _deleteFileFromFirebaseStorage(String storagePath) async {
    storage.FirebaseStorage stg = storage.FirebaseStorage.instance;
    final ref = stg.ref().child(storagePath);
    await ref.delete();
  }
}
