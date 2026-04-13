import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/utils/global_functions.dart';
import 'package:energya_ind/frontend/home/view/material/widgets/tags_tree_view.dart';
import 'package:flutter/material.dart';

class SelectTagRelease extends StatefulWidget {
  const SelectTagRelease({
    super.key,
    required this.searchedList,
    required this.selectedRelease,
    required this.select,
    required this.searchController,
    required this.releasePressed,
    required this.selectSearchedTag,
    required this.initReleasePresed,
    this.filteredTags,
    this.filter = false,
    this.isProd = false,
    this.filesInLocal,
    this.download,
  this.onPrintProject,
  });
  final List<Map<String, dynamic>> searchedList;
  final Map<String, dynamic> selectedRelease;
  final Function(Map<String, dynamic>, String, String, String) select;
  final TextEditingController searchController;
  final String releasePressed;
  final Map<String, dynamic>? filteredTags;
  final bool filter;
  final bool isProd;
  final void Function(Map<String, dynamic>) selectSearchedTag;
  final void Function() initReleasePresed;
  final List<Map<String, dynamic>>? filesInLocal;
  final Future<void> Function(
      {required String projectName,
      required String orderName,
      required String releaseName,
      required String firebasePath})? download;
  final Function(String)? onPrintProject;
  @override
  State<SelectTagRelease> createState() => _SelectTagReleaseState();
}

class _SelectTagReleaseState extends State<SelectTagRelease> {
  @override
  Widget build(BuildContext context) {
    //var excel = Provider.of<ExcelFileProvider>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.searchedList.isEmpty
            ? Expanded(
                child: TagsTreeView(
                  selectedRelease: widget.selectedRelease,
                  initSelectedRelease: widget.initReleasePresed,
                  select: (release, proj, ord, rel) {
                    widget.select(release, proj, ord, rel);
                  },
                  download: widget.download ??
                      (
                          {required projectName,
                          required orderName,
                          required releaseName,
                          required firebasePath}) async {},
                  filteredTags: widget.filteredTags,
                  filesInLocal: widget.filesInLocal,
                  isProd: widget.isProd,
                  onPrintProject: widget.onPrintProject,
                ),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: widget.searchedList.length,
                  itemBuilder: (context, i) {
                    return InkWell(
                      onTap: widget.searchedList[i]['file'].isEmpty ||
                              widget.isProd == true
                          ? () {
                              widget.selectSearchedTag(widget.searchedList[i]);
                            }
                          : () {
                              showTopSnackBar(context, 'تحتوى على فايل بالفعل');
                              widget.initReleasePresed();
                            },
                      child: Container(
                        color: widget.releasePressed ==
                                widget.searchedList[i]['name']
                            ? Colors.amber.withValues(alpha: .1)
                            : AppStaticColor.primary.withValues(alpha: .06),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: GlobalFunctions().searchMatch(
                                      widget.searchedList[i]['name'],
                                      widget.searchController,
                                    ),
                                  ),
                                  if (!widget.filter)
                                    if (widget
                                        .searchedList[i]['file'].isNotEmpty)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Icon(
                                          Icons.done_outline_outlined,
                                          color: Colors.green,
                                        ),
                                      ),
                                  if (!(widget.filesInLocal?[i]['isLocal'] ??
                                      false))
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: InkWell(
                                        onTap: () {
                                          widget.download!(
                                            projectName: widget.filesInLocal?[i]
                                                ['projectName'],
                                            orderName: widget.filesInLocal?[i]
                                                ['orderName'],
                                            releaseName: widget.filesInLocal?[i]
                                                ['releaseName'],
                                            firebasePath:
                                                widget.filesInLocal?[i]
                                                    ['firebasePath'],
                                          );
                                        },
                                        child: const Icon(
                                          Icons.cloud_download_rounded,
                                          color: AppStaticColor.text,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (widget.searchedList[i]['file'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        getDate(widget.searchedList[i]['file']
                                            ['uploadedAt'] as Timestamp),
                                        style: const TextStyle(
                                            color: AppStaticColor.text,
                                            fontSize: 14),
                                      )
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
