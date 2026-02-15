import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/config/app_strings.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/app_settings_provider.dart';
import 'package:energya_ind/core/helper/providers/excel_provider.dart';
import 'package:energya_ind/core/models/user_model.dart';
import 'package:energya_ind/core/widgets/custom_navigation_button.dart';
import 'package:energya_ind/core/widgets/progress.dart';
import 'package:energya_ind/export.dart';
import 'package:energya_ind/frontend/home/layout/excel_table.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:energya_ind/frontend/home/view/production/widgets/vertical_tabel.dart';

class ExcelDataBody extends StatelessWidget {
  final String title;
  final bool moreDirs;
  final Future<void> Function() onRefresh;
  final List<List<String>> currentExcelData;
  final List<List<String>> searchedExcelData;

  const ExcelDataBody({
    required this.title,
    required this.moreDirs,
    required this.onRefresh,
    required this.currentExcelData,
    required this.searchedExcelData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var set = context.watch<AppSettingsProvider>();
    return Expanded(
      child: RefreshIndicator(
        color: AppStaticColor.primary,
        onRefresh: onRefresh,
        child: Consumer<ExcelProvider>(
          builder: (context, excel, child) => Stack(
            alignment: Alignment.center,
            children: [
              _buildExcelTable(context, excel),
              if (set.load) progress(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExcelTable(BuildContext context, ExcelProvider excel) {
    if (searchedExcelData.isNotEmpty) {
      return SingleChildScrollView(
        child: _buildExcelList(context, excel, list: searchedExcelData),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: excel.allExcelData.isEmpty
          ? const Center(child: Text('● ● ● ● ●'))
          : _buildExcelList(context, excel),
    );
  }

  Widget _buildExcelList(BuildContext context, ExcelProvider excel,
      {List<List<String>>? list}) {
    return ExcelTable(
      excelData: list ?? currentExcelData,
      title: title,
      isPro: true,
      withActions: excel.enabledExcelRows.isNotEmpty,
      moreDirs: moreDirs,
      dispatchTap: (row) => _showDispatchDialog(context, excel, row),
      actionTap: (row) async {
        await _handleActionTap(context, excel, row);
      },
      moreDirsOnSelected: (row, selectedDirId) async {
        context.pop();
        await _handleActionTap(
          context,
          excel,
          row,
          selectedDirId: selectedDirId,
        );
      },
      preprationsDone: (row) => _showPreparationDialog(context, excel, row),
    );
  }

  void _showDispatchDialog(
    BuildContext context,
    ExcelProvider excel,
    List<String> row,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: AppStaticColor.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text('Selected Mark Data'),
            const SizedBox(height: 10),
            VerticalTable(headers: excel.headerRow, data: row),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomNavigatorButton(
                buttonName: 'Finish Dispatch',
                borderRadius: 40,
                onTap: () async {
                  context.pop();
                  await excel.checkAndUpdateStates(
                    context,
                    excel.allExcelData.indexOf(row),
                    [],
                    initFunction: onRefresh,
                  );
                },
              ),
            ),
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.close, size: 25),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _handleActionTap(
    BuildContext context,
    ExcelProvider excel,
    List<String> row, {
    int? selectedDirId,
  }) async {
    pr("selected row: $row");
    pr("${authos.firstWhere((a) => a['autho'] == title, orElse: () => {})['dir'] as List<int>}");
    pr("selected: $selectedDirId");

    await excel.checkAndUpdateStates(
      context,
      excel.allExcelData.indexOf(row),
      authos.firstWhere((a) => a['autho'] == title, orElse: () => {})['dir']
          as List<int>,
      initFunction: onRefresh,
      selectedDirId: selectedDirId,
    );
  }

  void _showPreparationDialog(
    BuildContext context,
    ExcelProvider excel,
    List<String> row,
  ) {
    int index = excel.headerRow.indexOf(AppStrings.positionColumn);
    String pos = row[index];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        backgroundColor: AppStaticColor.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Text(
              'Position: $pos',
              style: const TextStyle(
                fontSize: 30,
                color: AppStaticColor.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                context.pop();
                await excel.updateCompletedPositionAtPrep(
                  context,
                  excel.allExcelData.where((row) => row[index] == pos).toList(),
                  initFunction: onRefresh,
                );
              },
              child: Container(
                margin: const EdgeInsets.all(20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppStaticColor.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 22,
                    color: AppStaticColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
