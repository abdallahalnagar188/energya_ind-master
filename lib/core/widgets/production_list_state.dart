import 'package:energya_ind/core/utils/app_routers.dart';
import 'package:energya_ind/core/utils/extentions.dart';
import 'package:energya_ind/frontend/home/widgets/production_item.dart';
import 'package:flutter/material.dart';

class ProductionListState {
  static List<ProductionItem> getProductionListItems(BuildContext context) {
    return [
      ProductionItem(
          imageAsset: 'images/prepraction.png',
          productionName: 'Prepration',
          onTapAction: () =>
              context.NavigatePushTo(AppRouters.kPrepractionInsertPage)),
      ProductionItem(
          imageAsset: 'images/assemply.png',
          productionName: 'Assembly',
          onTapAction: () =>
              context.NavigatePushTo(AppRouters.kAssemplayInsertPage)),
      ProductionItem(
          imageAsset: 'images/welding.png',
          productionName: 'Welding',
          onTapAction: () =>
              context.NavigatePushTo(AppRouters.kWeldingInsertPage)),
      ProductionItem(
          imageAsset: 'images/visual.png',
          productionName: 'Visual',
          onTapAction: () =>
              context.NavigatePushTo(AppRouters.kvisualInsertPage)),
      ProductionItem(
        imageAsset: 'images/follow up.png',
        productionName: 'Follow-up',
        onTapAction: () => context.NavigatePushTo(AppRouters.kFollowUpPage),
      ),
      ProductionItem(
        imageAsset: 'images/painting.png',
        productionName: 'Painting',
        onTapAction: () =>
            context.NavigatePushTo(AppRouters.kPaintingInsertPage),
      ),
      ProductionItem(
        imageAsset: 'images/dispatch.png',
        productionName: 'Dispatch',
        onTapAction: () =>
            context.NavigatePushTo(AppRouters.kDispatchInsertPage),
      ),
      ProductionItem(
        imageAsset: 'images/galv.png',
        productionName: 'Galvanization',
        onTapAction: () =>
            context.NavigatePushTo(AppRouters.kGlavonizationInsertPage),
      ),
      ProductionItem(
        imageAsset: 'images/prepraction.png',
        productionName: 'Cutting',
        onTapAction: () =>
            context.NavigatePushTo(AppRouters.kCuttingInsertPage),
      ),
    ];
  }
}
