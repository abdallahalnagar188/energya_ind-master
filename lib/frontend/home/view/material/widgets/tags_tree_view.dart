import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/config/app_strings.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/excel_file_provider.dart';
import 'package:energya_ind/core/helper/providers/tag_provider.dart';
import 'package:energya_ind/core/utils/expanded.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagsTreeView extends StatefulWidget {
  const TagsTreeView({
    super.key,
    required this.selectedRelease,
    required this.select,
    required this.initSelectedRelease,
    this.filteredTags,
    this.filter = false,
    this.isProd = false,
    this.filesInLocal,
    required this.download,
    this.onPrintProject,
  });
  final Map<String, dynamic> selectedRelease;
  final Function(Map<String, dynamic>, String, String, String) select;
  final Function() initSelectedRelease;
  final Map<String, dynamic>? filteredTags;
  final List<Map<String, dynamic>>? filesInLocal;
  final bool filter;
  final bool isProd;
  final Function(String)? onPrintProject;
  final Future<void> Function(
      {required String projectName,
      required String orderName,
      required String releaseName,
      required String firebasePath}) download;
  @override
  State<TagsTreeView> createState() => _TagsTreeViewState();
}

Map<String, bool> tagsExpansionState = {};
Map<String, bool> ordersExpansionState = {};

class _TagsTreeViewState extends State<TagsTreeView> {
  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<TagProvider>(context);
    var excel = Provider.of<ExcelFileProvider>(context);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(AppStrings.tagCollerction)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('● ● ● ● ●');
        return ListView(
          children: (widget.filteredTags ?? prov.tags).entries.map((tagEntry) {
            String tagName = tagEntry.key;
            Map<String, List<Map<String, dynamic>>> orders = tagEntry.value;

            return Column(
              children: [
                Container(
                  color: AppStaticColor.primary.withValues(alpha: .08),
                  child: ListTile(
                    title: Text(
                      tagName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    leading: Icon(
                      tagsExpansionState[tagName] ?? false
                          ? Icons.remove_circle_outline_outlined
                          : Icons.cancel_outlined,
                      color: AppStaticColor.primary.withValues(alpha: .8),
                      size: 20,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.onPrintProject != null)
                          IconButton(
                            icon: const Icon(Icons.print_outlined),
                            onPressed: () => widget.onPrintProject!(tagName),
                          ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        tagsExpansionState[tagName] =
                            !(tagsExpansionState[tagName] ?? false);
                      });
                    },
                  ),
                ),
                ExpandedSection(
                  expand: tagsExpansionState[tagName] ?? false,
                  child: Column(
                    children: orders.entries.map((orderEntry) {
                      String orderId = orderEntry.key;
                      List<Map<String, dynamic>> releases = orderEntry.value;

                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              "    $orderId",
                              style: const TextStyle(
                                  color: AppStaticColor.primary),
                            ),
                            trailing: Icon(
                              ordersExpansionState[orderId] ?? false
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                            ),
                            onTap: () {
                              setState(() {
                                ordersExpansionState[orderId] =
                                    !(ordersExpansionState[orderId] ?? false);
                              });
                            },
                          ),
                          ExpandedSection(
                            expand: ordersExpansionState[orderId] ?? false,
                            child: Column(
                              children: releases.map((release) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: widget.selectedRelease == release &&
                                            widget.selectedRelease['file'] !=
                                                null &&
                                            (widget.isProd == false
                                                ? (widget.selectedRelease[
                                                        'file'] as Map)
                                                    .isEmpty
                                                : (widget.selectedRelease[
                                                        'file'] as Map)
                                                    .isNotEmpty)
                                        ? Colors.red.withValues(alpha: .05)
                                        : null,
                                    borderRadius: BorderRadius.circular(80),
                                  ),
                                  child: ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("${release['release']}"),
                                        const SizedBox(
                                          width: 30,
                                        ),
                                        download(
                                            tagName, orderId, release, excel),
                                      ],
                                    ),
                                    subtitle: release['file'] != null &&
                                            (release['file'] as Map).isNotEmpty
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "${release['file']['fileName']}",
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.green,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                getDate(release['file']
                                                        ['uploadedAt']
                                                    as Timestamp),
                                              ),
                                            ],
                                          )
                                        : null,
                                    leading: const Padding(
                                      padding: EdgeInsets.only(left: 30),
                                      child: Icon(
                                        Icons.file_present,
                                        color: Colors.green,
                                      ),
                                    ),
                                    onTap: (release['file'] != null &&
                                                (release['file'] as Map)
                                                    .isEmpty) ||
                                            widget.isProd == true
                                        ? () {
                                            String projName = tagName;
                                            String ordName = orderId;
                                            String releaseName =
                                                release['release'].toString();

                                            pr('$projName-$ordName-$releaseName');
                                            widget.select(
                                              release,
                                              projName,
                                              ordName,
                                              releaseName,
                                            );
                                          }
                                        : () {
                                            widget.initSelectedRelease();
                                            showTopSnackBar(context,
                                                ' تحتوى على فايل بالفعل');
                                          },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(
                  height: 15,
                )
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget download(tagName, orderId, release, ExcelFileProvider excel) {
    var fileData = widget.filesInLocal?.firstWhere(
      (file) =>
          file['projectName'] == tagName &&
          file['orderName'] == orderId &&
          file['releaseName'] == release['release'],
      orElse: () => {},
    );
    if (fileData != null && fileData.isNotEmpty && !fileData['isLocal']) {
      return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: InkWell(
          onTap: () async {
            widget.download(
              projectName: fileData['projectName'],
              orderName: fileData['orderName'],
              releaseName: fileData['releaseName'],
              firebasePath: fileData['firebasePath'],
            );
          },
          child: const Icon(
            Icons.cloud_download_rounded,
            color: AppStaticColor.text,
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
