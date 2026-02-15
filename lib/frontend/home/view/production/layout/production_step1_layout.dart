import 'package:energya_ind/frontend/home/layout/material_step1_layout.dart';
import 'package:flutter/material.dart';

class ProductionStep1Layout extends StatefulWidget {
  const ProductionStep1Layout({super.key, required this.title, required this.onNext,});
  final String title;
  final dynamic Function() onNext;
  @override
  State<ProductionStep1Layout> createState() => _ProductionLayoutState();
}

class _ProductionLayoutState extends State<ProductionStep1Layout> {
  @override
  Widget build(BuildContext context) {
    return MaterialStep1Layout(
      title: widget.title,
      isProd: true,
      onNext: widget.onNext,
    );
  }
}
