import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/excel_provider.dart';
import 'package:energya_ind/core/utils/styles.dart';
import 'package:energya_ind/core/widgets/custom_navigation_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'step2_vertical_table_widget.dart';

Future<dynamic> markDialog(
  BuildContext context, {
  required List<String> rowData,
  String? btnText,
  void Function()? btnTap,
  int? rowIndex,
  Color? btnColor,
  bool? isEdit,
  bool isNew = false,
  void Function(List<String> updatedData)? editTap,
  required Future<void> Function() initialize,
}) {
  var ex = context.read<ExcelProvider>();
  final GlobalKey<VerticalTableState> tableKey =
      GlobalKey<VerticalTableState>();
  print('rowIndex: $rowIndex');
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: AppStaticColor.gray,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                isNew ? 'Add New Mark' : 'Selected Mark Data',
                style: Styles.textStyle14600.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                child: VerticalTable(
                  key: tableKey,
                  headers: ex.headerRow,
                  data: isNew
                      ? List.generate(ex.headerRow.length, (_) => '')
                      : rowData,
                  isEdit: isEdit ?? false,
                  isNew: isNew,
                ),
              ),
              const SizedBox(height: 2),
              if (isNew)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CustomNavigatorButton(
                    buttonName: 'Add',
                    borderRadius: 40,
                    btnColor: AppStaticColor.green,
                    onTap: () async {
                      List<String> newValues =
                          tableKey.currentState!.getUpdatedValues();
                      pr("📦 البيانات المضافة: $newValues");

                      await ex.addExcelRow(context, newValues);
                      if (context.mounted) context.pop();
                      await initialize();
                    },
                  ),
                )
              else if (isEdit == true)
                CustomNavigatorButton(
                  buttonName: 'Edit',
                  borderRadius: 40,
                  btnColor: AppStaticColor.green,
                  onTap: () async {
                    List<String> updatedValues =
                        tableKey.currentState!.getUpdatedValues();
                    pr("بيانات الصف بعد التعديل: $updatedValues");

                    await ex.editExcelRow(
                      context,
                      rowIndex,
                      updatedValues,
                    );
                    if (context.mounted) {
                      context.pop();
                    }

                    await initialize();
                  },
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CustomNavigatorButton(
                          buttonName: btnText ?? 'Hold',
                          borderRadius: 40,
                          btnColor: btnColor,
                          onTap: btnTap,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CustomNavigatorButton(
                          buttonName: 'Edit',
                          borderRadius: 40,
                          btnColor: AppStaticColor.green,
                          onTap: () {
                            context.pop();
                            markDialog(
                              context,
                              rowData: rowData,
                              rowIndex: rowIndex,
                              btnColor: Colors.green,
                              initialize: initialize,
                              isEdit: true,
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CustomNavigatorButton(
                          buttonName: 'Delete',
                          borderRadius: 40,
                          btnColor: AppStaticColor.red,
                          onTap: () async {
                            await ex
                                .deleteExcelRow(context, rowIndex)
                                .then((_) async {
                              context.pop();
                              await initialize();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(
                  Icons.close,
                  size: 25,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}
