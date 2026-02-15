// ignore: must_be_immutable
import 'package:energya_ind/core/config/app_colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HeadLineBar extends StatelessWidget {
  HeadLineBar(
      {super.key,
      required this.headLineText,
      this.secondeHeadLineText,
      this.onTapAction});
  final String headLineText;
  final String? secondeHeadLineText;
  VoidCallback? onTapAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 5,
            color: AppStaticColor.primary,
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  headLineText,
                  style: const TextStyle(
                      color: AppStaticColor.black, fontSize: 18),
                ),
                if (secondeHeadLineText != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: onTapAction,
                      child: Text(
                        secondeHeadLineText!,
                        style: const TextStyle(
                            color: AppStaticColor.primary, fontSize: 18),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
