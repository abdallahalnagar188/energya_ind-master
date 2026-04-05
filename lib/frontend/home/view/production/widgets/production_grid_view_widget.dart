import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/widgets/production_list_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:energya_ind/core/helper/providers/user_provider.dart';
import 'package:energya_ind/core/models/authority_model.dart';

class ProductionGridViewPage extends StatelessWidget {
  const ProductionGridViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context);
    List<AuthorityModel> activeAuthorities =
        user.user?.authorities.where((auth) => auth.isActive).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStaticColor.primary.withValues(alpha: 0.5),
        title: const Text('Production'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 20, left: 8, top: 12, bottom: 12),
        child: GridView.builder(
          itemCount: activeAuthorities.length,
          clipBehavior: Clip.none,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 7,
            mainAxisSpacing: 15,
          ),
          itemBuilder: (context, index) {
            var auth = activeAuthorities[index];
            return ProductionListState.getProductionListItems(
                context)[user.user?.authorities.indexOf(auth) ?? 0];
          },
        ),
      ),
    );
  }
}
