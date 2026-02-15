import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/config/app_strings.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/app_settings_provider.dart';
import 'package:energya_ind/core/helper/providers/excel_provider.dart';
import 'package:energya_ind/core/utils/consts.dart';
import 'package:energya_ind/core/utils/pdf.dart';
import 'package:energya_ind/core/widgets/appbar_widget.dart';
import 'package:energya_ind/core/widgets/filter_box_widget.dart';
import 'package:energya_ind/core/widgets/progress.dart';
import 'package:energya_ind/core/widgets/search_widget.dart';
import 'package:energya_ind/export.dart';
import 'package:energya_ind/core/widgets/step2_total_widget.dart';
import 'package:energya_ind/frontend/home/layout/excel_table.dart';
import 'package:flutter/material.dart';
import 'widget/reports_filter.dart';

class ReportsStep2Screen extends StatefulWidget {
  const ReportsStep2Screen({
    super.key,
    required this.onPop,
  });
  final Function() onPop;
  @override
  State<ReportsStep2Screen> createState() => _ReportsStep2ScreenState();
}

class _ReportsStep2ScreenState extends State<ReportsStep2Screen> {
  final TextEditingController searchController = TextEditingController();
  List<List<String>> currentExcelData = [];
  int selectedState = 0;
  late ExcelProvider ex;
  List<List<String>> searchedList = [];

  @override
  void initState() {
    super.initState();
    ex = context.read<ExcelProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
     await _init();
    });
  }

  Future<void> _init() async {
    setState(() {
      selectedState = 0;
      currentExcelData.clear();
      searchedList.clear();
      searchController.clear();
    });

    await ex.readExcelFile(context, '', forReports: true);
    ex.calculateTotalWeight(ex.allExcelData);
    setState(() => currentExcelData = ex.allExcelData);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        widget.onPop();
      },
      child: Scaffold(
        appBar: buildAppBar(
          ex.selectedFileLocalPath.split('/').last,
          onPressed: () {
            widget.onPop();
          },
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: IconButton(
                onPressed: () async {
                  await generateFilteredPdf(
                    currentExcelData,
                    ex.selectedFileLocalPath
                        .split('/')
                        .last
                        .replaceAll('.xlsx', ''),
                    ex,
                  );
                  _init();
                },
                icon: const Icon(
                  Icons.print_outlined,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _searchWidget(),
              const SizedBox(height: 5),
              //filter
              filterItems(
                reportsFilters,
                selectedState,
                onTap: (index) {
                  setState(() {
                    selectedState = index;
                  });
                  ex.filterExcelData('');
                  setState(() {
                    currentExcelData = getReportFilteredData(ex, selectedState);
                  });
                  ex.calculateTotalWeight(currentExcelData);
                },
              ),
              const SizedBox(height: 10),
              totalWeightWidget(context),
              _excelDataBody(ex, context),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchWidget() {
    return step2SearchWidget(
      controller: searchController,
      onClose: () {
        setState(() {
          searchedList.clear();
          searchController.clear();
        });
      },
      onChanged: (v) {
        searchFunction(v);
        print(searchedList.length);
      },
    );
  }

  searchFunction(String query) {
    var ex = context.read<ExcelProvider>();
    searchedList.clear();
    if (currentExcelData.isEmpty) return [];

    List<String> headers = ex.headerRow;

    int columnIndex = headers.indexOf(AppStrings.markColumn);
    if (columnIndex == -1) {
      pr("❌ NotFound Column: MARK");
      return [];
    } else {
      setState(() {
        searchedList.add(headers);

        searchedList.addAll(
          currentExcelData.skip(1).where((row) {
            return row.isNotEmpty &&
                row[columnIndex].toLowerCase().contains(query.toLowerCase());
          }).toList(),
        );
      });
      ex.calculateTotalWeight(searchedList);
    }
  }

  Expanded _excelDataBody(ExcelProvider ex, BuildContext context) {
    var set = context.watch<AppSettingsProvider>();
    return Expanded(
      child: RefreshIndicator(
        color: AppStaticColor.primary,
        onRefresh: _init,
        child: Stack(
          alignment: Alignment.center,
          children: [
            searchedList.isEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: currentExcelData.isEmpty
                        ? const Center(child: Text("....."))
                        : ExcelTable(
                            excelData: currentExcelData,
                            withActions: false,
                            actionTap: (index) {},
                            preprationsDone: (row) {},
                          ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: ExcelTable(
                      excelData: searchedList,
                      withActions: false,
                      actionTap: (index) {},
                      preprationsDone: (row) {},
                    ),
                  ),
            if (set.load) progress(),
          ],
        ),
      ),
    );
  }
}
