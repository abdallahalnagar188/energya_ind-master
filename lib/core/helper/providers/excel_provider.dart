import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energya_ind/core/config/app_strings.dart';
import 'package:energya_ind/core/helper/services/file_services.dart';
import 'package:energya_ind/core/models/user_model.dart';
import 'package:energya_ind/export.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/authority_model.dart';
import '../methods.dart';
import 'app_settings_provider.dart';

class ExcelProvider with ChangeNotifier {
  double _totalMarksWeight = 0.0;
  double get totalMarksWeight => _totalMarksWeight;

  String selectedFileLocalPath = '';

  List<List<String>> allExcelData = [];
  List<List<String>> holdExcelData = [];
  List<List<String>> unHoldExcelData = [];
  List<List<String>> underExcelData = [];
  List<List<String>> doneExcelData = [];
  List<List<String>> dispatchedExcelData = [];

  List<bool> enabledExcelRows = []; //rows was enabled to selected.
  List<bool> selectedRows = []; //for selected rows.

  List<String> headerRow = [];

  final FileServices _fileServices = FileServices();

  List<List<String>> getDoneExcelData(String currentStep) {
    int currentIndex =
        AuthorityModel.authos.indexWhere((auth) => auth.name == currentStep);

    if (currentIndex == -1) return [];

    List<String> nextSteps = AuthorityModel.authos
        .skip(currentIndex + 1)
        .map((auth) => auth.name)
        .toList();
    notifyListeners();
    // تصفية الصفوف التي تنتمي إلى المراحل التالية فقط
    return allExcelData.where((row) {
      int index = headerRow.indexOf(AppStrings.stateColumn);
      return index != -1 && nextSteps.any((step) => row[index].contains(step));
    }).toList();
  }

  List<List<String>> getPrepDoneExcelData() {
    int currentIndex = 0;
    List<String> nextSteps = AuthorityModel.authos
        .skip(currentIndex + 1)
        .map((auth) => auth.name)
        .toList();

    // تصفية الصفوف التي تنتمي إلى المراحل التالية فقط
    return allExcelData.where((row) {
      int index = headerRow.indexOf(AppStrings.stateColumn);
      return index != -1 && nextSteps.any((step) => row[index].contains(step));
    }).toList();
  }

  /// Returns true if currentStep is the initial step for this project type.
  bool _isInitialStep(String currentStep) {
    bool isTL = AuthorityModel.isTLProject(selectedFileLocalPath);
    return (isTL && currentStep == 'Cutting') ||
        (!isTL && currentStep == AuthorityModel.authos[0].name);
  }

  void filterExcelData(String currentStep) {
    print(currentStep);
    if (allExcelData.isEmpty) return;
    holdExcelData = [headerRow] +
        allExcelData.where((row) => row.contains("hold")).toList();
    pr('📂hold: ${holdExcelData.length}');
    unHoldExcelData = [headerRow] +
        allExcelData
            .where((row) => !row.contains("hold") && !row.contains("HOLD"))
            .toList();
    pr('📂unHold: ${unHoldExcelData.length}');
    if (_isInitialStep(currentStep)) {
      if (headerRow.contains(AppStrings.stateColumn)) {
        underExcelData = [headerRow] +
            allExcelData.skip(1).where((row) {
              return row.contains(currentStep);
            }).toList();
      } else {
        underExcelData = [headerRow] + allExcelData.skip(1).toList();
      }
    } else {
      underExcelData = [headerRow] +
          allExcelData.where((row) => row.contains(currentStep)).toList();
    }
    pr('📂under-$currentStep: ${underExcelData.length}');
    dispatchedExcelData = [headerRow] +
        allExcelData.where((row) => row.contains("✓✓Dispatched")).toList();
    pr('📂dispatched: ${dispatchedExcelData.length}');
    if (_isInitialStep(currentStep)) {
      doneExcelData = [headerRow] +
          allExcelData.where((row) {
            return row.any((cell) => cell.toString().contains("✅"));
          }).toList() +
          getDoneExcelData(currentStep);
    } else {
      doneExcelData = [headerRow] + getDoneExcelData(currentStep);
    }
    pr('📂done: ${doneExcelData.length}');
    notifyListeners();
  }

  void initialExcelRows(List<List<String>> filteredData) {
    enabledExcelRows = List.generate(filteredData.length, (index) => true);
    selectedRows = List.generate(filteredData.length, (index) => false);
    notifyListeners();
  }

  void updateRowsBasedOnFilter(
    String filterType, {
    String? currentStep,
  }) {
    if (filterType == "All" && currentStep != null) {
      if (_isInitialStep(currentStep)) {
        enabledExcelRows = List.generate(allExcelData.length, (index) {
          List<String> row = allExcelData[index];
          bool isDone = doneExcelData.contains(row);

          return !isDone;
        });
      } else {
        enabledExcelRows = List.generate(
          allExcelData.length,
          (index) {
            List<String> row = allExcelData[index];
            bool isHold = holdExcelData.contains(row); // الصف في الـ Hold
            bool isCurrentStep = row.contains(currentStep);
            return isCurrentStep && !isHold;
          },
        );
      }
      selectedRows = List.generate(enabledExcelRows.length, (index) => false);
    } else if (filterType == "Under-$currentStep" && currentStep != null) {
      if (_isInitialStep(currentStep)) {
        enabledExcelRows = List.generate(allExcelData.length, (index) {
          List<String> row = allExcelData[index];
          bool isDone = doneExcelData.contains(row);
          return !isDone;
        });
      } else {
        enabledExcelRows = List.generate(underExcelData.length, (index) {
          List<String> row = underExcelData[index];
          bool isHold = holdExcelData.contains(row); // الصف في الـ Hold
          bool isCurrentStep = row.contains(currentStep);
          return isCurrentStep && !isHold;
        });
      }
      selectedRows = List.generate(enabledExcelRows.length, (index) => false);
    } else if (filterType == "All" && currentStep == null) {
      enabledExcelRows = List.generate(allExcelData.length, (index) => true);
      selectedRows = List.generate(allExcelData.length, (index) => false);
    } else if (filterType == "Hold" && currentStep == null) {
      enabledExcelRows = List.generate(holdExcelData.length, (index) => true);
      selectedRows = List.generate(holdExcelData.length, (index) => false);
    } else if (filterType == "Un-Hold" && currentStep == null) {
      enabledExcelRows = List.generate(unHoldExcelData.length, (index) => true);
      selectedRows = List.generate(unHoldExcelData.length, (index) => false);
    } else if (filterType == "Hold" && currentStep != null) {
      enabledExcelRows.clear();
      selectedRows.clear();
    } else if (filterType == "Done" ||
        filterType == "Dispatched" && currentStep != null) {
      enabledExcelRows.clear();
      selectedRows.clear();
    }
    notifyListeners();
  }

  double calculateTotalWeight(List<List<String>>? excelData) {
    if (excelData == null || excelData.isEmpty) return 0.0;

    print("first row: ${excelData.first}");
    print(
        "index of weight: ${excelData.first.indexOf(AppStrings.markColumnWeight)}");
    int columnIndex = excelData.first.indexOf(AppStrings.markColumnWeight);
    if (columnIndex == -1) {
      calculatePreprationTotalWeight(excelData);
      notifyListeners();
      return 0.0;
    } else {
      print("mark column index: $columnIndex");

      double total = excelData.skip(1).fold(0.0, (total, row) {
        if (row.length > columnIndex) {
          double value = double.tryParse(row[columnIndex]) ?? 0.0;
          return total + value;
        } else {
          print("Skipped row (too short): $row");
          return total;
        }
      });
      _totalMarksWeight = double.parse(total.toStringAsFixed(1));
      notifyListeners();
      print('Calculated Total Weight: $_totalMarksWeight');
      print('Data Used for Calculation: ${excelData.length}');
      return _totalMarksWeight;
    }
  }

  double calculatePreprationTotalWeight(List<List<String>>? excelData) {
    if (excelData == null || excelData.isEmpty) return 0.0;

    int column1Index =
        excelData.first.indexOf(AppStrings.markColumnPrep1Weight);
    int column2Index =
        excelData.first.indexOf(AppStrings.markColumnPrep2Weight);

    if (column1Index == -1 && column2Index == -1) return 0.0;
    double total = excelData.skip(1).fold(0.0, (tot, row) {
      double value1 = double.tryParse(row[column1Index]) ?? 0.0;
      double value2 = double.tryParse(row[column2Index]) ?? 0.0;
      return tot + (value1 * value2);
    });
    _totalMarksWeight = double.parse(total.toStringAsFixed(1));
    notifyListeners();
    return _totalMarksWeight;
  }

  bool isRowInUnHold(List<String> row) {
    return unHoldExcelData.any((unHoldRow) => listEquals(unHoldRow, row));
  }

  Future<void> updateMultipleExcelRows(
    BuildContext context, {
    required List<List<String>> rowsToUpdate,
    required String columnName,
    required String newValue,
    required String currentStep,
  }) async {
    var set = context.read<AppSettingsProvider>();
    set.startLoad();
    var file = File(selectedFileLocalPath);
    try {
      if (await file.exists()) {
        var bytes = file.readAsBytesSync();
        if (bytes.isNotEmpty) {
          var excel = Excel.decodeBytes(bytes); // تحميل ملف Excel
          var sheet = excel.tables[excel.tables.keys.first]!;

          bool isUpdated = false; // للتحقق مما إذا كان هناك تعديل فعلي

          for (var rowToUpdate in rowsToUpdate) {
            int rowIndex = allExcelData.indexWhere((row) => row == rowToUpdate);
            if (rowIndex == -1) continue; // تخطي الصف إذا لم يكن موجودًا

            // البحث عن اسم العمود
            int columnIndex = allExcelData.first.indexOf(columnName);

            // إذا لم يكن موجودًا، يتم إضافته
            if (columnIndex == -1) {
              columnIndex = sheet.maxColumns;
              sheet.insertColumn(columnIndex);
              pr('New Column Added ✅');
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: columnIndex, rowIndex: 0))
                  .value = TextCellValue(columnName);
              pr('New Column -> $columnName ');

              for (int row = 1; row < sheet.rows.length; row++) {
                sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: columnIndex, rowIndex: row))
                    .value = TextCellValue('-');
              }
              pr('All $columnName values Filled by: -');
            }

            sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: columnIndex, rowIndex: rowIndex))
                .value = TextCellValue(
              newValue,
            );
            notifyListeners();
            isUpdated = true;
            notifyListeners();
          }

          if (isUpdated) {
            var updatedBytes = excel.encode();
            if (updatedBytes != null) {
              await file.writeAsBytes(updatedBytes);
            }

            // تحديث الفلتر
            filterExcelData(currentStep);
            notifyListeners();

            await saveChanges(context, excel);
          }
        } else {
          pr('❌ الملف موجود لكنه فارغ!');
        }
      } else {
        pr('❌ الملف غير موجود!');
      }
    } finally {
      set.endLoad();
      notifyListeners();
    }
  }

  Future<void> saveChanges(BuildContext context, Excel excel) async {
    String path = selectedFileLocalPath;

    var updatedBytes = excel.encode();
    if (updatedBytes == null || updatedBytes.isEmpty) {
      pr('❌ فشل تحديث الملف: `excel.encode()` أعاد null أو بيانات فارغة');
      return;
    }

    File localFile = File(path);

    List<String> pathSegments = path.split('/');
    String fileName = pathSegments.last;
    String order = pathSegments[pathSegments.length - 2];
    String project = pathSegments[pathSegments.length - 3];
    String release = fileName.split('.').first.split('-').last;
    String storagePath = 'files/$project/$order/$fileName';

    pr('$storagePath\n$project\n$order\n$fileName\n$release');
    try {
      localFile.writeAsBytesSync(updatedBytes);
      pr('✅ تم حفظ التعديلات في الملف بنجاح');
    } catch (e) {
      pr('❌ خطأ أثناء كتابة الملف محليًا: $e');
      return;
    }
    await _addFileToFirestore(
      context,
      project: project,
      order: order,
      fileName: fileName,
      filePath: selectedFileLocalPath,
      allowReplace: true,
      release: release,
    ).then((fileUrl) {
      pr('✅ تم تحديث الملف ورفعه إلى Firebase');
    }).catchError((error) {
      pr('❌ فشل رفع الملف إلى Firebase: $error');
    });
    notifyListeners();
  }

  Future<void> _addFileToFirestore(
    BuildContext context, {
    required String project,
    required String order,
    required String release,
    required String fileName,
    required String filePath,
    bool allowReplace = false,
  }) async {
    var set = context.read<AppSettingsProvider>();

    if (!fileName.endsWith(".xlsx")) {
      pr("❌ الملف ليس بصيغة xlsx");
      set.endLoad();
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

      final fileUrl = await _fileServices.uploadFileToFirebaseWithProgress(
        file,
        storagePath,
        loadProgress: set.loadProgress,
      );

      pr('File uploaded successfully. File URL: $fileUrl');

      // استرجاع قائمة releases
      List<dynamic> releases = List.from(orderSnapshot['releases']);
      pr('rels: ${orderSnapshot['releases']}');
      pr('rels: $releases');

      Map<String, dynamic>? existingRelease;

      // التحقق إذا كان الـ release موجودًا
      for (var r in releases) {
        String rRelease = r['release'].toString();
        if (rRelease.replaceAll(' ', '') == release.replaceAll(' ', '')) {
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
          set.endLoad();
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
      notifyListeners();
      set.endLoad();
    } catch (e) {
      pr('Error adding file to Firestore: $e');
    }
  }

  Future<File?> downloadLatestFile({
    required String project,
    required String order,
    required String release,
    required String fileName,
  }) async {
    try {
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

      List<dynamic> releases = List.from(orderSnapshot['releases']);
      Map<String, dynamic>? existingRelease;

      for (var r in releases) {
        String rRelease = r['release'].toString();
        if (rRelease.replaceAll(' ', '') == release.replaceAll(' ', '')) {
          existingRelease = Map<String, dynamic>.from(r);
          break;
        }
      }

      if (existingRelease == null || (existingRelease['file'] as Map).isEmpty) {
        pr('❌ لا يوجد ملف متاح لهذا الإصدار.');
        return null;
      }

      String fileUrl = existingRelease['file']['filePath'];

      // تحديد مسار الحفظ المحلي
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String localFilePath = '${appDocDir.path}/$fileName';

      File localFile = File(localFilePath);

      // تحميل الملف وتخزينه محليًا
      HttpClient httpClient = HttpClient();
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(fileUrl));
      HttpClientResponse response = await request.close();
      List<int> bytes = await consolidateHttpClientResponseBytes(response);
      print(bytes.length);
      await localFile.writeAsBytes(bytes);

      pr('✅ تم تحديث الملف محليًا!');
      notifyListeners();
      return localFile;
    } catch (e) {
      pr('❌ Error downloading latest file: $e');
      return null;
    }
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

  Future<void> readExcelFile(BuildContext context, String currentStep,
      {bool forReports = false}) async {
    var set = context.read<AppSettingsProvider>();
    set.startLoad();

    try {
      List<String> pathSegments = selectedFileLocalPath.split('/');
      String fileName = pathSegments.last; // اسم الملف
      String orderName = pathSegments[pathSegments.length - 2]; // اسم الأوردر
      String projectName = pathSegments[pathSegments.length - 3]; // اسم المشروع
      String releaseName = fileName.split('.').first.split('-').last;
      File? updatedFile = await downloadLatestFile(
        project: projectName,
        order: orderName,
        release: releaseName,
        fileName: fileName,
      );
      //////////
      print('updatedFile:  $updatedFile');
      allExcelData = forReports
          ? await _fileServices.readReportExcelFile(
              updatedFile: updatedFile,
              selectedFileLocalPath: selectedFileLocalPath,
            )
          : await _fileServices.readExcelFile(
              updatedFile: updatedFile,
              selectedFileLocalPath: selectedFileLocalPath,
            );

      if (allExcelData.isNotEmpty) {
        headerRow = allExcelData.first;
      }
      pr("🗣 headerRow $headerRow - ${headerRow.length}");
      pr('📂all: ${allExcelData.length}');

      initialExcelRows(allExcelData);
      filterExcelData(currentStep);
    } finally {
      set.endLoad();
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> checkFilesIfInLocal(
    BuildContext context,
    Map<String, dynamic> filteredTags,
  ) async {
    var set = context.read<AppSettingsProvider>();
    set.startLoad();
    List<Map<String, dynamic>> filesInLocale =
        await _fileServices.checkFilesIfinLocal(filteredTags);
    set.endLoad();
    notifyListeners();
    return filesInLocale;
  }

  Future<String?> saveFileLocaly(
    BuildContext context, {
    required String projectName,
    required String orderName,
    required String releaseName,
    String? firebasePath,
  }) async {
    var set = context.read<AppSettingsProvider>();
    set.startLoad();
    print('Firebase: Url: $firebasePath');
    String? filePath = await _fileServices.saveFileLocaly(
      context,
      projectName: projectName,
      orderName: orderName,
      releaseName: releaseName,
      firebasePath: firebasePath,
      onProgress: (prog) {
        pr("Download Progress: ${prog.toStringAsFixed(2)}%");
      },
      startDownLoad: set.startDownload,
      startProgress: set.startLoad,
      endDownLoad: set.endDownload,
    );
    set.endLoad();
    notifyListeners();
    return filePath;
  }

  Future deleteFileCompletely(
    BuildContext context, {
    required Function() init,
  }) async {
    var set = context.read<AppSettingsProvider>();
    set.startLoad();
    await _fileServices.deleteFileCompletely(
      context,
      init,
      selectedFileLocalPath,
    );
    notifyListeners();
    set.endLoad();
  }

  Future<void> editExcelRow(
    BuildContext context,
    int? rowIndex,
    List<String> newData,
  ) async {
    print('rowIndex: $rowIndex');
    print('newData: $newData');
    var set = context.read<AppSettingsProvider>();
    set.startLoad();
    var file = File(selectedFileLocalPath);
    if (await file.exists()) {
      var bytes = await file.readAsBytes();
      if (bytes.isNotEmpty) {
        var excel = Excel.decodeBytes(bytes);

        var sheet = excel.tables.keys.first; // افتراضًا أول شيت في الملف
        var table = excel.tables[sheet];

        if (rowIndex != null) {
          if (table == null || rowIndex >= table.rows.length) {
            print("❌ الصف غير موجود!");
            set.endLoad();
            return;
          }

          // تحديث بيانات الصف
          for (int i = 0; i < newData.length; i++) {
            if (i < table.rows[rowIndex].length) {
              table.updateCell(
                CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex),
                TextCellValue(newData[i]),
              );
            }
          }

          saveChanges(context, excel);
        }
      } else {
        pr('❌ الملف موجود لكنه فارغ!');
      }
    } else {
      pr('❌ الملف غير موجود!');
    }
    set.endLoad();
    notifyListeners();
  }

  Future<void> addExcelRow(
    BuildContext context,
    List<String> newRowData,
  ) async {
    print('newRowData: $newRowData');
    var set = context.read<AppSettingsProvider>();
    set.startLoad();

    var file = File(selectedFileLocalPath);
    if (await file.exists()) {
      var bytes = await file.readAsBytes();
      if (bytes.isNotEmpty) {
        var excel = Excel.decodeBytes(bytes);
        var sheet = excel.tables.keys.first; // افتراضًا أول شيت في الملف
        var table = excel.tables[sheet];

        if (table == null) {
          print("❌ الجدول غير موجود!");
          set.endLoad();
          return;
        }

        // إضافة صف جديد
        var newRowIndex = table.maxRows;
        for (int col = 0; col < newRowData.length; col++) {
          table.updateCell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: newRowIndex),
            TextCellValue(newRowData[col]),
          );
        }

        saveChanges(context, excel);
      } else {
        pr('❌ الملف موجود لكنه فارغ!');
      }
    } else {
      pr('❌ الملف غير موجود!');
    }
    set.endLoad();
    notifyListeners();
  }

  Future<void> deleteExcelRow(BuildContext context, int? rowIndex) async {
    var set = context.read<AppSettingsProvider>();
    set.startLoad();
    var file = File(selectedFileLocalPath);
    if (await file.exists()) {
      var bytes = file.readAsBytesSync();
      if (bytes.isNotEmpty) {
        var excel = Excel.decodeBytes(bytes);

        var sheet = excel.tables.keys.first;
        var table = excel.tables[sheet];

        if (rowIndex != null) {
          if (table == null || rowIndex >= table.rows.length) {
            print("❌ الصف غير موجود!");
            return;
          }

          table.removeRow(rowIndex);

          // حفظ التعديلات
          saveChanges(context, excel);
        }
      } else {
        pr('❌ الملف موجود لكنه فارغ!');
      }
    } else {
      pr('❌ الملف غير موجود!');
    }
    set.endLoad();
    notifyListeners();
  }

  /*  String getAllTotalsToPrint(
    List<List<String>> filter, {
    int? index,
    List<List<String>>? another,
  }) {
    String txt = '';
    if (index == null) {
      txt = calculateTotalWeight(filter).toString();
    } else {
      filterExcelData(AuthorityModel.authos[index].name);

      if (another != null) {
        filter.clear();
        filter.addAll(another);
      } else {
        filter.clear();
        filter.addAll(underExcelData);
      }
      txt = calculateTotalWeight(filter).toString();
    }
    notifyListeners();
    return txt;
  } */

  String getAllTotalsToPrint(
    List<List<String>> filter, {
    int? index,
    List<List<String>>? another,
  }) {
    String txt = '';
    List<List<String>> workingList = [];

    if (index == null) {
      workingList = List.from(filter); // نسخة من البيانات
    } else {
      filterExcelData(AuthorityModel.authos[index].name);
      if (another != null) {
        workingList = List.from(another); // استخدام نسخة من another
      } else {
        workingList = List.from(underExcelData); // نسخة من underExcelData
      }
    }

    txt = calculateTotalWeight(workingList).toString();
    print("Number of rows in workingList: ${workingList.length}");

    return txt;
  }

  String? getNextProductionStep(String title) {
    int i = authos.indexWhere((a) => a['autho'] == title);

    if (i != -1 && (authos[i]['dir'] as List).isNotEmpty) {
      List<int> l = authos[i]['dir'];
      List<String> nextText = [];
      for (int x in l) {
        nextText.add(authos[x]['autho']);
      }
      return nextText.join(',');
    }
    if (i != -1 && (authos[i]['dir'] as List).isEmpty) {
      pr('next : Dispatched');
    }
    notifyListeners();
    return null;
  }

  /// Updates the QTY column value for a specific row in the Excel file.
  /// Used by Cutting → Visual push to write back the remaining quantity.
  Future<void> updateQtyInExcel(
    BuildContext context,
    int rowIndex,
    int newQty,
  ) async {
    var file = File(selectedFileLocalPath);
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    String sheetName = excel.tables.keys.first;
    Sheet sheet = excel[sheetName];

    // Find the QTY column index
    int qtyColumnIndex = -1;
    for (int colIndex = 0; colIndex < sheet.rows[0].length; colIndex++) {
      var cellValue = sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: colIndex, rowIndex: 0))
              .value
              ?.toString()
              .toUpperCase() ??
          '';
      if (cellValue.contains('QTY') && !cellValue.contains('POS QTY')) {
        qtyColumnIndex = colIndex;
        break;
      }
    }

    if (qtyColumnIndex == -1) {
      pr('❌ QTY column not found');
      return;
    }

    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: qtyColumnIndex, rowIndex: rowIndex))
        .value = TextCellValue(newQty.toString());

    pr('✅ QTY updated to $newQty at row $rowIndex');
    await saveChanges(context, excel);
    notifyListeners();
  }

  Future<void> checkAndUpdateStates(
    BuildContext context,
    int rowIndex,
    List<int> nextDirs, {
    List<List<String>>? selectedRows,
    required Future<void> Function() initFunction,
    int? selectedDirId,
  }) async {
    var set = context.read<AppSettingsProvider>();
    set.startLoad();
    pr('selected row index: $rowIndex');
    var file = File(selectedFileLocalPath);
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    bool hasStatesColumn = false;
    int statesColumnIndex = -1;
    String sheetName = excel.tables.keys.first;
    Sheet sheet = excel[sheetName];

    // البحث عن عمود STATES
    for (int colIndex = 0; colIndex < sheet.rows[0].length; colIndex++) {
      var cellValue = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 0))
          .value
          ?.toString();
      if (cellValue == 'STATES') {
        pr('✔️ there STATES col');
        hasStatesColumn = true;
        statesColumnIndex = colIndex;
        break;
      }
    }

    // Use project-aware initial state
    String initialState = AuthorityModel.getInitialState(selectedFileLocalPath);
    // Use project-aware authos for state transitions
    List<Map<String, dynamic>> projectAuthos =
        getAuthosForProject(selectedFileLocalPath);

    if (!hasStatesColumn) {
      statesColumnIndex = sheet.maxColumns;

      sheet.insertColumn(statesColumnIndex);
      pr('New Column Added ✅');
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: statesColumnIndex, rowIndex: 0))
          .value = TextCellValue('STATES');
      pr('New Column -> STATES ');
      for (int row = 1; row < sheet.rows.length; row++) {
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: statesColumnIndex, rowIndex: row))
            .value = TextCellValue(initialState);
      }
      pr('All STATES values Filled by: $initialState');
    }

    if (selectedRows == null) {
      await _updateStateForRow(
        sheet,
        rowIndex,
        statesColumnIndex,
        projectAuthos,
        nextDirs,
        selectedDirId: selectedDirId,
      );
    } else {
      for (var row in selectedRows) {
        await _updateStateForRow(
          sheet,
          allExcelData.indexOf(row),
          statesColumnIndex,
          projectAuthos,
          nextDirs,
          selectedDirId: selectedDirId,
        );
      }
    }

    // طباعة بيانات الصف بعد التعديل
    List<String> rowData = [];
    for (int colIndex = 0; colIndex < sheet.rows[rowIndex].length; colIndex++) {
      rowData.add(sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: colIndex, rowIndex: rowIndex))
              .value
              ?.toString() ??
          '-');
    }
    pr('Row $rowIndex updated: ${rowData.join(', ')}');
    await saveChanges(context, excel);
    await initFunction();

    set.endLoad();
    notifyListeners();
  }

  Future<void> _updateStateForRow(
    Sheet sheet,
    int rowIndex,
    int statesColumnIndex,
    List<Map<String, dynamic>> authos,
    List<int> nextDirs, {
    int? selectedDirId,
  }) async {
    if (rowIndex < sheet.rows.length) {
      String currentAutho = sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: statesColumnIndex, rowIndex: rowIndex))
              .value
              ?.toString() ??
          '';

      var authoEntry = authos.firstWhere(
          (entry) => entry['autho'] == currentAutho,
          orElse: () => {});
      print(authoEntry);
      if (nextDirs.isNotEmpty && authoEntry.isNotEmpty) {
        print("selected Id From Dir: $selectedDirId");

        int chosenDirId = selectedDirId ?? nextDirs.first;

        var nextAuthoEntry = authos[chosenDirId];
        print("nextAutho is : $nextAuthoEntry");
        String initialState =
            AuthorityModel.getInitialState(selectedFileLocalPath);
        String nextState =
            nextAuthoEntry.isNotEmpty ? nextAuthoEntry['autho'] : initialState;
        print("next state is: $nextState");
        sheet
            .cell(
              CellIndex.indexByColumnRow(
                  columnIndex: statesColumnIndex, rowIndex: rowIndex),
            )
            .value = TextCellValue(nextState);
        notifyListeners();
      }
      if (nextDirs.isEmpty) {
        String nextState = '✓✓Dispatched';
        print("next step: $nextState");
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: statesColumnIndex, rowIndex: rowIndex))
            .value = TextCellValue(nextState);
        notifyListeners();
      }
    }
    notifyListeners();
  }

  Future<void> updateCompletedPositionAtPrep(
    BuildContext context,
    List<List<String>> selectedPositionRows, {
    required Future<void> Function() initFunction,
  }) async {
    final settings = context.read<AppSettingsProvider>();
    settings.startLoad();

    try {
      final file = File(selectedFileLocalPath);
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      final positionColumnIndex = headerRow.indexOf(AppStrings.positionColumn);
      final sheetName = excel.tables.keys.first;
      final sheet = excel[sheetName];

      // Update rows with ✅
      for (final row in sheet.rows) {
        for (final posRow in selectedPositionRows) {
          if (row[positionColumnIndex]?.value ==
              TextCellValue(posRow[positionColumnIndex])) {
            final rowIndex = allExcelData.indexOf(posRow);
            sheet
                .cell(CellIndex.indexByColumnRow(
                  columnIndex: positionColumnIndex,
                  rowIndex: rowIndex,
                ))
                .value = TextCellValue('✅  ${posRow[positionColumnIndex]}');
          }
        }
      }

      // Filter and save changes
      filterExcelData(AuthorityModel.authos[0].name);
      await mergeCompletedRows(context, excel);
      await saveChanges(context, excel);
      await initFunction();
      notifyListeners();
    } catch (e) {
      print('Error updating completed positions: $e');
    } finally {
      settings.endLoad();
      notifyListeners();
    }
  }

  Future<void> mergeCompletedRows(BuildContext context, Excel excel) async {
    final settings = context.read<AppSettingsProvider>();
    settings.startLoad();

    try {
      pr("****$headerRow*****");
      pr("🗣 $headerRow - ${headerRow.length}");

      final positionColumnIndex = headerRow.indexOf(AppStrings.positionColumn);
      final markColumnIndex = headerRow.indexOf(AppStrings.markColumn);
      final column1Index = headerRow.indexOf(AppStrings.markColumnPrep1Weight);
      final column2Index = headerRow.indexOf(AppStrings.markColumnPrep2Weight);
      final qTYColumnIndex = headerRow.indexOf(AppStrings.qtyColum);

      final sheetName = excel.tables.keys.first;
      final sheet = excel[sheetName];
      pr("🗣 fileRows ${sheet.rows[0].map((cell) => cell?.value?.toString() ?? '')} - ${sheet.rows[0].length}");
      headerRow = sheet.rows[0]
          .map((cell) => cell?.value?.toString() ?? '')
          .where((cell) => cell.isNotEmpty) // إزالة الأعمدة الفارغة
          .toList();
      pr("****$headerRow*****");
      // Ensure STATE and WEIGHT columns exist
      int statesColumnIndex = headerRow.indexOf(AppStrings.stateColumn);
      int weightColumnIndex = headerRow.indexOf(AppStrings.markColumnWeight);

      pr("🅾️ ${AppStrings.positionColumn}-> $positionColumnIndex");
      pr("🅾️ ${AppStrings.markColumn}-> $markColumnIndex");
      pr("🅾️ ${AppStrings.markColumnPrep1Weight}-> $column1Index");
      pr("🅾️ ${AppStrings.markColumnPrep2Weight}-> $column2Index");
      pr("🅾️ ${AppStrings.stateColumn}-> $statesColumnIndex");
      pr("🅾️ ${AppStrings.markColumnWeight}-> $weightColumnIndex");
      // التحقق من وجود عمود STATE قبل إضافته
      for (int i = 1; i < sheet.rows.length; i++) {
        pr("****$headerRow*****");

        // التحقق من وجود عمود STATE قبل إضافته
        if (!headerRow.contains(AppStrings.stateColumn)) {
          pr('❌ STATES not found');
          statesColumnIndex = sheet.maxColumns;
          sheet.insertColumn(statesColumnIndex);
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: statesColumnIndex, rowIndex: 0))
              .value = TextCellValue(AppStrings.stateColumn);

          // تحديث headerRow ليعكس التغييرات في الشيت
          headerRow = sheet.rows[0]
              .map((cell) => cell?.value?.toString() ?? '')
              .where((cell) => cell.isNotEmpty) // إزالة الأعمدة الفارغة
              .toList();
          pr("****$headerRow*****");
          pr('✔︎ STATES was added');
        }
        // التحقق من وجود عمود WEIGHT قبل إضافته
        if (!headerRow.contains(AppStrings.markColumnWeight)) {
          pr('❌ T.WEIGHT not found');
          weightColumnIndex = sheet.maxColumns;
          sheet.insertColumn(weightColumnIndex);
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: weightColumnIndex, rowIndex: 0))
              .value = TextCellValue(AppStrings.markColumnWeight);

          // تحديث headerRow ليعكس التغييرات في الشيت
          headerRow = sheet.rows[0]
              .map((cell) => cell?.value?.toString() ?? '')
              .where((cell) => cell.isNotEmpty) // إزالة الأعمدة الفارغة
              .toList();
          pr("****$headerRow*****");
          pr('✔︎ T.WEIGHT was added');
        }

        // تعبئة القيم الافتراضية لأعمدة STATE و WEIGHT

        if (statesColumnIndex != -1 &&
            sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: statesColumnIndex, rowIndex: i))
                    .value ==
                null) {
          pr("'تعبئة ال states' 🗣 $headerRow - ${headerRow.length}");

          String initialState =
              AuthorityModel.getInitialState(selectedFileLocalPath);
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: statesColumnIndex, rowIndex: i))
              .value = TextCellValue(initialState);
        }

        if (weightColumnIndex != -1 &&
            sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: weightColumnIndex, rowIndex: i))
                    .value ==
                null) {
          pr("'تعبئة ال weight' 🗣 $headerRow - ${headerRow.length}");
          final value1 = double.tryParse(sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: column1Index, rowIndex: i))
                      .value
                      ?.toString() ??
                  "0") ??
              0.0;
          final value2 = double.tryParse(sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: column2Index, rowIndex: i))
                      .value
                      ?.toString() ??
                  "0") ??
              0.0;
          final initialWeight = value1 * value2;
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: weightColumnIndex, rowIndex: i))
              .value = TextCellValue(initialWeight.toString());
        }
      }

      // Group rows by Mark
      final groupedRows = <String, List<int>>{};
      final rowDataMap = <String, List<List<String?>>>{};

      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        final markValue = row[markColumnIndex]?.value?.toString() ?? '';
        final rowData = row.map((cell) => cell?.value?.toString()).toList();

        groupedRows.putIfAbsent(markValue, () => []).add(i);
        rowDataMap.putIfAbsent(markValue, () => []).add(rowData);
      }

      // Delete completed rows and add new aggregated row
      final rowsToDelete = <int>[];

      for (final entry in groupedRows.entries) {
        final markValue = entry.key;
        final rowIndexes = entry.value;
        final rows = rowDataMap[markValue]!;

        final allDone = rows.every((row) =>
            row[positionColumnIndex]?.toString().contains("✅") ?? false);
        print('#all is Done or not? $allDone');

        if (allDone) {
          rowsToDelete.addAll(rowIndexes);

          // Calculate total weight for rows with the same Mark
          double totalWeight = 0.0;
          for (final row in rows) {
            final value1 = double.tryParse(row[column1Index] ?? "0") ?? 0.0;
            final value2 = double.tryParse(row[column2Index] ?? "0") ?? 0.0;
            totalWeight += value1 * value2;
          }
          final qtyValue = rows.first[qTYColumnIndex] ?? "0";
          // Add new row
          final newRowIndex = sheet.rows.length;
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: markColumnIndex, rowIndex: newRowIndex))
              .value = TextCellValue(markValue);
          // T-L projects: after merge go to Visual; SS-L: go to Assembly
          String nextStepAfterMerge =
              AuthorityModel.isTLProject(selectedFileLocalPath)
                  ? 'Visual'
                  : AuthorityModel.authos[1].name;
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: statesColumnIndex, rowIndex: newRowIndex))
              .value = TextCellValue(nextStepAfterMerge);
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: weightColumnIndex, rowIndex: newRowIndex))
              .value = TextCellValue(totalWeight.toString());
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: qTYColumnIndex, rowIndex: newRowIndex))
              .value = TextCellValue(qtyValue);
        }
      }

      // Delete rows in reverse order to avoid index issues
      rowsToDelete.sort((a, b) => b.compareTo(a));
      for (final rowIndex in rowsToDelete) {
        sheet.removeRow(rowIndex);
      }

      await saveChanges(context, excel);
    } catch (e) {
      print('Error merging completed rows: $e');
    } finally {
      settings.endLoad();
      notifyListeners();
    }
  }

  Future<void> removeColumnFromExcel(
    BuildContext context,
    String columnName,
  ) async {
    var set = context.read<AppSettingsProvider>();
    set.startLoad();

    var file = File(selectedFileLocalPath);
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    String sheetName = excel.tables.keys.first;
    Sheet sheet = excel[sheetName];

    // الحصول على فهرس العمود المطلوب حذفه
    int columnIndex = headerRow.indexOf(columnName);
    if (columnIndex == -1) {
      print("العمود غير موجود.");
      set.endLoad();
      return;
    }

    // إزالة القيم الخاصة بهذا العمود من جميع الصفوف
    for (var row in sheet.rows) {
      if (columnIndex < row.length) {
        row.removeAt(columnIndex);
      }
    }

    // تحديث الهيدر بإزالة العمود
    headerRow.removeAt(columnIndex);

    // حفظ التعديلات
    await saveChanges(context, excel);
    set.endLoad();

    print("تم حذف العمود $columnName بنجاح.");
    notifyListeners();
  }
}
