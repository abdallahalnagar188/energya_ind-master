import 'package:energya_ind/frontend/home/view/production/layout/production_layout.dart';
import 'package:flutter/material.dart';
class FollowUpInsertPage extends StatelessWidget {
  const FollowUpInsertPage({super.key});

  @override
  Widget build(BuildContext context) {
    //var ex = Provider.of<ExcelFileProvider>(context);
    return const ProductionLayout(
      title: 'Follow-Up',
      moreDirs: true,
    );
  }
}
