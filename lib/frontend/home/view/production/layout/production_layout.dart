import 'package:energya_ind/frontend/home/view/material/material_controller.dart';
import 'package:energya_ind/frontend/home/view/production/layout/production_step1_layout.dart';
import 'package:energya_ind/frontend/home/view/production/layout/production_step2_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductionLayout extends StatefulWidget {
  const ProductionLayout({
    super.key,
    required this.title,
    this.moreDirs = false,
    this.isDispatch = false,
  });
  final String title;
  final bool moreDirs;
  final bool isDispatch;
  @override
  State<ProductionLayout> createState() => _ProductionLayoutState();
}

class _ProductionLayoutState extends State<ProductionLayout> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MaterialController(),
      child: Consumer<MaterialController>(
        builder: (context, provider, child) {
          return provider.materialStep == 0
              ? ProductionStep1Layout(
                  title: widget.title,
                  onNext: () {
                    provider.changeEditMaterialStep(1);
                  },
                )
              : ProductionStep2Layout(
                  title: widget.title,
                  moreDirs: widget.moreDirs,
                  isDispatch: widget.isDispatch,
                  onPop: () {
                    provider.changeEditMaterialStep(0);
                  },
                );
        },
      ),
    );
  }
}
