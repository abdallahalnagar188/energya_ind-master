import 'package:flutter/material.dart';
import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/utils/directions.dart';

class MaterialListItem extends StatelessWidget {
  const MaterialListItem({
    super.key,
    required this.titel,
    required this.iconData,
    this.onTap,
  });
  final String titel;
  final IconData iconData;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.height * 0.17,
        width: context.width * 0.35,
        decoration: BoxDecoration(
            color: const Color(0xff292929),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 64,
              color: AppStaticColor.primary,
            ),
            SizedBox(
              height: context.height * 0.022,
            ),
            Text(
              titel,
              style: const TextStyle(color: AppStaticColor.white),
            )
          ],
        ),
      ),
    );
  }
}
