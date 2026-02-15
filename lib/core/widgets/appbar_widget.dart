import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/utils/styles.dart';
import 'package:flutter/material.dart';

AppBar buildAppBar(
  String title, {
  required void Function()? onPressed,
  List<Widget>? actions,
}) {
  return AppBar(
    backgroundColor: AppStaticColor.primary.withAlpha(128),
    title: Text(
      title,
      style:
          Styles.textStyle16600.copyWith(color: Colors.white70, fontSize: 18),
    ),
    centerTitle: true,
    automaticallyImplyLeading: false,
    leading: IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back),
    ),
    actions: actions,
  );
}
