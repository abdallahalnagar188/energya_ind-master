import 'package:energya_ind/core/config/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/utils/directions.dart';

class LogoBody extends StatelessWidget {
  const LogoBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'location-img-${AppStrings.logo}',
      child: Stack(
        children: [
          Container(
            height: context.height * 0.25,
            width: context.width * 0.75,
            // color: kBlackColor,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.blueAccent.withOpacity(0.8), width: 3),
                shape: BoxShape.circle,
                color: AppStaticColor.primary.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            right: context.width * 0.16,
            child: Image.asset(
              fit: BoxFit.fill,
              AppStrings.logo,
              height: context.height * 0.2,
              width: context.width * 0.5,
            ),
          )
        ],
      ),
    );
  }
}
