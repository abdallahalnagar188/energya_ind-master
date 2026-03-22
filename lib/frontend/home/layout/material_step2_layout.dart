import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/app_settings_provider.dart';
import 'package:energya_ind/core/helper/providers/excel_provider.dart';
import 'package:energya_ind/core/utils/consts.dart';
import 'package:energya_ind/core/widgets/filter_box_widget.dart';
import 'package:energya_ind/core/widgets/progress.dart';
import 'package:energya_ind/export.dart';
import 'package:energya_ind/frontend/home/layout/excel_table.dart';
import 'package:energya_ind/frontend/home/widgets/step2/step2_delete_forever_button.dart';
import 'package:energya_ind/frontend/home/widgets/step2/filter_widget.dart';
import 'package:energya_ind/frontend/home/view/material/widgets/tags_tree_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/step2/step2_all_action_button_widget.dart';
import '../../../core/widgets/appbar_widget.dart';
import '../widgets/step2/step2_row_dialog_widget.dart';
import '../../../core/widgets/search_widget.dart';
import '../../../core/widgets/step2_total_widget.dart';

class MaterialStep2Layout extends StatefulWidget {
  const MaterialStep2Layout({
    super.key,
    required this.title,
    this.isPro = true,
    this.holdWidget,
    required this.onPop,
  });

  final String title;
  final bool isPro;
  final Widget Function(int, bool)? holdWidget;
  final Function() onPop;

  @override
  State<MaterialStep2Layout> createState() => _ProductionStep2LayoutState();
}

class _ProductionStep2LayoutState extends State<MaterialStep2Layout> {
  final TextEditingController searchController = TextEditingController();
  int selectedState = 0;
  List<List<String>> searchedList = [];
  List<List<String>> currentExcelData = [];

  late ExcelProvider excel;
  @override
  void initState() {
    super.initState();

    excel = context.read<ExcelProvider>();
    _initialize();
  }

  initialPageVariables() {
    setState(() {
      searchController.clear();
      tagsExpansionState.clear();
      ordersExpansionState.clear();
      searchedList.clear();
      selectedState = 0;
    });
  }

  Future<void> _initialize() async {
    initialPageVariables();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await excel.readExcelFile(context, widget.title);
      setState(() {
        currentExcelData = getHoldFilteredData(excel, selectedState);
      });
      excel.calculateTotalWeight(currentExcelData);
    });
  }

  @override
  Widget build(BuildContext context) {
    var excel = context.watch<ExcelProvider>();
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        widget.onPop();
      },
      child: Scaffold(
        appBar: buildAppBar(excel.selectedFileLocalPath.split('/').last,
            onPressed: () {
          widget.onPop();
        }, actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: IconButton(
              onPressed: () async {

               // _initialize();
                markDialog(
                  context,
                  rowData: [],
                  isNew: true,
                  initialize: _initialize, // دالة بتعمل setState أو refresh
                );
              },
              icon: const Icon(
                Icons.add_box_outlined,
              ),
            ),
          ),
        ]),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _searchWidget(),
              const SizedBox(height: 5),
              //filter
              filterItems(
                holdFilters,
                selectedState,
                onTap: (index) {
                  setState(() {
                    selectedState = index;
                  });
                  excel.filterExcelData(widget.title);
                  setState(() {
                    currentExcelData =
                        getHoldFilteredData(excel, selectedState);
                  });
                  excel.calculateTotalWeight(currentExcelData);
                },
              ),
              const SizedBox(height: 10),
              totalWeightWidget(context),
              if (excel.selectedRows.where((e) => e == true).length > 1)
                AllActionButtonWidget(
                  currentExcelData: currentExcelData,
                  title: widget.title,
                  initial: _initialize,
                ),
              _excelDataBody(),
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

  Expanded _excelDataBody() {
    var set = context.watch<AppSettingsProvider>();
    return Expanded(
      child: RefreshIndicator(
        color: AppStaticColor.primary,
        onRefresh: _initialize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            searchedList.isEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: excel.allExcelData.isEmpty
                        ? Column(
                            children: [
                              const Center(child: Text('● ● ● ● ●')),
                              deleteForeverWidget(
                                context,
                                permDelete: () async {
                                  context.pop();
                                  await excel
                                      .deleteFileCompletely(
                                    context,
                                    init: _initialize,
                                  )
                                      .then((_) {
                                    setState(() {});
                                    if (mounted) {
                                      context.pushReplacement(
                                        AppRouters.kHomeView,
                                      );
                                    }
                                  });
                                },
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ExcelTable(
                                excelData: currentExcelData,
                                editMaterialListPage: true,
                                preprationsDone: (row) {},
                                actionTap: (rowData) {
                                  int rowIndex = excel.allExcelData.indexWhere(
                                      (row) => listEquals(row, rowData));
                                  print('rowIndex $rowIndex');
                                  markDialog(
                                    context,
                                    rowData: rowData,
                                    rowIndex: rowIndex,
                                    initialize: () async {
                                      await _initialize();
                                      setState(() {});
                                    },
                                    btnText: excel.isRowInUnHold(rowData)
                                        ? "Hold"
                                        : "Un-Hold",
                                    btnTap: excel.isRowInUnHold(rowData)
                                        ? () async {
                                            pr("make hold action");
                                            context.pop();
                                            await excel
                                                .updateMultipleExcelRows(
                                              context,
                                              rowsToUpdate: [rowData],
                                              columnName: "HOLD",
                                              newValue: "hold",
                                              currentStep: widget.title,
                                            )
                                                .then((_) async {
                                              await _initialize();
                                              setState(() {});
                                            });
                                          }
                                        : () async {
                                            pr("make un-hold action");
                                            context.pop();
                                            await excel
                                                .updateMultipleExcelRows(
                                              context,
                                              rowsToUpdate: [rowData],
                                              columnName: "HOLD",
                                              newValue: "-",
                                              currentStep: widget.title,
                                            )
                                                .then((_) async {
                                              await _initialize();
                                              setState(() {});
                                            });
                                          },
                                  );
                                },
                              ),
                              deleteForeverWidget(
                                context,
                                permDelete: () async {
                                  context.pop();
                                  await excel
                                      .deleteFileCompletely(context,
                                          init: _initialize)
                                      .then((_) {
                                    setState(() {});
                                    if (mounted) {
                                      context.pushReplacement(
                                          AppRouters.kHomeView);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                  )
                : SingleChildScrollView(
                    child: ExcelTable(
                      excelData: searchedList,
                      editMaterialListPage: true,
                      preprationsDone: (row) {},
                      actionTap: (rowData) {
                        int rowIndex = excel.allExcelData
                            .indexWhere((row) => listEquals(row, rowData));
                        print('rowIndex $rowIndex');
                        markDialog(
                          context,
                          rowData: rowData,
                          rowIndex: rowIndex,
                          initialize: () async {
                            await _initialize();
                            setState(() {});
                          },
                          btnText:
                              excel.isRowInUnHold(rowData) ? "Hold" : "Un-Hold",
                          btnTap: excel.isRowInUnHold(rowData)
                              ? () async {
                                  pr("make hold action");
                                  context.pop();
                                  await excel
                                      .updateMultipleExcelRows(
                                    context,
                                    rowsToUpdate: [rowData],
                                    columnName: "HOLD",
                                    newValue: "hold",
                                    currentStep: widget.title,
                                  )
                                      .then((_) async {
                                    await _initialize();
                                    setState(() {});
                                  });
                                }
                              : () async {
                                  pr("make un-hold action");
                                  context.pop();
                                  await excel
                                      .updateMultipleExcelRows(
                                    context,
                                    rowsToUpdate: [rowData],
                                    columnName: "HOLD",
                                    newValue: "-",
                                    currentStep: widget.title,
                                  )
                                      .then((_) async {
                                    await _initialize();
                                    setState(() {});
                                  });
                                },
                        );
                      },
                    ),
                  ),
            if (set.load) progress(),
          ],
        ),
      ),
    );
  }

  searchFunction(String query) {
    var ex = context.read<ExcelProvider>();
    searchedList.clear();
    if (currentExcelData.isEmpty) return [];

    List<String> headers = ex.headerRow;

    int columnIndex = headers.indexOf('MARK');
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
      excel.calculateTotalWeight(searchedList);
    }
  }
}


/* import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/utils/directions.dart';
import 'package:energya_ind/core/utils/extentions.dart';
import 'package:energya_ind/core/utils/styles.dart';
import 'package:energya_ind/core/widgets/custom_navigation_button.dart';
import 'package:energya_ind/core/widgets/progress.dart';
import 'package:energya_ind/export.dart';
import 'package:energya_ind/frontend/home/widgets/text_feilds.dart';
import 'package:energya_ind/frontend/home/view/material/widgets/tags_tree_view.dart';
import 'package:energya_ind/frontend/home/view/production/widgets/excel_table.dart';
import 'package:energya_ind/frontend/home/view/production/widgets/vertical_tabel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MaterialStep2Layout extends StatefulWidget {
  const MaterialStep2Layout({
    super.key,
    required this.title,
    this.isPro = true,
    this.holdWidget,
  });

  final String title;
  final bool isPro;
  final Widget Function(int, bool)? holdWidget;

  @override
  State<MaterialStep2Layout> createState() => _ProductionStep2LayoutState();
}

class _ProductionStep2LayoutState extends State<MaterialStep2Layout> {
  final TextEditingController searchController = TextEditingController();
  List<List<String>> excelData = [];
  int selectedState = 0;
  late ExcelFileProvider ex;
  List<List<String>> searchedList = [];
  
  @override
  void initState() {
    super.initState();
    ex = Provider.of<ExcelFileProvider>(context, listen: false);
    _init();
  }

  init() {
    setState(() {
      searchController.clear();
      tagsExpansionState.clear();
      ordersExpansionState.clear();
      excelData.clear();
      searchedList.clear();
    });
  }

  Future<void> _init() async {
    setState(() {
      selectedState = 0;
      excelData.clear();
      searchedList.clear();
      searchController.clear();
      ex.enabledHoldRows.clear();
    });

    final data = await ex.readExcelFile(widget.title);
    ex.changeTotalMarks(ex.calculateTotalWeight(data, 'T.WEIGHT'));

    setState(() => excelData = data);
    await ex.initHoldExcelDataBode(excelData);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, __) async => ex.changeProductionStep(0),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _searchWidget(),
              const SizedBox(height: 5),
              //filter
              filterItems(ex),
              const SizedBox(height: 10),
              _totalWeightWidget(),
              _excelDataBody(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppStaticColor.primary.withAlpha(128),
      title: Text(
        ex.selectedReleaseLocalPath.split('/').last,
        style:
            Styles.textStyle16600.copyWith(color: Colors.white70, fontSize: 18),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () => ex.changeEditMaterialStep(0),
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }

  Expanded _excelDataBody() {
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
                    child: excelData.isEmpty
                        ? const Center(child: Text("....."))
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ExcelTable(
                                excelData: excelData,
                                initFunction: _init,
                                title: widget.title,
                                isProd: widget.isPro,
                                enabledRows: ex.enabledHoldRows,
                                selectedRows: ex.selectedRows,
                                holdWidget: (selectedIndex, isSelected) {
                                  return IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      print(ex.excelData[selectedIndex + 1]);
                                      markDialog(selectedIndex);
                                    },
                                    icon: const Icon(
                                      Icons.subdirectory_arrow_right,
                                      color: Color.fromARGB(255, 188, 151, 39),
                                    ),
                                  );
                                },
                                unHoldWidget: (selectedIndex, isSelected) {
                                  return IconButton(
                                    onPressed: () {
                                      print(ex.excelData[selectedIndex + 1]);
                                      markDialog(
                                        selectedIndex,
                                        btnText: 'Un-Hold',
                                        btnTap: () async {
                                          context.pop();
                                          await ex.updateHoldValue(
                                              selectedIndex + 1, widget.title,
                                              unHold: true);

                                          await _init();
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.subdirectory_arrow_left,
                                      color: Color.fromARGB(255, 188, 151, 39),
                                    ),
                                  );
                                },
                                moreDirsOnSelected: (v, i) async {},
                                editRowFun: (selectedIndex, isSelected) {
                                    markDialog(
                                      selectedIndex,
                                      btnText: 'Edit this Row',
                                      btnColor: Colors.green,
                                      isEdit: true,
                                      editTap: (updatedData) async {
                                        print(
                                            "بيانات الصف بعد التعديل: $updatedData");

                                        await ex.editExcelRow(
                                            selectedIndex + 1, updatedData);

                                        await _init();
                                      },
                                    );
                                },
                                removeRowFun: (selectedIndex, isSelected) {
                                  markDialog(
                                    selectedIndex,
                                    btnText: 'Remove this Row',
                                    btnColor: Colors.red,
                                    btnTap: () async {
                                      context.pop();
                                      await ex
                                          .deleteExcelRow(selectedIndex + 1);
                                      await _init();
                                    },
                                  );
                                },
                              ),
                              deleteForeverWidget(),
                            ],
                          ),
                  )
                : SingleChildScrollView(
                    child: ExcelTable(
                      excelData: searchedList,
                      initFunction: _init,
                      title: widget.title,
                      isProd: widget.isPro,
                      enabledRows: ex.enabledHoldRows,
                      selectedRows: ex.selectedRows,
                      holdWidget: (selectedIndex, isSelected) {
                        return IconButton(
                          onPressed: () {
                            print(ex.excelData[selectedIndex + 1]);
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                insetPadding: EdgeInsets.zero,
                                backgroundColor:
                                    const Color.fromARGB(255, 5, 34, 62),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 10),
                                    const Text('Selected Mark Data'),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      //height: context.height * .4,
                                      child: VerticalTable(
                                        headers: ex.excelData[0],
                                        data: ex.excelData[selectedIndex + 1],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: CustomNavigatorButton(
                                        buttonName: 'Hold',
                                        borderRadius: 40,
                                        onTap: () async {
                                          context.pop();
                                          await ex.updateHoldValue(
                                            selectedIndex + 1,
                                            widget.title,
                                          );

                                          await _init();
                                        },
                                      ),
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
                          icon: const Icon(
                            Icons.subdirectory_arrow_right,
                            color: Color.fromARGB(255, 188, 151, 39),
                          ),
                        );
                      },
                      unHoldWidget: (selectedIndex, isSelected) {
                        return IconButton(
                          onPressed: () {
                            pr(ex.excelData[selectedIndex + 1]);
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                insetPadding: EdgeInsets.zero,
                                backgroundColor:
                                    const Color.fromARGB(255, 5, 34, 62),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 10),
                                    const Text('Selected Mark Data'),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      //height: context.height * .4,
                                      child: VerticalTable(
                                        headers: ex.excelData[0],
                                        data: ex.excelData[selectedIndex + 1],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: CustomNavigatorButton(
                                        buttonName: 'Un-Hold',
                                        borderRadius: 40,
                                        onTap: () async {
                                          context.pop();
                                          await ex.updateHoldValue(
                                              selectedIndex + 1, widget.title,
                                              unHold: true);

                                          await _init();
                                        },
                                      ),
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
                          icon: const Icon(
                            Icons.subdirectory_arrow_left,
                            color: Color.fromARGB(255, 188, 151, 39),
                          ),
                        );
                      },
                      moreDirsOnSelected: (v, i) async {},
                    ),
                  ),
            if (ex.load) progress(),
          ],
        ),
      ),
    );
  }

  Future<dynamic> markDialog(int selectedIndex,
      {String? btnText,
      void Function()? btnTap,
      Color? btnColor,
      bool? isEdit,
      void Function(List<String> updatedData)? editTap}) {
    final GlobalKey<VerticalTableState> tableKey =
        GlobalKey<VerticalTableState>();
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: const Color.fromARGB(255, 5, 34, 62),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const Text('Selected Mark Data'),
                const SizedBox(height: 10),
                SizedBox(
                  child: VerticalTable(
                    key: tableKey,
                    headers: ex.excelData[0],
                    data: ex.excelData[selectedIndex + 1],
                    isEdit: isEdit ?? false,
                  ),
                ),
                /*   SizedBox(
                //height: context.height * .4,
                child: VerticalTable(
                  headers: ex.excelData[0],
                  data: ex.excelData[selectedIndex + 1],
                ),
              ), */
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CustomNavigatorButton(
                    buttonName: btnText ?? 'Hold',
                    borderRadius: 40,
                    btnColor: btnColor,
                    onTap: isEdit ?? false
                        ? () {
                            context.pop();
                            if (editTap != null) {
                              List<String> updatedValues =
                                  tableKey.currentState!.getUpdatedValues();
                              pr("القيم المحدثة: $updatedValues");
                              editTap(updatedValues);
                            }
                          }
                        : btnTap ??
                            () async {
                              context.pop();
                              await ex.updateHoldValue(
                                selectedIndex + 1,
                                widget.title,
                              );

                              await _init();
                            },
                  ),
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

  InkWell deleteForeverWidget() {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Are you sure?? \n\nWhen you delete it, you will not be able to recover all the changes previously made to it',
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        context.pop();
                        ex.deleteFileCompletely(context, init).then((_) {
                          context.NavigatereplaceTo(AppRouters.kHomeView);
                        });
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.redAccent, width: 3),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_forever_outlined,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Deleted Material List',
                              style: TextStyle(color: Colors.redAccent),
                            )
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppStaticColor.primary),
                        ))
                  ],
                ),
              );
            });
      },
      child: Container(
        height: 65,
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red, width: 3),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_forever_outlined,
              color: Colors.red,
            ),
            SizedBox(width: 10),
            Text(
              'Deleted Material List',
              style: TextStyle(color: Colors.red),
            )
          ],
        ),
      ),
    );
  }

  Widget _searchWidget() {
    return TextFeild(
      hintText: 'Search on Marks....',
      prefixIcon: Icons.note_add,
      controller: searchController,
      alpha: .1,
      suffix: IconButton(
        onPressed: () {
          setState(() {
            searchedList.clear();
            searchController.clear();
          });
        },
        icon: const Icon(
          Icons.close,
          color: Colors.redAccent,
        ),
      ),
      onChanged: (v) {
        setState(() {
          searchedList = searchFunction(v, excelData);
        });
        print(searchedList.length);
      },
    );
  }

  List<List<String>> searchFunction(
      String searchTerm, List<List<String>> excelData) {
    searchedList.clear();
    if (excelData.isEmpty) return [];

    List<String> headers = ex.excelData[0];
    print(headers);
    int columnIndex = headers.indexOf('MARK');

    if (columnIndex == -1) {
      pr("⚠️ لم يتم العثور على العمود: MARK");
      return [];
    } else {
      setState(() {
        searchedList.add(headers);
      });
      searchedList.addAll(
        ex.excelData.skip(1).where((row) {
          return row.isNotEmpty &&
              row[columnIndex].toLowerCase().contains(searchTerm.toLowerCase());
        }).toList(),
      );
    }

    return searchedList;
  }

  Widget _totalWeightWidget() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              text: 'Total :   ',
              style: Styles.textStyle16600
                  .copyWith(fontSize: 20, color: Colors.white.withAlpha(180)),
              children: [
                TextSpan(
                  text: '${ex.totalWeight}',
                  style: Styles.textStyle16600.copyWith(
                      fontSize: 24, color: Colors.white.withAlpha(230)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
              height: 2, width: context.width * .9, color: Colors.white10),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget filterItems(ExcelFileProvider ex) {
    final filters = ['All', 'Hold', 'Un-Hold'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          return filterBox(
            filters[index],
            color: selectedState == index
                ? Colors.blueGrey
                : AppStaticColor.primary.withAlpha(77),
            onTap: () => onFilterSelected(index, ex),
          );
        }),
      ),
    );
  }

  Widget filterBox(String text, {Color? color, void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        child: Align(child: Text(text)),
      ),
    );
  }

  Future<void> onFilterSelected(int index, ExcelFileProvider ex) async {
    setState(() => selectedState = index);
    //await ex.filterExcelData(ex.excelData, widget.title);
    await ex.updateHolds();
    switch (index) {
      case 0:
        setState(() {
          excelData = List.from(ex.excelData);
        });
        ex.initExcelDataBode(ex.excelData, widget.title);
        pr('All: ${excelData.length}');
        break;
      case 1:
        setState(() {
          excelData = List.from(ex.holdExcelData);
        });
        ex.initExcelDataBode(ex.holdExcelData, widget.title);
        pr('Hold: ${ex.holdExcelData.length}');
        break;
      case 2:
        setState(() {
          excelData = List.from(ex.unholdExcelData);
        });
        ex.initExcelDataBode(ex.unholdExcelData, widget.title);
        pr('Un-Hold: ${ex.unholdExcelData.length}');
        break;
    }

    ex.changeTotalMarks(ex.calculateTotalWeight(excelData, 'T.WEIGHT'));
  }

  List<List<String>> getFilteredData(ExcelFileProvider ex) {
    switch (selectedState) {
      case 1:
        return ex.holdExcelData;
      case 2:
        return ex.unholdExcelData;
      default:
        return ex.excelData;
    }
  }
}
 */