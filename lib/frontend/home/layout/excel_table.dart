import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/excel_provider.dart';
import 'package:energya_ind/core/models/authority_model.dart';
import 'package:energya_ind/core/utils/pop_up.dart';
import 'package:energya_ind/core/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExcelTable extends StatefulWidget {
  final List<List<String>> excelData;
  final bool withActions;
  final bool isPro;
  final bool editMaterialListPage;
  final Function(List<String>) actionTap;
  final Function(List<String>) preprationsDone;
  final String? title;
  final dynamic Function(List<String>, int)? moreDirsOnSelected;
  final bool moreDirs;
  final Function(List<String>)? dispatchTap;

  const ExcelTable({
    super.key,
    required this.excelData,
    this.withActions = true,
    this.isPro = false,
    this.editMaterialListPage = false,
    required this.actionTap,
    this.title,
    this.moreDirsOnSelected,
    this.moreDirs = false,
    this.dispatchTap,
    required this.preprationsDone,
  });
  @override
  ExcelTableState createState() => ExcelTableState();
}

class ExcelTableState extends State<ExcelTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DataTable(
            columnSpacing: 6,
            dividerThickness: 1.0,
            border: TableBorder.all(color: Colors.blueGrey),
            columns: _tableHeaders(),
            rows: _tableRows(context),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _tableHeaders() {
    if (widget.excelData.isEmpty || widget.excelData.first.isEmpty) {
      return [
        const DataColumn(
          label: Padding(
            padding: EdgeInsets.only(right: 15),
            child: Text(
              "Fetching...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ];
    }
    return [
      if (widget.withActions)
        const DataColumn(
          label: Padding(
            padding: EdgeInsets.only(right: 15),
            child: Text(
              "Select",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
          ),
        ),
      ...widget.excelData.first.map(
        (col) => DataColumn(
          label: Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blueGrey,
              alignment: Alignment.center,
              child: Text(
                col,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<DataRow> _tableRows(BuildContext context) {
    var excel = context.read<ExcelProvider>();
    if (widget.excelData.isEmpty || widget.excelData.first.isEmpty) {
      return []; // إذا لم تكن هناك بيانات، إرجاع قائمة فارغة
    }
    return widget.excelData.skip(1).toList().asMap().entries.map((entry) {
      int rowIndex = entry.key;
      List<String> row = entry.value;
      List<String> filledRow = List.generate(
        widget.excelData.first.length,
        (index) => index < row.length ? row[index] : "-",
      );

      setState(() {
        filledRow = List.generate(
          widget.excelData.first.length,
          (index) => index < row.length ? row[index] : "-",
        );
      });
      return DataRow(
        color:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          return excel.selectedRows.isNotEmpty && excel.selectedRows[rowIndex]
              ? AppStaticColor.primary.withValues(alpha: .2)
              : null;
        }),
        cells: _tableRowCells(rowIndex, context, filledRow),
      );
    }).toList();
  }

  List<DataCell> _tableRowCells(
    int rowIndex,
    BuildContext context,
    List<String> filledRow,
  ) {
    var excel = context.read<ExcelProvider>();

    bool isRowExist = excel.isRowInUnHold(
      widget.excelData.skip(1).toList()[rowIndex],
    );
    return [
      if (widget.withActions)
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //for (hold, unhold) actions
              if (excel.enabledExcelRows.contains(true)) ...[
                if (widget.editMaterialListPage)
                  InkWell(
                    onTap: () {
                      widget.actionTap(
                          widget.excelData.skip(1).toList()[rowIndex]);
                    },
                    child: Icon(
                      isRowExist
                          ? Icons.subdirectory_arrow_right_outlined
                          : Icons.subdirectory_arrow_left_outlined,
                      color: AppStaticColor.green,
                    ),
                  ),
                //for production
                if (widget.isPro &&
                    widget.title != AuthorityModel.authos[6].name &&
                    widget.title != AuthorityModel.authos[0].name &&
                    excel.enabledExcelRows.skip(1).toList()[rowIndex])
                  popActoionsMarkItemsForPops(
                    context,
                    onSelected: (v) async {
                      widget.actionTap(
                        widget.excelData.skip(1).toList()[rowIndex],
                      );
                    },
                    next: excel.getNextProductionStep(widget.title ?? '') ?? '',
                    moreDirs: widget.moreDirs,
                    moreDirsOnSelected: (v) {
                      widget.moreDirsOnSelected!(
                          widget.excelData.skip(1).toList()[rowIndex], v);
                    },
                  ),
                if (widget.isPro &&
                    widget.title == AuthorityModel.authos[0].name &&
                    excel.enabledExcelRows.skip(1).toList()[rowIndex])
                  InkWell(
                    onTap: () {
                      widget.preprationsDone(
                        widget.excelData.skip(1).toList()[rowIndex],
                      );
                    },
                    child: Text(
                      "Done",
                      style: Styles.textStyle16600.copyWith(
                        color: AppStaticColor.green,
                      ),
                    ),
                  ),
                if (widget.isPro &&
                    widget.title == AuthorityModel.authos[6].name)
                  InkWell(
                    onTap: () {
                      widget.dispatchTap!(
                        widget.excelData.skip(1).toList()[rowIndex],
                      );
                    },
                    child: const Icon(
                      Icons.done_all_outlined,
                      color: AppStaticColor.green,
                    ),
                  ),
              ],
              //for total
              Checkbox(
                value: excel.selectedRows[rowIndex],
                activeColor: AppStaticColor.black.withValues(alpha: .7),
                onChanged: (bool? value) {
                  List<List<String>> selectedRows = [];
                  List<List<String>> currentExcelData =
                      widget.excelData.skip(1).toList();
                  print(
                      "${currentExcelData.length} selected row index - $rowIndex");
                  setState(() {
                    excel.selectedRows[rowIndex] =
                        !excel.selectedRows[rowIndex];

                    selectedRows = [excel.headerRow] +
                        currentExcelData
                            .asMap()
                            .entries
                            .where((entry) => excel.selectedRows[entry.key])
                            .map((entry) => entry.value)
                            .toList();
                    pr("###selectedRows: $selectedRows");
                  });
                  bool thereSelect = excel.selectedRows.contains(true);
                  excel.calculateTotalWeight(
                    thereSelect ? selectedRows : widget.excelData,
                  );
                },
              ),
            ],
          ),
        ),
      ...filledRow.map(
        (cell) => DataCell(
          Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Text(
              cell.isEmpty ? "ـ" : cell,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ];
  }
}
