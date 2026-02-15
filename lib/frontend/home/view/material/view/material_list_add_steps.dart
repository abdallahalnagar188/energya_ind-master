import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/excel_file_provider.dart';
import 'package:energya_ind/core/utils/styles.dart';
import 'package:energya_ind/core/widgets/custom_navigation_button.dart';
import 'package:energya_ind/core/widgets/progress.dart';
import 'package:energya_ind/core/widgets/select_tag_release.dart';
import 'package:energya_ind/frontend/home/view/material/widgets/tags_tree_view.dart';
import 'package:energya_ind/frontend/home/widgets/text_feilds.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MaterialListAddSteps extends StatefulWidget {
  const MaterialListAddSteps({super.key, required this.tags});
  final Map<String, dynamic> tags;
  @override
  State<MaterialListAddSteps> createState() => _MaterialListAddStepsState();
}

class _MaterialListAddStepsState extends State<MaterialListAddSteps> {
  int currentStep = 0;
  Map<String, dynamic> selectedRelease = {};
  String projName = '';
  String ordName = '';
  String relName = '';
  bool searchPressed = false;
  String releasePressed = '';
  TextEditingController searchController = TextEditingController();
  String searchHint = 'Search ';
  List<Map<String, dynamic>> searchedList = [];
  @override
  void initState() {
    super.initState();
  }

  init() async {
    setState(() {
      projName = '';
      ordName = '';
      relName = '';
      searchPressed = false;
      releasePressed = '';
      selectedRelease.clear();
      searchController.clear();
      tagsExpansionState.clear();
      ordersExpansionState.clear();
      searchedList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    var excel = Provider.of<ExcelFileProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStaticColor.primary.withValues(alpha: 0.5),
        title: const Text('Upload Material'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.tags.keys.isNotEmpty)
              Column(
                children: [
                  buildSearchBar(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SelectTagRelease(
                      searchedList: searchedList,
                      selectedRelease: selectedRelease,
                      select: (release, proj, ord, rel) {
                        setState(() {
                          selectedRelease = release;
                          projName = proj;
                          ordName = ord;
                          relName = rel;
                        });
                      },
                      searchController: searchController,
                      releasePressed: releasePressed,
                      selectSearchedTag: (Map<String, dynamic> selectedTag) {
                        List l = (selectedTag['name'] as String).split(' - ');
                        setState(() {
                          projName = l[0];
                          ordName = l[1];
                          relName = l[2];
                          releasePressed = selectedTag['name'];
                        });
                      },
                      initReleasePresed: () {
                        setState(() {
                          releasePressed = '';
                          selectedRelease = {};
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: CustomNavigatorButton(
                      buttonName: 'Upload',
                      borderRadius: 40,
                      onTap: () async {
                        if (projName.isNotEmpty &&
                            ordName.isNotEmpty &&
                            relName.isNotEmpty &&
                            selectedRelease.isNotEmpty) {
                          excel.uploadAndSaveFile(
                            context,
                            projectName: projName,
                            orderName: ordName,
                            releaseName: relName,
                            init: init,
                          );
                        } else {
                          showTopSnackBar(
                              context, 'Please Select The Release!');
                        }
                      },
                    ),
                  ),
                ],
              ),
            if (widget.tags.keys.isEmpty)
              const Center(
                child: Text(
                  'لا يوجد إشارات حتى تقوم بالرفع عليها\nEngineering يرجى الذهاب لصفحة\nلإنشاء إشارة',
                  style: TextStyle(
                    color: AppStaticColor.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (excel.load == true) progressLoad(excel.prog),
          ],
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        searchPressed
            ? Expanded(
                child: TextFeild(
                  hintText: searchHint,
                  prefixIcon: Icons.note_add,
                  controller: searchController,
                  alpha: .1,
                  onChanged: (v) {
                    setState(() {
                      searchedList = searchFun(context, v);
                    });
                  },
                ),
              )
            : Text(
                'Please Select a Release!',
                style: Styles.textStyle16600.copyWith(
                  fontSize: 15,
                  color: AppStaticColor.darkGray.withValues(alpha: .5),
                ),
              ),
        IconButton(
          onPressed: () {
            setState(() {
              searchPressed = !searchPressed;
            });
          },
          icon: const Icon(Icons.search_outlined),
        ),
      ],
    );
  }
}
