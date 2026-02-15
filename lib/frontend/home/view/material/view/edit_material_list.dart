import 'package:energya_ind/frontend/home/layout/material_step1_layout.dart';
import 'package:energya_ind/frontend/home/layout/material_step2_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../material_controller.dart';

class EditMaterialList extends StatefulWidget {
  const EditMaterialList({super.key});

  @override
  State<EditMaterialList> createState() => _EditMaterialListState();
}

class _EditMaterialListState extends State<EditMaterialList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MaterialController(),
      child: Consumer<MaterialController>(
        builder: (context, provider, child) {
          return provider.materialStep == 0
              ? MaterialStep1Layout(
                  title: 'Edit Material-Release',
                  isProd: false,
                  onNext: () {
                    provider.changeEditMaterialStep(1);
                  },
                )
              : MaterialStep2Layout(
                  title: 'Edit Material-Release',
                  isPro: false,
                  onPop: () {
                    provider.changeEditMaterialStep(0);
                  },
                  holdWidget: (selectedIndex, isSelected) {
                    return IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.star,
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
