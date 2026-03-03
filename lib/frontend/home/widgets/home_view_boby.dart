import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/helper/providers/tag_provider.dart';
import 'package:energya_ind/core/helper/providers/user_provider.dart';
import 'package:energya_ind/core/utils/app_routers.dart';
import 'package:energya_ind/core/utils/extentions.dart';
import 'package:energya_ind/frontend/home/widgets/head_line_bar_home_view.dart';
import 'package:energya_ind/frontend/home/widgets/material_list_item.dart';
import 'package:energya_ind/frontend/home/widgets/production_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  @override
  void initState() {
    var user = Provider.of<UserProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      showTopSnackBar(context, 'Hello ${user.user?.name ?? ''} 👋🏻',
          error: false);
    });
    List<Map<String, dynamic>> activeAuthoritiesMap = user.user?.authorities
            .where((auth) => auth.isActive == true)
            .map((auth) => auth.toMap())
            .toList() ??
        [];

    print('✅ active authorities: --- $activeAuthoritiesMap');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var tag = Provider.of<TagProvider>(context);
    var user = Provider.of<UserProvider>(context);
    return ListView(
      children: [
        HeadLineBar(
          headLineText: 'Production',
          secondeHeadLineText: 'View',
          onTapAction: () => context.NavigatePushTo(
            AppRouters.kProductionGridViewPage,
          ),
        ),
        const ProductionList(),
        if (user.user?.type != 'user')
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HeadLineBar(
                headLineText: 'Engineering',
                secondeHeadLineText: 'View',
                onTapAction: () => context.NavigatePushTo(
                  AppRouters.kEngineeringViewPage,
                ),
              ),
            ],
          ),
        if (user.user?.type != 'user')
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HeadLineBar(
                headLineText: 'MaterialList',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialListItem(
                    titel: 'Add',
                    iconData: Icons.add,
                    onTap: () async {
                      Map<String, dynamic> tags = await tag.getAllTagsData();
                      print(tags);
                      //   await SharedPrefs().getJsonFromString('tags');
                      context.push(AppRouters.kUploadMaterialViewPage,
                          extra: tags);
                    },
                  ),
                  MaterialListItem(
                    titel: 'Edit',
                    iconData: Icons.edit,
                    onTap: () {
                      context.push(AppRouters.kEditMaterialPage);
                    },
                  ),
                ],
              ),
            ],
          ),
        HeadLineBar(
          headLineText: 'Reports',
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12, right: 12, left: 12),
          child: MaterialListItem(
            titel: 'Add Report',
            iconData: Icons.note_add,
            onTap: () => context.NavigatePushTo(
              AppRouters.kReportsPage,
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }
}
