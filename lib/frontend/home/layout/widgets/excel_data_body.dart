import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/config/app_strings.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/app_settings_provider.dart';
import 'package:energya_ind/core/helper/providers/excel_provider.dart';
import 'package:energya_ind/core/models/authority_model.dart';
import 'package:energya_ind/core/models/user_model.dart';
import 'package:energya_ind/core/widgets/custom_navigation_button.dart';
import 'package:energya_ind/core/widgets/progress.dart';
import 'package:energya_ind/export.dart';
import 'package:energya_ind/frontend/home/layout/excel_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // For Cutting, show quantity dialog before pushing to Visual
    if (title == AuthorityModel.authos[8].name) {
      await _showCuttingQuantityDialog(context, excel, row,
          selectedDirId: selectedDirId);
      return;
    }

    // Use project-aware authos for state transitions
    var projectAuthos = getAuthosForProject(excel.selectedFileLocalPath);
    pr("selected row: $row");
    pr("${projectAuthos.firstWhere((a) => a['autho'] == title, orElse: () => {})['dir'] as List<int>}");
    pr("selected: $selectedDirId");

    await excel.checkAndUpdateStates(
      context,
      excel.allExcelData.indexOf(row),
      projectAuthos.firstWhere((a) => a['autho'] == title,
          orElse: () => {})['dir'] as List<int>,
      initFunction: onRefresh,
      selectedDirId: selectedDirId,
    );
  }

  /// Shows a dialog to enter the quantity to push from Cutting to Visual.
  /// Pre-fills with the current QTY value of the row.
  /// On confirm: deducts pushed qty, updates QTY in Excel, then changes state.
  Future<void> _showCuttingQuantityDialog(
    BuildContext context,
    ExcelProvider excel,
    List<String> row, {
    int? selectedDirId,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _CuttingQuantityDialog(
          excel: excel,
          row: row,
          title: title,
          onRefresh: onRefresh,
          selectedDirId: selectedDirId,
        );
      },
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

class _CuttingQuantityDialog extends StatefulWidget {
  final ExcelProvider excel;
  final List<String> row;
  final String title;
  final Future<void> Function() onRefresh;
  final int? selectedDirId;

  const _CuttingQuantityDialog({
    required this.excel,
    required this.row,
    required this.title,
    required this.onRefresh,
    this.selectedDirId,
  });

  @override
  State<_CuttingQuantityDialog> createState() => _CuttingQuantityDialogState();
}

class _CuttingQuantityDialogState extends State<_CuttingQuantityDialog> {
  late TextEditingController qtyController;
  String? errorText;
  int currentQty = 0;
  int qtyColIndex = -1;
  int stateColIndex = -1;

  @override
  void initState() {
    super.initState();
    // Look up QTY column: might be 'QTY' or 'MARK QTY'
    qtyColIndex = widget.excel.headerRow.indexWhere((h) =>
            h.toUpperCase().contains('QTY') &&
            !h.toUpperCase().contains('POS QTY') // Avoid position qty
        );
    if (qtyColIndex == -1) {
      qtyColIndex = widget.excel.headerRow.indexOf(AppStrings.qtyColum);
    }

    stateColIndex = widget.excel.headerRow.indexOf(AppStrings.stateColumn);

    if (qtyColIndex != -1 && qtyColIndex < widget.row.length) {
      currentQty = int.tryParse(widget.row[qtyColIndex]) ?? 0;
    }
    qtyController = TextEditingController(text: currentQty.toString());
  }

  @override
  void dispose() {
    qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.content_cut,
              color: AppStaticColor.primary, size: 22),
          SizedBox(width: 8),
          Text(
            'Push to Visual',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available quantity: $currentQty',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Quantity to push',
                hintText: 'Enter quantity',
                errorText: errorText,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon:
                    const Icon(Icons.numbers, color: AppStaticColor.primary),
              ),
              onChanged: (_) {
                if (errorText != null) {
                  setState(() => errorText = null);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppStaticColor.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            final int? pushedQty = int.tryParse(qtyController.text.trim());

            if (pushedQty == null || pushedQty <= 0) {
              setState(
                  () => errorText = 'Please enter a quantity greater than 0');
              return;
            }
            if (pushedQty > currentQty) {
              setState(() =>
                  errorText = 'Cannot exceed available quantity ($currentQty)');
              return;
            }

            Navigator.of(context).pop();

            final int remainingQty = currentQty - pushedQty;
            final int rowIndex = widget.excel.allExcelData.indexOf(widget.row);

            // Update QTY in Excel first
            await widget.excel
                .updateQtyInExcel(context, rowIndex, remainingQty);

            // Check if state is ALREADY Visual (because they just re-pushed another qty)
            String currentState = '';
            if (stateColIndex != -1 && stateColIndex < widget.row.length) {
              currentState = widget.row[stateColIndex];
            }

            if (context.mounted) {
              // If already Visual, we don't try to push to the next state, just re-refresh
              if (currentState == AuthorityModel.authos[8].name ||
                  currentState == 'Visual' ||
                  currentState.contains('Visual')) {
                await widget.onRefresh();
              } else {
                var projectAuthos =
                    getAuthosForProject(widget.excel.selectedFileLocalPath);
                final dirs = projectAuthos.firstWhere(
                    (a) => a['autho'] == widget.title,
                    orElse: () => {})['dir'] as List<int>;

                await widget.excel.checkAndUpdateStates(
                  context,
                  rowIndex,
                  dirs,
                  initFunction: widget.onRefresh,
                  selectedDirId: widget.selectedDirId,
                );
              }
            }
          },
          child: const Text('Confirm',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
