import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/config/app_strings.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/excel_provider.dart';
import 'package:energya_ind/core/models/authority_model.dart';
import 'package:energya_ind/core/models/user_model.dart';
import 'package:energya_ind/core/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AllActionButtonWidget extends StatefulWidget {
  const AllActionButtonWidget({
    super.key,
    required this.currentExcelData,
    required this.title,
    required this.initial,
  });
  final List<List<String>> currentExcelData;
  final String title;
  final Future<void> Function() initial;
  @override
  State<AllActionButtonWidget> createState() => _AllActionButtonWidgetState();
}

class _AllActionButtonWidgetState extends State<AllActionButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: makeAllUpdatedFunction,
            child: Text(
              "Change",
              style: Styles.textStyle14600.copyWith(
                color: AppStaticColor.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }

  makeAllUpdatedFunction() {
    var excel = context.read<ExcelProvider>();
    if (excel.selectedRows.where((e) => e == true).length > 1) {
      List<List<String>> selectedRows = [];
      for (int i = 0; i < excel.selectedRows.length; i++) {
        if (excel.selectedRows[i] == true) {
          selectedRows.add(widget.currentExcelData[i + 1]);
        }
      }

      int columnIndex = widget.currentExcelData.first.indexOf("HOLD");
      if (columnIndex == -1) return;

      int holdCount =
          selectedRows.where((row) => excel.holdExcelData.contains(row)).length;
      int unholdCount = selectedRows.length - holdCount;

      String title = "";
      String message = "";
      String buttonText = "";
      pr(selectedRows);
      if (holdCount == selectedRows.length) {
        // جميع الصفوف Hold
        title = "Currently all selected rows are Hold";
        message = "They will be updated to Unhold.";
        buttonText = "Un-Hold";
      } else if (unholdCount == selectedRows.length) {
        // جميع الصفوف Unhold
        title = "Currently all selected rows are Unhold";
        message = "They will be updated to Hold.";
        buttonText = "Hold";
      } else {
        // الصفوف مختلطة
        title = "You have selected mixed rows";
        message =
            "You have selected mixed rows containing Hold and Unhold.\n\nDue to the current state, all selected rows will be Hold..";
        buttonText = "Apply Change";
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await excel
                      .updateMultipleExcelRows(
                    context,
                    rowsToUpdate: selectedRows,
                    columnName: "HOLD",
                    newValue: holdCount == selectedRows.length ? '-' : 'hold',
                    currentStep: widget.title,
                  )
                      .then((_) {
                    widget.initial();
                  });
                },
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}

class AllActionPushButtonWidget extends StatefulWidget {
  const AllActionPushButtonWidget({
    super.key,
    this.moreDirections = false,
    required this.title,
    required this.currentExcelData,
    required this.initial,
  });
  final bool moreDirections;
  final String title;
  final List<List<String>> currentExcelData;
  final Future<void> Function() initial;

  @override
  State<AllActionPushButtonWidget> createState() =>
      _AllActionPushButtonWidgetState();
}

class _AllActionPushButtonWidgetState extends State<AllActionPushButtonWidget> {
  @override
  Widget build(BuildContext context) {
    var ex = Provider.of<ExcelProvider>(context);
    bool isDispatch = widget.title == AuthorityModel.authos[6].name;
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: isDispatch
                ? () async {
                    List<List<String>> selectedRows = [];
                    for (int i = 0; i < ex.selectedRows.length; i++) {
                      if (ex.selectedRows[i] == true) {
                        selectedRows.add(widget.currentExcelData[i + 1]);
                      }
                    }
                    pr(selectedRows.length);
                    await ex.checkAndUpdateStates(
                      context,
                      0,
                      [],
                      selectedRows: selectedRows,
                      initFunction: widget.initial,
                    );
                  }
                : () => makeAllUpdatedFunction(ex),
            child: Text(
              widget.moreDirections
                  ? "push"
                  : isDispatch
                      ? "Finish Dispatched"
                      : "Push to ${ex.getNextProductionStep(widget.title)}",
              style: Styles.textStyle14600.copyWith(
                color: AppStaticColor.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<int?> showDirSelectionDialog(
      BuildContext context, List<int> dirs) async {
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Push To",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: dirs.map((dir) {
              return ListTile(
                title: Text(authos[dir]['autho']),
                onTap: () {
                  Navigator.pop(context, dir); // إرجاع الـ dir المختار
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> makeAllUpdatedFunction(ExcelProvider excel) async {
    if (excel.selectedRows.where((e) => e == true).length > 1) {
      List<List<String>> selectedRows = [];
      for (int i = 0; i < excel.selectedRows.length; i++) {
        if (excel.selectedRows[i] == true) {
          selectedRows.add(widget.currentExcelData[i + 1]);
        }
      }

      int columnIndex =
          widget.currentExcelData.first.indexOf(AppStrings.stateColumn);
      if (columnIndex == -1) return;

      List<List<String>> holdRows = selectedRows
          .where((row) => excel.holdExcelData.contains(row))
          .toList();
      List<List<String>> doneRows = selectedRows
          .where((row) => excel.doneExcelData.contains(row))
          .toList();
      List<List<String>> dispatchedRows = selectedRows
          .where((row) => excel.dispatchedExcelData.contains(row))
          .toList();

      String title = "";
      String message = "";
      String buttonText = "";

      bool isHoldRows = selectedRows.any((row) => holdRows.contains(row));
      bool isDoneRows = selectedRows.any((row) => doneRows.contains(row));
      bool isDispatchedRows =
          selectedRows.any((row) => dispatchedRows.contains(row));

      bool isOkForPush = !isHoldRows && !isDoneRows && !isDispatchedRows;
      bool isCurrentStep =
          selectedRows.any((row) => row.contains(widget.title));

      // Use project-aware authos for state transitions
      var projectAuthos = getAuthosForProject(excel.selectedFileLocalPath);

      List<int> dirs = projectAuthos.firstWhere(
        (a) => a['autho'] == widget.title,
        orElse: () => {'dir': []},
      )['dir'] as List<int>;

      int? selectedDir;
      if (dirs.length > 1 && widget.moreDirections) {
        selectedDir = await showDirSelectionDialog(context, dirs);
        if (selectedDir == null) return; // إذا لم يتم اختيار أي dir
      } else if (dirs.isNotEmpty) {
        selectedDir = dirs.first; // إذا كان هناك dir واحد فقط
      }

      if (isCurrentStep && isOkForPush) {
        // جميع الصفوف Hold
        title = "Currently at ${widget.title}";
        message = widget.moreDirections
            ? "They will be updated to ( ${authos[selectedDir!]['autho']} )."
            : "They will be updated to  ( ${excel.getNextProductionStep(widget.title)} ).";
        buttonText = "Push";
      } else if (isOkForPush && !isCurrentStep) {
        // الصفوف مختلطة
        title = "Mixed rows";
        message = "You have selected mixed rows, Hold State or done State.";
        buttonText = "OK";
      } else if (!isCurrentStep) {
        return;
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Selected Rows',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        content: SizedBox(
                          width: MediaQuery.of(context).size.width * .8,
                          height: selectedRows.length > 3 ? 300 : 80,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GridView.count(
                                  crossAxisCount: 3,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  children: [
                                    ...selectedRows.map((row) {
                                      return Container(
                                        color: AppStaticColor.primary
                                            .withValues(alpha: .3),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 2),
                                        margin: const EdgeInsets.all(2),
                                        child: Center(
                                          child: Text(
                                            row[0],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    })
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              context.pop();
                            },
                            child: const Text("Ok"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text("Re-View"),
              ),
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: isOkForPush
                    ? () async {
                        context.pop();
                        await excel.checkAndUpdateStates(
                          context,
                          0,
                          projectAuthos.firstWhere(
                            (a) => a['autho'] == widget.title,
                            orElse: () => {},
                          )['dir'] as List<int>,
                          selectedRows: selectedRows,
                          selectedDirId: selectedDir,
                          initFunction: widget.initial,
                        );
                      }
                    : () {
                        context.pop();
                      },
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
