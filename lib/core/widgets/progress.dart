import 'package:energya_ind/core/config/app_colors.dart';
import 'package:flutter/material.dart';

Widget progress() {
  return Container(
    height: 55,
    width: 55,
    alignment: Alignment.center,
    //padding: const,
    decoration:
        const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
      BoxShadow(
        color: AppStaticColor.darkGray,
        blurRadius: 10,
        offset: Offset(0, 0),
      )
    ]),
    child: const CircularProgressIndicator(
      color: AppStaticColor.primary,
    ),
  );
}

Widget progressLoad(double d) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Container(
        height: 120,
        width: 120,
        alignment: Alignment.center,
        //padding: const,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .7),
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(
            strokeWidth: 10,
            color: AppStaticColor.primary,
            value: d / 100,
          ),
        ),
      ),
      Text(
        '${d.toInt()}',
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppStaticColor.primary),
      )
    ],
  );
}
