import 'package:energya_ind/export.dart';
import 'package:energya_ind/frontend/home/layout/material_step1_layout.dart';
import 'package:energya_ind/frontend/home/view/material/material_controller.dart';
import 'package:energya_ind/frontend/home/view/reports/reports_step2_screen.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MaterialController(),
      child: Consumer<MaterialController>(
        builder: (context, provider, child) {
          return provider.materialStep == 0
              ? MaterialStep1Layout(
                  title: 'Reports',
                  isProd: false,
                  isReport: true,
                  onNext: () {
                    provider.changeEditMaterialStep(1);
                  },
                )
              : ReportsStep2Screen(
                  onPop: () {
                    provider.changeEditMaterialStep(0);
                  },
                );
        },
      ),
    );
  }
}
