import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/helper/providers/excel_provider.dart';
import 'package:energya_ind/core/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget totalWeightWidget(BuildContext context) {
  var excel = context.watch<ExcelProvider>();
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            RichText(
              text: TextSpan(
                text: 'Total :   ',
                style: Styles.textStyle16600.copyWith(
                    fontSize: 20,
                    color: AppStaticColor.darkGray.withValues(alpha: .6)),
                children: [
                  TextSpan(
                    text: '${excel.totalMarksWeight}',
                    style: Styles.textStyle16600.copyWith(
                        fontSize: 24,
                        color: AppStaticColor.darkGray.withValues(alpha: .8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
