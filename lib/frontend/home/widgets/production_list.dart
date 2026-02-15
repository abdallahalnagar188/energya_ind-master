import 'package:energya_ind/core/helper/providers/user_provider.dart';
import 'package:energya_ind/core/models/authority_model.dart';
import 'package:energya_ind/core/widgets/production_list_state.dart';
import 'package:flutter/material.dart';
import 'package:energya_ind/core/utils/directions.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ProductionList extends StatelessWidget {
  const ProductionList({super.key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context);
    List<AuthorityModel> activeAuthorities =
        user.user?.authorities.where((auth) => auth.isActive).toList() ?? [];
    print(activeAuthorities.map((e) => e.toString()));
    return SizedBox(
      height: activeAuthorities.isNotEmpty ? context.height * 0.32 : 0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: activeAuthorities.map((auth) {
          return ProductionListState.getProductionListItems(
              context)[user.user?.authorities.indexOf(auth) ?? 0];
        }).toList(),
      ),
    );
  }
}
