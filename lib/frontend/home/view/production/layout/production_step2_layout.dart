import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/config/app_strings.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/excel_provider.dart';
import 'package:energya_ind/core/models/authority_model.dart';
import 'package:energya_ind/core/utils/consts.dart';
import 'package:energya_ind/core/utils/styles.dart';
import 'package:energya_ind/core/widgets/filter_box_widget.dart';
import 'package:energya_ind/core/widgets/search_widget.dart';
import 'package:energya_ind/core/widgets/step2_total_widget.dart';
import 'package:energya_ind/frontend/home/layout/widgets/excel_data_body.dart';
import 'package:energya_ind/frontend/home/widgets/step2/filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/step2/step2_all_action_button_widget.dart';

class ProductionStep2Layout extends StatefulWidget {
  const ProductionStep2Layout({
    super.key,
    required this.title,
    this.moreDirs = false,
    this.isDispatch = false,
    required this.onPop,
  });
  final String title;
  final bool moreDirs;
  final bool isDispatch;
  final Function() onPop;
  @override
  State<ProductionStep2Layout> createState() => _ProductionStep2LayoutState();
}

class _ProductionStep2LayoutState extends State<ProductionStep2Layout> {
  final String searchHint = 'Search on Marks....';
  final TextEditingController searchController = TextEditingController();
  List<List<String>> currentExcelData = [];
  List<List<String>> searchedExcelData = [];
  int selectedState = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initialize();
    });
  }

  initialPageVariables() {
    setState(() {
      searchController.clear();
      searchedExcelData.clear();
      currentExcelData.clear();
      selectedState = 0;
    });
  }

  Future<void> _initialize() async {
    initialPageVariables();
    final excel = context.read<ExcelProvider>();

    await excel.readExcelFile(context, widget.title);

    excel.calculateTotalWeight(excel.allExcelData);
    setState(() {
      currentExcelData = getProductionFilteredData(
        excel,
        selectedState,
        widget.title,
        widget.isDispatch,
      );
    });
    excel.filterExcelData(widget.title);
    setState(() {});
  }

  changeCurrentExcel(excel) {}

  @override
  Widget build(BuildContext context) {
    final excel = Provider.of<ExcelProvider>(context);
    final selectedCount = excel.selectedRows.where((e) => e == true).length;
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        widget.onPop();
      },
      child: Scaffold(
        appBar: _appBar(excel),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _searchWidget(),
              const SizedBox(height: 5),
              filterItems(
                productionFilter(widget.title, widget.isDispatch),
                selectedState,
                onTap: FocusScope.of(context).hasFocus
                    ? (i) {
                        pr("keyboard activated");
                        FocusScope.of(context).unfocus();
                        setState(() {
                          searchedExcelData.clear();
                          searchController.clear();
                        });
                      }
                    : (index) {
                        setState(() {
                          selectedState = index;
                        });
                        excel.filterExcelData(widget.title);
                        setState(() {
                          currentExcelData = getProductionFilteredData(
                            excel,
                            selectedState,
                            widget.title,
                            widget.isDispatch,
                          );
                        });
                        excel.calculateTotalWeight(currentExcelData);
                      },
              ),
              const SizedBox(height: 10),
              totalWeightWidget(context),
              if (selectedCount > 1 &&
                  widget.title != AuthorityModel.authos[0].name &&
                  selectedCount > 0 && // تأكد من تحديد صف واحد على الأقل
                  excel.selectedRows
                      .asMap()
                      .entries
                      .where((entry) => entry.value == true)
                      .every((entry) =>
                          excel.enabledExcelRows[entry.key + 1] == true))
                AllActionPushButtonWidget(
                  currentExcelData: currentExcelData,
                  title: widget.title,
                  initial: _initialize,
                  moreDirections:
                      widget.title == AuthorityModel.authos[4].name ||
                          widget.title == AuthorityModel.authos[7].name,
                ),
              ExcelDataBody(
                title: widget.title,
                moreDirs: widget.moreDirs,
                onRefresh: () async {
                  _initialize();
                },
                currentExcelData: currentExcelData,
                searchedExcelData: searchedExcelData,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar(ExcelProvider excel) {
    return AppBar(
      backgroundColor: AppStaticColor.primary.withAlpha(128),
      title: Text(
        excel.selectedFileLocalPath.split('/').last,
        style: Styles.textStyle16600.copyWith(
          color: Colors.white70,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () {
          widget.onPop();
        },
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }
 
  Widget _searchWidget() {
    return step2SearchWidget(
      controller: searchController,
      onClose: () {
        setState(() {
          searchedExcelData.clear();
          searchController.clear();
        });
      },
      onChanged: (v) {
        searchFunction(v);
        print(searchedExcelData.length);
      },
    );
  }

  searchFunction(String query) {
    var ex = context.read<ExcelProvider>();
    searchedExcelData.clear();
    if (currentExcelData.isEmpty) return [];

    List<String> headers = ex.headerRow;

    int columnIndex = headers.indexOf(AppStrings.markColumn);
    if (columnIndex == -1) {
      pr("❌ NotFound Column: MARK");
      return [];
    } else {
      setState(() {
        searchedExcelData.add(headers);

        searchedExcelData.addAll(
          currentExcelData.skip(1).where((row) {
            return row.isNotEmpty &&
                row[columnIndex].toLowerCase().contains(query.toLowerCase());
          }).toList(),
        );
      });
      ex.calculateTotalWeight(searchedExcelData);
    }
  }
}
