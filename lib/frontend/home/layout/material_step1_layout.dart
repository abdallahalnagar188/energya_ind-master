import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/app_settings_provider.dart';
import 'package:energya_ind/core/helper/providers/excel_provider.dart';
import 'package:energya_ind/core/helper/providers/tag_provider.dart';
import 'package:energya_ind/core/utils/styles.dart';
import 'package:energya_ind/core/widgets/custom_navigation_button.dart';
import 'package:energya_ind/core/widgets/progress.dart';
import 'package:energya_ind/core/widgets/select_tag_release.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:energya_ind/core/utils/pdf.dart';

class MaterialStep1Layout extends StatefulWidget {
  final String title;
  final bool isProd;
  final bool isReport;
  final Function() onNext;

  const MaterialStep1Layout({
    super.key,
    required this.title,
    this.isProd = true,
    this.isReport = false,
    required this.onNext,
  });

  @override
  State<MaterialStep1Layout> createState() => _ProductionStepLayoutState();
}

class _ProductionStepLayoutState extends State<MaterialStep1Layout> {
  late TextEditingController searchController;
  late TagProvider tagProvider;

  String searchHint = 'Search';
  List<Map<String, dynamic>> searchedList = [];
  Map<String, dynamic> selectedRelease = {};
  List<Map<String, dynamic>> filesInLocal = [];

  String releasePressed = '';

  late ExcelProvider excel;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    tagProvider = Provider.of<TagProvider>(context, listen: false);
    excel = context.read<ExcelProvider>();
    _initializeData();
  }

  void _clearSearchState() {
    setState(() {
      searchedList.clear();
      selectedRelease.clear();
      searchController.clear();
    });
  }

  Future<void> _initializeData() async {
    _clearSearchState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchAndFilterTags();
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _fetchAndFilterTags() async {
    var set = context.read<AppSettingsProvider>();
    set.startLoad();
    await tagProvider.getAllTagsData();

    tagProvider.tags.forEach((projectName, orders) {
      Map<String, List<Map<String, dynamic>>> filteredOrders = {};

      orders.forEach((orderName, releases) {
        List<Map<String, dynamic>> filteredReleases = releases
            .where((release) =>
                release['file'] != null && release['file'].isNotEmpty)
            .toList();

        if (filteredReleases.isNotEmpty) {
          filteredOrders[orderName] = filteredReleases;
        }
      });

      if (filteredOrders.isNotEmpty) {
        tagProvider.fillFilteredTags(projectName, filteredOrders);
      }
    });
    if (mounted) {
      filesInLocal =
          await excel.checkFilesIfInLocal(context, tagProvider.filteredTags);
    }
    set.endLoad();
  }

  @override
  Widget build(BuildContext context) {
    var set = context.watch<AppSettingsProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStaticColor.primary.withValues(alpha: .5),
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Consumer<ExcelProvider>(
        builder: (context, excel, child) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: RefreshIndicator(
              color: AppStaticColor.primary,
              onRefresh: _initializeData,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  tagProvider.filteredTags.isEmpty
                      ? _noFilesWidget()
                      : _productionBody(),
                  if (set.load) progress(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _noFilesWidget() {
    return Center(
      child: Text(
        'لا يوجد أي ملفات حاليًا\nيمكنك إنشاء معرف ورفع ملف ثم العودة',
        style: Styles.textStyle16600.copyWith(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _productionBody() {
    return Column(
      children: [
        _searchWidget(),
        const SizedBox(height: 10),
        Expanded(
          child: SelectTagRelease(
            searchedList: searchedList,
            selectedRelease: selectedRelease,
            filteredTags: tagProvider.filteredTags,
            isProd: true,
            filter: true,
            download: _downloadFile,
            select: _selectRelease,
            filesInLocal: filesInLocal,
            searchController: searchController,
            selectSearchedTag: _selectSearchedTag,
            initReleasePresed: _resetSelection,
            releasePressed: releasePressed,
            onPrintProject: widget.isReport ? (projectName) async {
               await _handlePrintProject(context, projectName);
            } : null,
          ),
        ),
        const SizedBox(height: 16),
        _nextButton(),
      ],
    );
  }

  Widget _searchWidget() {
    return TextField(
      decoration: InputDecoration(
        hintText: searchHint,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.withValues(alpha: .1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              searchedList.clear();
            });
          },
          icon: const Icon(
            Icons.close,
            color: Colors.redAccent,
          ),
        ),
      ),
      controller: searchController,
      onChanged: (v) {
        setState(() {
          searchedList = searchFun(context, v, filter: true);
        });
      },
    );
  }

  Widget _nextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: CustomNavigatorButton(
        buttonName: 'Next',
        borderRadius: 40,
        onTap: () {
          if (excel.selectedFileLocalPath.isNotEmpty) {
            if (widget.title == 'Cutting') {
              String fileName = excel.selectedFileLocalPath.split('/').last;
              if (!fileName.toUpperCase().startsWith('T-L')) {
                showTopSnackBar(context,
                    'يجب أن يبدأ اسم الملف بـ T-L في مرحلة التقطيع (Cutting)',
                    error: true);
                return;
              }
            }
            pr('selected file: ${excel.selectedFileLocalPath}');
            widget.onNext();
          }
        },
      ),
    );
  }

  Future<void> _handlePrintProject(BuildContext context, String projectName) async {
    var set = context.read<AppSettingsProvider>();
    set.startLoad();
    try {
      List<String> localPaths = [];

      Map<String, List<Map<String, dynamic>>>? orders = tagProvider.filteredTags[projectName];
      if (orders != null) {
        for (var entry in orders.entries) {
          String orderId = entry.key;
          List<Map<String, dynamic>> releases = entry.value;

          for (var release in releases) {
            String releaseName = release['release'].toString();

            var fileData = filesInLocal.firstWhere(
              (f) =>
                  f['projectName'] == projectName &&
                  f['orderName'] == orderId &&
                  f['releaseName'] == releaseName,
              orElse: () => <String, dynamic>{},
            );

            String? localPath;
            if (fileData.isNotEmpty && fileData['isLocal'] == true) {
               localPath = fileData['localFilePath'];
            } else if (fileData.isNotEmpty && fileData['isLocal'] == false) {
               localPath = await excel.saveFileLocaly(
                 context,
                 projectName: projectName,
                 orderName: orderId,
                 releaseName: releaseName,
                 firebasePath: fileData['firebasePath'],
               );
               if (mounted) {
                 filesInLocal = await excel.checkFilesIfInLocal(context, tagProvider.filteredTags);
               }
            }

            if (localPath != null && localPath.isNotEmpty) {
               localPaths.add(localPath);
            }
          }
        }
      }

      if (localPaths.isNotEmpty) {
        Map<String, double> aggregatedWeights = await excel.calculateProjectAggregatedWeights(
          localFilePaths: localPaths,
          context: context,
        );
        await generateProjectFullReport(context, projectName, aggregatedWeights);
      }
    } catch (e) {
      pr('Error generating full report: $e');
    } finally {
      set.endLoad();
    }
  }

  Future<void> _downloadFile({
    required String projectName,
    required String orderName,
    required String releaseName,
    required String firebasePath,
  }) async {
    await excel.saveFileLocaly(
      context,
      projectName: projectName,
      orderName: orderName,
      releaseName: releaseName,
      firebasePath: firebasePath,
    );
    _initializeData();
  }

  void _selectRelease(
      Map<String, dynamic> release, String proj, String ord, String rel) {
    setState(() {
      selectedRelease = release;
    });
    _updateLocalFilePath(proj, ord, rel);
  }

  void _selectSearchedTag(Map<String, dynamic> selectedTag) {
    List<String> l = (selectedTag['name'] as String).split(' - ');
    setState(() {
      selectedRelease = {};
      releasePressed = selectedTag['name'];
    });
    _updateLocalFilePath(l[0], l[1], l[2]);
  }

  void _updateLocalFilePath(String proj, String ord, String rel) {
    var fileData = filesInLocal.firstWhere(
      (file) =>
          file['projectName'] == proj &&
          file['orderName'] == ord &&
          file['releaseName'] == rel,
      orElse: () => {},
    );
    setState(
      () {
        excel.selectedFileLocalPath =
            fileData.isNotEmpty && fileData['isLocal'] == true
                ? fileData['localFilePath']
                : '';
      },
    );
  }

  void _resetSelection() {
    setState(() {
      selectedRelease = {};
    });
  }
}


/* import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/excel_file_provider.dart';
import 'package:energya_ind/core/helper/providers/tag_provider.dart';
import 'package:energya_ind/core/utils/styles.dart';
import 'package:energya_ind/core/widgets/custom_navigation_button.dart';
import 'package:energya_ind/core/widgets/progress.dart';
import 'package:energya_ind/core/widgets/select_tag_release.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MaterialStep1Layout extends StatefulWidget {
  final String title;
  final bool isProd;
  final bool isReport;

  const MaterialStep1Layout({
    super.key,
    required this.title,
    this.isProd = true,
    this.isReport = false,
  });

  @override
  State<MaterialStep1Layout> createState() => _ProductionStepLayoutState();
}

class _ProductionStepLayoutState extends State<MaterialStep1Layout> {
  late TextEditingController searchController;
  late TagProvider tagProvider;
  late ExcelFileProvider excelProvider;

  String searchHint = 'Search';
  List<Map<String, dynamic>> searchedList = [];
  Map<String, dynamic> selectedRelease = {};
  List<Map<String, dynamic>> filesInLocal = [];

  String releasePressed = '';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    tagProvider = Provider.of<TagProvider>(context, listen: false);
    excelProvider = Provider.of<ExcelFileProvider>(context, listen: false);
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      searchedList.clear();
      selectedRelease.clear();
      searchController.clear();
    });
    await tagProvider.getAllTagsData();

    tagProvider.tags.forEach((projectName, orders) {
      Map<String, List<Map<String, dynamic>>> filteredOrders = {};

      orders.forEach((orderName, releases) {
        List<Map<String, dynamic>> filteredReleases = releases
            .where((release) =>
                release['file'] != null && release['file'].isNotEmpty)
            .toList();

        if (filteredReleases.isNotEmpty) {
          filteredOrders[orderName] = filteredReleases;
        }
      });

      if (filteredOrders.isNotEmpty) {
        tagProvider.fillFilteredTags(projectName, filteredOrders);
      }
    });

    filesInLocal =
        await excelProvider.checkFilesIfinLocal(tagProvider.filteredTags);
    await tagProvider.getAllTagsData();
    tagProvider.tags.forEach((projectName, orders) {
      Map<String, List<Map<String, dynamic>>> filteredOrders = {};

      orders.forEach((orderName, releases) {
        List<Map<String, dynamic>> filteredReleases = releases
            .where((release) =>
                release['file'] != null && release['file'].isNotEmpty)
            .toList();

        if (filteredReleases.isNotEmpty) {
          filteredOrders[orderName] = filteredReleases;
        }
      });

      if (filteredOrders.isNotEmpty) {
        tagProvider.fillFilteredTags(projectName, filteredOrders);
      }
    });

    filesInLocal =
        await excelProvider.checkFilesIfinLocal(tagProvider.filteredTags);
    setState(() {
      excelProvider.load = false;
      tagProvider.load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStaticColor.primary.withValues(alpha: .5),
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Consumer<ExcelFileProvider>(
        builder: (context, excel, child) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: RefreshIndicator(
              color: AppStaticColor.primary,
              onRefresh: _initializeData,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  tagProvider.filteredTags.isEmpty
                      ? _noFilesWidget()
                      : _productionBody(),
                  if (excel.prog == .1 && excel.startDown)
                    progressLoad(excel.prog),
                  if (tagProvider.load) progress(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _noFilesWidget() {
    return Center(
      child: Text(
        'لا يوجد أي ملفات حاليًا\nيمكنك إنشاء معرف ورفع ملف ثم العودة',
        style: Styles.textStyle16600.copyWith(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _productionBody() {
    return Column(
      children: [
        _searchWidget(),
        const SizedBox(height: 10),
        Expanded(
          child: SelectTagRelease(
            searchedList: searchedList,
            selectedRelease: selectedRelease,
            filteredTags: tagProvider.filteredTags,
            isProd: true,
            filter: true,
            download: _downloadFile,
            select: _selectRelease,
            filesInLocal: filesInLocal,
            searchController: searchController,
            selectSearchedTag: _selectSearchedTag,
            initReleasePresed: _resetSelection,
            releasePressed: releasePressed,
          ),
        ),
        const SizedBox(height: 16),
        _nextButton(),
      ],
    );
  }

  Widget _searchWidget() {
    return TextField(
      decoration: InputDecoration(
        hintText: searchHint,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.withValues(alpha: .1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              searchedList.clear();
            });
          },
          icon: const Icon(
            Icons.close,
            color: Colors.redAccent,
          ),
        ),
      ),
      controller: searchController,
      onChanged: (v) {
        setState(() {
          searchedList = searchFun(context, v, filter: true);
        });
      },
    );
  }

  Widget _nextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: CustomNavigatorButton(
        buttonName: 'Next',
        borderRadius: 40,
        onTap: () {
          if (excelProvider.selectedReleaseLocalPath.isNotEmpty) {
            if (widget.isProd) excelProvider.changeProductionStep(1);
            if (!widget.isProd) excelProvider.changeEditMaterialStep(1);
            if (widget.isReport) excelProvider.changeReportsStep(1);
          }
        },
      ),
    );
  }

  Future<void> _downloadFile({
    required String projectName,
    required String orderName,
    required String releaseName,
    required String firebasePath,
  }) async {
    await excelProvider.saveFileLocaly(
      context,
      projectName: projectName,
      orderName: orderName,
      releaseName: releaseName,
      firebasePath: firebasePath,
    );
    _initializeData();
  }

  void _selectRelease(
      Map<String, dynamic> release, String proj, String ord, String rel) {
    setState(() {
      selectedRelease = release;
    });
    _updateLocalFilePath(proj, ord, rel);
  }

  void _selectSearchedTag(Map<String, dynamic> selectedTag) {
    List<String> l = (selectedTag['name'] as String).split(' - ');
    setState(() {
      selectedRelease = {};
      releasePressed = selectedTag['name'];
    });
    _updateLocalFilePath(l[0], l[1], l[2]);
  }

  void _updateLocalFilePath(String proj, String ord, String rel) {
    var fileData = filesInLocal.firstWhere(
      (file) =>
          file['projectName'] == proj &&
          file['orderName'] == ord &&
          file['releaseName'] == rel,
      orElse: () => {},
    );
    setState(
      () {
        excelProvider.selectedReleaseLocalPath =
            fileData.isNotEmpty && fileData['isLocal'] == true
                ? fileData['localFilePath']
                : '';
      },
    );
  }

  void _resetSelection() {
    setState(() {
      selectedRelease = {};
    });
  }
}
 */