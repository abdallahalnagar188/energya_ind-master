import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/tag_provider.dart';
import 'package:energya_ind/core/utils/pop_up.dart';
import 'package:energya_ind/core/widgets/custom_navigation_button.dart';
import 'package:energya_ind/core/widgets/progress.dart';
import 'package:energya_ind/frontend/home/widgets/text_feilds.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EngineeringView extends StatefulWidget {
  const EngineeringView({super.key});

  @override
  State<EngineeringView> createState() => _EngineeringViewState();
}

class _EngineeringViewState extends State<EngineeringView> {
  TextEditingController projController = TextEditingController();
  TextEditingController ordController = TextEditingController();
  TextEditingController relController = TextEditingController();
  List<String> projs = [];
  List<String> ords = [];
  String projHint = '';
  String ordHint = '';

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    var tag = Provider.of<TagProvider>(context, listen: false);
    pr(tag.tags);
    projs = await tag.getTagsKeys('Proj');
    setState(() {
      projHint = 'Project Name';
      ordHint = 'Order Name';
      projController.text = '';
      ordController.text = '';
      relController.text = '';
      ords = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    var tag = Provider.of<TagProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStaticColor.primary.withValues(alpha: 0.5),
        title: const Text('Engineering'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 20, left: 8, top: 12, bottom: 12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                TextFeild(
                  suffix: tag.tags.isNotEmpty || tag.tags.keys.isNotEmpty
                      ? PopupMenuButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            size: 20,
                          ),
                          onSelected: (v) async {
                            pr(projController.text);
                            ords = await tag.getTagsKeys(
                              'Ord',
                              projectName: v,
                            );
                            setState(() {
                              projController.text = v;
                              projHint = v;
                            });
                          },
                          itemBuilder: (context) {
                            return projs
                                .map(
                                  (e) => PopupMenuItem(
                                    value: e,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          e,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList();
                          },
                        )
                      : null,
                  prefixIcon: Icons.note_add,
                  hintText: projHint,
                  controller: projController,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFeild(
                  hintText: ordHint,
                  prefixIcon: Icons.note_add,
                  suffix: tag.tags.isNotEmpty
                      ? PopMenu(
                          list: ords,
                          onSelected: (v) {
                            setState(() {
                              ordController.text = v;
                              ordHint = v;
                            });
                          },
                        )
                      : null,
                  controller: ordController,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFeild(
                  hintText: 'Release Name',
                  prefixIcon: Icons.note_add,
                  controller: relController,
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: CustomNavigatorButton(
                    buttonName: 'Create',
                    borderRadius: 40,
                    onTap: () async {
                      if (projController.text.isNotEmpty ||
                          ordController.text.isNotEmpty ||
                          relController.text.isNotEmpty) {
                        await tag.addTag(
                          context,
                          project: projController.text,
                          order: ordController.text,
                          release: relController.text,
                        );

                        init();
                      } else {
                        showTopSnackBar(context, 'Please Fill All Fields !');
                      }
                    },
                  ),
                ),
              ],
            ),
            if (tag.load) progress(),
          ],
        ),
      ),
    );
  }
}
