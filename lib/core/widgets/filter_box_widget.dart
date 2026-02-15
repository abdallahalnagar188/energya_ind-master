import 'package:energya_ind/core/config/app_colors.dart';
import 'package:flutter/material.dart';

Widget filterBox(String text, {Color? color, void Function()? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      child: Align(child: Text(text)),
    ),
  );
}

Widget filterItems(List<String> filters,int selectedState, {required void Function(int) onTap}) {

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: List.generate(filters.length, (index) {
        return filterBox(
          filters[index],
          color: selectedState == index
              ? AppStaticColor.primary.withValues(alpha: .6)
              : AppStaticColor.primary.withValues(alpha: .2),
          onTap: () {
            onTap(index);
          },
        );
      }),
    ),
  );
}
