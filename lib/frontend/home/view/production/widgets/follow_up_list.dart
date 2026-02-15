import 'package:energya_ind/core/utils/app_routers.dart';
import 'package:energya_ind/core/utils/extentions.dart';
import 'package:energya_ind/frontend/home/widgets/production_item.dart';
import 'package:flutter/material.dart';

class FollowUpList {
  static List<ProductionItem> getFollowUpList(BuildContext context) {
    return [
      ProductionItem(
        imageAsset: 'images/follow up.png',
        productionName: 'Glavanization',
        onTapAction: () =>
            context.NavigatePushTo(AppRouters.kGlavonizationInsertPage),
      ),
      ProductionItem(
        imageAsset: 'images/follow up.png',
        productionName: 'Dispatch',
        onTapAction: () =>
            context.NavigatePushTo(AppRouters.kDispatchInsertPage),
      ),
      ProductionItem(
        imageAsset: 'images/follow up.png',
        productionName: 'Painting',
        onTapAction: () =>
            context.NavigatePushTo(AppRouters.kPaintingInsertPage),
      ),
    ];
  }

 
}
