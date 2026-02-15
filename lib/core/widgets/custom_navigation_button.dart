import 'package:flutter/material.dart';
import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/utils/extentions.dart';

// ignore: must_be_immutable
class CustomNavigatorButton extends StatelessWidget {
  CustomNavigatorButton({
    super.key,
    required this.buttonName,
    this.nextRoutName,
    this.borderRadius = 12,
    this.onTap,
    this.border = false,
    this.btnColor,
  });
  String buttonName;
  String? nextRoutName;
  double borderRadius;
  final bool border;
  final void Function()? onTap;
  final Color? btnColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () {
            context.NavigatePushTo(nextRoutName!);
          },
      highlightColor: AppStaticColor.primary.withOpacity(0.2),
      splashColor: AppStaticColor.primary.withOpacity(0.5),
      child: Container(
        height: 55,
        width: 150,
        decoration: BoxDecoration(
          color: border
              ? Colors.transparent
              : btnColor ?? AppStaticColor.primary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(borderRadius),
          border: border
              ? Border.all(color: AppStaticColor.primary, width: 4)
              : null,
        ),
        child: Center(
          child: Text(
            buttonName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}
