import 'package:energya_ind/core/config/app_colors.dart';
import 'package:energya_ind/core/helper/providers/user_provider.dart';
import 'package:energya_ind/core/utils/directions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawar extends StatelessWidget {
  const CustomDrawar({super.key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context);
    return Drawer(
      width: context.width * 0.6,
      shadowColor: AppStaticColor.primary,
      surfaceTintColor: AppStaticColor.primary,
      
      child: ListView(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(right: 48, top: 48, left: 48, bottom: 24),
            child: SizedBox(
              child: Container(
                height: 100,
                width: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppStaticColor.primary,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'images/person2.jpg',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          const Align(
              alignment: Alignment.center, child: Text('adham mohamed')),
          const Align(
              alignment: Alignment.center, child: Text('adhaamm7md@gmail.com')),
          SizedBox(
            height: context.height * 0.01,
          ),
          const ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
          ),
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('Person'),
          ),
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text('settings'),
          ),
          const ListTile(
            leading: Icon(Icons.details),
            title: Text('Details'),
          ),
          const Divider(
            color: AppStaticColor.text,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () async {
              await user.logoutUser(context);
            },
          ),
        ],
      ),
    );
  }
}
